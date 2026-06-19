using AMonitor.API.Extensions.Logging;
using AMonitor.API.Models.Options;
using AMonitor.API.Services;
using Azure.Storage.Queues;
using Azure.Storage.Queues.Models;
using Microsoft.Extensions.Options;

namespace AMonitor.API.Jobs;

public class QueueProcessorWorker(
    IServiceProvider serviceProvider,
    ILogger<QueueProcessorWorker> logger,
    IOptions<QueueOptions> queueOptions,
    QueueClient? queueClient = null) : BackgroundService
{
    private readonly IServiceProvider _serviceProvider = serviceProvider;
    private readonly ILogger<QueueProcessorWorker> _logger = logger;
    private readonly IOptions<QueueOptions> _queueOptions = queueOptions;
    private readonly QueueClient? _queueClient = queueClient;

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        if (string.IsNullOrWhiteSpace(_queueOptions.Value.ConnectionString) ||
        _queueOptions.Value.ConnectionString == "USE_DEVELOPMENT_PLACEHOLDER")
        {
            _logger.LogAmonitorInfo("local development environment. queue polling exits now");
            return;
        }

        _logger.LogAmonitorInfo("queue ingestion background worker has started");

        await _queueClient!.CreateIfNotExistsAsync(cancellationToken: stoppingToken);
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                QueueMessage[] messages = await _queueClient.ReceiveMessagesAsync(
                    maxMessages: 5,
                    cancellationToken: stoppingToken);
                if (messages.Length == 0)
                {
                    continue;
                }

                using AsyncServiceScope scope = _serviceProvider.CreateAsyncScope();

                AzureCommonAlertService azureCommonAlertService = scope.ServiceProvider
                .GetRequiredService<AzureCommonAlertService>();
                foreach (QueueMessage message in messages)
                {
                    string rawJson = message.Body.ToString();

                    await azureCommonAlertService.CreateAlertAsync(rawJson, stoppingToken);

                    await _queueClient.DeleteMessageAsync(
                        message.MessageId,
                        message.PopReceipt,
                        stoppingToken);
                }
            }
            catch (Exception ex)
            {
                _logger.LogAmonitorError($"could not process item: {ex.Message}");
            }

            await Task.Delay(TimeSpan.FromSeconds(5), stoppingToken);
        }
    }
}