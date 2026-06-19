using System.Text.Json;
using AMonitor.API.Data;
using AMonitor.API.Extensions.Configuration;
using AMonitor.API.Models.Common;
using AMonitor.API.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AMonitor.API.Extensions.Routing;

public static class AlertRoutesExtension
{
    public static RouteGroupBuilder MapAlertRoutes(this WebApplication app)
    {
        RouteGroupBuilder root = app.MapGroup("/api");

        root.MapGet("/azure-alerts",
            () => "info. azure-alerts webhook is online 🟢...")
            .WithName("GetAlerts");

        root.MapPost("/azure-alerts", async (
            [FromBody] JsonElement payload,
            [FromServices] IAzureCommonAlertService azureCommonAlertService,
            CancellationToken cancellationToken) =>
        {
            string rawJson = payload.GetRawText();

            await azureCommonAlertService.CreateAlertAsync(rawJson, cancellationToken);

            return Results.Ok(new { message = "info. azure-alerts webhook processed 🟢" });
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