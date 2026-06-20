using System.Text.Json;
using AMonitor.API.Data;
using AMonitor.API.Extensions.Logging;
using AMonitor.API.Models.Common;
using Microsoft.EntityFrameworkCore;

namespace AMonitor.API.Services;

public class AzureCommonAlertService(
    ApplicationDbContext dbContext,
    ILogger<AzureCommonAlertService> logger)
{
    private readonly ApplicationDbContext _dbContext = dbContext;
    private readonly ILogger<AzureCommonAlertService> _logger = logger;

    public async Task CreateAlertAsync(
        string rawJson,
        CancellationToken cancellationToken)
    {
        _logger.LogAmonitorInfo("info. processing and storing alert to db...");

        string finalJsonToStore = rawJson;

        try
        {
            using JsonDocument doc = JsonDocument.Parse(rawJson);

            JsonElement root = doc.RootElement;
            if (root.TryGetProperty("data", out JsonElement innerData) &&
                innerData.TryGetProperty("essentials", out _))
            {
                finalJsonToStore = innerData.GetRawText();
            }
        }
        catch (Exception ex)
        {
            _logger.LogAmonitorInfo("error. could not sanitize logic app wrapper, using raw format: " + ex.Message);
        }

        AzureCommonAlertPayload alertRecord = new()
        {
            Id = Guid.NewGuid(),
            SchemaId = "azureMonitorCommonAlertSchema",
            DataJson = finalJsonToStore,
        };

        _dbContext.Alerts.Add(alertRecord);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task<List<AzureCommonAlertPayload>> GetAlertsOlderThan(
        TimeSpan oldAbout,
        CancellationToken stoppingToken)
    {
        DateTimeOffset ageBoundary = DateTimeOffset.UtcNow.Add(-oldAbout);

        return await _dbContext.Alerts
        .Where(a => EF.Property<DateTimeOffset>(a, "FiredDateTime") < ageBoundary)
        .ToListAsync(stoppingToken);
    }

    public async Task RemoveAlerts(
        List<AzureCommonAlertPayload> oldAlerts,
        CancellationToken stoppingToken)
    {
        _dbContext.Alerts.RemoveRange(oldAlerts);
        await _dbContext.SaveChangesAsync(stoppingToken);
    }
}
