using System.Text;
using AMonitor.API.Extensions.Logging;
using AMonitor.API.Models.Common;
using AMonitor.API.Models.Options;
using AMonitor.API.Services;
using Azure.Storage.Blobs;
using Microsoft.Extensions.Options;

namespace AMonitor.API.Jobs;

public class ArchiveProcessorWorker(
    IServiceProvider serviceProvider,
    ILogger<ArchiveProcessorWorker> logger,
    IOptions<StorageOptions> storageOptions,
    BlobServiceClient? storageServiceClient = null) : BackgroundService
{
    private readonly IServiceProvider _serviceProvider = serviceProvider;
    private readonly ILogger<ArchiveProcessorWorker> _logger = logger;
    private readonly IOptions<StorageOptions> _storageOptions = storageOptions;
    private readonly BlobServiceClient? _storageServiceClient = storageServiceClient;

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        if (string.IsNullOrWhiteSpace(_storageOptions.Value.ConnectionString) ||
        _storageOptions.Value.ConnectionString == "USE_DEVELOPMENT_PLACEHOLDER")
        {
            _logger.LogAmonitorInfo("local development environment. archiving exits now");
            return;
        }

        _logger.LogAmonitorInfo("info. starting archiving task...");
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                using AsyncServiceScope scope = _serviceProvider.CreateAsyncScope();

                AzureCommonAlertService azureCommonAlertService = scope.ServiceProvider
                .GetRequiredService<AzureCommonAlertService>();
                List<AzureCommonAlertPayload> oldAlerts = await azureCommonAlertService
                .GetAlertsOlderThan(
                    TimeSpan.FromDays(30),
                    stoppingToken);
                if (oldAlerts.Count == 0)
                {
                    _logger.LogAmonitorInfo("info. no old alerts were found");
                    return;
                }

                StringBuilder archiveBuilder = new();
                foreach (AzureCommonAlertPayload alert in oldAlerts)
                {
                    archiveBuilder.AppendLine(alert.DataJson);
                }

                BlobContainerClient containerClient = _storageServiceClient!
                .GetBlobContainerClient(_storageOptions.Value.StorageName);

                string blobName = $"archive-{DateTime.UtcNow:yyyy-MM-dd}.json";
                BlobClient blobClient = containerClient.GetBlobClient(blobName);

                using MemoryStream stream = new(Encoding.UTF8.GetBytes(archiveBuilder.ToString()));
                await blobClient.UploadAsync(stream, overwrite: true, stoppingToken);

                await azureCommonAlertService.RemoveAlerts(oldAlerts, stoppingToken);

                _logger.LogAmonitorInfo("info. successfully moved old alerts");
            }
            catch (Exception ex)
            {
                _logger.LogAmonitorError("error. alert archiving failed " + ex.Message);
                throw;
            }

            await Task.Delay(TimeSpan.FromHours(24), stoppingToken);
        }
    }
}