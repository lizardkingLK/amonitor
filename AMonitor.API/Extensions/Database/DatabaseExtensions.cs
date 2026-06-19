using AMonitor.API.Data;
using AMonitor.API.Models.Options;
using Microsoft.EntityFrameworkCore;

namespace AMonitor.API.Extensions.Database;

public static class DatabaseExtensions
{
    public static IServiceCollection AddDatabaseServices(
    this IServiceCollection services,
    IConfiguration configuration)
    {
        DatabaseOptions? databaseOptions = configuration
        .GetSection(DatabaseOptions.SectionName)
        .Get<DatabaseOptions>();
        if (databaseOptions == null || string.IsNullOrWhiteSpace(databaseOptions.ConnectionString))
        {
            throw new InvalidOperationException(
                "error. database ConnectionString is missing from configuration.");
        }

        string connectionString = databaseOptions.ConnectionString;

        bool isRunningInDocker = Environment.GetEnvironmentVariable("DOTNET_RUNNING_IN_CONTAINER") == "true";
        if (isRunningInDocker && connectionString.Contains("127.0.0.1"))
        {
            connectionString = connectionString.Replace("127.0.0.1", "host.docker.internal");
        }

        services.AddDbContext<ApplicationDbContext>(options =>
            options
                .UseNpgsql(connectionString)
                .UseModel(Data.Compiled.ApplicationDbContextModel.Instance));

        return services;
    }


    public static WebApplication ApplyMigrations(this WebApplication app)
    {
        using (IServiceScope scope = app.Services.CreateScope())
        {
            ApplicationDbContext dbContext = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
            dbContext.Database.Migrate();
        }

        return app;
    }
}