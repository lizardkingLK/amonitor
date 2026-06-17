using AMonitor.API.Extensions.Configuration;
using AMonitor.API.Extensions.Database;
using AMonitor.API.Extensions.Routing;

namespace AMonitor.API;

public partial class Program
{
    private static void Main(string[] args)
    {
        WebApplicationBuilder builder = WebApplication.CreateSlimBuilder(args);

        builder.Logging.AddConsole();

        builder.AddAppConfigurations();
        builder.Services.AddDatabaseServices(builder.Configuration);
        builder.Services.AddOpenApi();

        try
        {
            WebApplication app = builder.Build();
            if (app.Environment.IsDevelopment())
            {
                app.MapOpenApi();
            }

            Console.WriteLine("--> Running Database Migrations...");
            app.ApplyMigrations();
            Console.WriteLine("--> Database Migrations Completed Successfully!");

            app.MapAlertRoutes();

            Console.WriteLine("--> Starting Web Application Server...");
            app.Run();
        }
        catch (Exception ex)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.Error.WriteLine($"!!! APPLICATION CRASHED DURING STARTUP: {ex.Message}");
            Console.Error.WriteLine(ex.StackTrace);
            Console.ResetColor();

            Environment.Exit(1);
        }
    }
}
