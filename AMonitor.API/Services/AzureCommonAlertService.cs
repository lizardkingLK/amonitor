using System.Text.Json;
using AMonitor.API.Data;
using AMonitor.API.Extensions.Logging;
using AMonitor.API.Models.Common;

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
}
