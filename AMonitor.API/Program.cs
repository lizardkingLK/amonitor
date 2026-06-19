using AMonitor.API.Extensions.Configuration;
using AMonitor.API.Extensions.Database;
using AMonitor.API.Extensions.Routing;
using AMonitor.API.Extensions.Services;

namespace AMonitor.API;

public partial class Program
{
    private static void Main(string[] args)
    {
        WebApplicationBuilder builder = WebApplication.CreateSlimBuilder(args);
        builder.AddAppConfigurations();
        builder.Services.AddDatabaseServices(builder.Configuration);
        builder.Services.AddServices(builder.Configuration);
        builder.Services.AddOpenApi();
        try
        {
            WebApplication app = builder.Build();
            if (app.Environment.IsDevelopment())
            {
                app.MapOpenApi();
            }

            app.ApplyMigrations();
            app.MapAlertRoutes();
            app.Run();
        }
        catch (Exception)
        {
            Environment.Exit(1);
        }
    }
}
