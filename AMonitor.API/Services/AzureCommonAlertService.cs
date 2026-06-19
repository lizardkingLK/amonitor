using System.Text.Json;
using AMonitor.API.Data;
using AMonitor.API.Extensions.Configuration;
using AMonitor.API.Models.Common;

namespace AMonitor.API.Services;

public interface IAzureCommonAlertService
{
    Task CreateAlertAsync(string rawJson, CancellationToken cancellationToken);
}

public class AzureCommonAlertService(
    ApplicationDbContext dbContext,
    ILogger<AzureCommonAlertService> logger) : IAzureCommonAlertService
{
    private readonly ApplicationDbContext _dbContext = dbContext;
    private readonly ILogger<AzureCommonAlertService> _logger = logger;

    public async Task CreateAlertAsync(
        string rawJson,
        CancellationToken cancellationToken)
    {
        _logger.LogInformation("info. processing and storing alert to db...");
        
        AzureCommonAlertPayload alertRecord = new()
        {
            Id = Guid.NewGuid(),
            SchemaId = "azureMonitorCommonAlertSchema",
            DataJson = JsonSerializer.Serialize(
                JsonDocument.Parse(rawJson),
                ConfigurationSerializerContext.Default.AlertData)
        };

        _dbContext.Alerts.Add(alertRecord);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }
}