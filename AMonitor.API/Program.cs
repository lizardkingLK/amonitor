using AMonitor.API.Extensions.Configuration;
using AMonitor.API.Extensions.Database;
using AMonitor.API.Extensions.Routing;

namespace AMonitor.API;

public partial class Program
{
    private static void Main(string[] args)
    {
        WebApplicationBuilder builder = WebApplication.CreateSlimBuilder(args);

        //        
        builder.Logging.AddConsole();
        //

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

            // Force an exit code of 1 so Docker knows it crashed instead of cleanly exiting
            Environment.Exit(1);
        }


        // WebApplication app = builder.Build();
        // if (app.Environment.IsDevelopment())
        // {
        //     app.MapOpenApi();
        // }

        // app.ApplyMigrations();
        // app.MapAlertRoutes();
        // app.Run();
    }
}
