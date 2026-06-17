using System.Text.Json;
using AMonitor.API.Data;
using AMonitor.API.Extensions.Configuration;
using AMonitor.API.Extensions.Logging;
using AMonitor.API.Models.Common;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AMonitor.API.Extensions.Routing;

public static class AlertRoutesExtension
{
    public static RouteGroupBuilder MapAlertRoutes(this WebApplication app)
    {
        RouteGroupBuilder root = app.MapGroup("/api");

        root.MapGet("/azure-alerts",
            () => "info. azure-alerts webhook is online 🟢...").WithName("GetAlerts");

        root.MapPost("/azure-alerts", async (
            AzureCommonAlertPayload payload,
            [FromServices] ApplicationDbContext dbContext,
            ILogger<Program> logger) =>
        {
            Essentials? essentials = payload.Data?.Essentials;

            logger.LogAzureAlert(
                essentials?.AlertRule ?? string.Empty,
                essentials?.Severity ?? string.Empty,
                essentials?.TargetResourceName ?? string.Empty);

            if (payload.Data != null)
            {
                payload.DataJson = JsonSerializer.Serialize(
                    payload.Data,
                    ConfigurationSerializerContext.Default.AlertData);
            }

            dbContext.Add(payload);
            await dbContext.SaveChangesAsync();

            return Results.Accepted();
        })
        .WithName("PostAlert");

        root.MapGet("/azure-alerts/logs", async (ApplicationDbContext dbContext) =>
        {
            List<AzureCommonAlertPayload> rawAlerts = await dbContext.Alerts
                .AsNoTracking()
                .OrderByDescending(a => a.Id)
                .Take(5)
                .ToListAsync();
            foreach (AzureCommonAlertPayload alert in rawAlerts)
            {
                if (!string.IsNullOrWhiteSpace(alert.DataJson))
                {
                    alert.Data = JsonSerializer.Deserialize(
                        alert.DataJson,
                        ConfigurationSerializerContext.Default.AlertData);
                }
            }

            return Results.Ok(rawAlerts);
        })
        .WithName("GetLatestAlerts");

        return root;
    }
}