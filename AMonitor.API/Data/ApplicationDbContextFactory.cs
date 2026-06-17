using AMonitor.API.Models.Options;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace AMonitor.API.Data;

public class ApplicationDbContextFactory : IDesignTimeDbContextFactory<ApplicationDbContext>
{
    public ApplicationDbContext CreateDbContext(string[] args)
    {
        string environment = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Development";

        IConfigurationRoot configuration = new ConfigurationBuilder()
            .SetBasePath(Directory.GetCurrentDirectory())
            .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
            .AddJsonFile($"appsettings.{environment}.json", optional: true)
            .AddEnvironmentVariables()
            .Build();

        DatabaseOptions databaseOptions = configuration
            .GetSection(DatabaseOptions.SectionName)
            .Get<DatabaseOptions>()
            ?? throw new InvalidOperationException("error. database configuration section is missing.");

        string connectionString = databaseOptions.ConnectionString;

        bool isRunningInDocker = Environment.GetEnvironmentVariable("DOTNET_RUNNING_IN_CONTAINER") == "true";
        if (isRunningInDocker && connectionString.Contains("127.0.0.1"))
        {
            connectionString = connectionString.Replace("127.0.0.1", "host.docker.internal");
        }

        DbContextOptionsBuilder<ApplicationDbContext> optionsBuilder = new();
        optionsBuilder.UseNpgsql(connectionString);

        return new ApplicationDbContext(optionsBuilder.Options);
    }

}

