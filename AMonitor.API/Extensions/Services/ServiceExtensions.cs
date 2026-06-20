using AMonitor.API.Jobs;
using AMonitor.API.Models.Options;
using AMonitor.API.Services;
using Azure.Storage.Blobs;
using Azure.Storage.Queues;

namespace AMonitor.API.Extensions.Services;

public static class ServiceExtensions
{
    public static IServiceCollection AddServices(
        this IServiceCollection services,
        ConfigurationManager configuration)
    {
        QueueOptions? queueOptions = configuration
        .GetSection(QueueOptions.SectionName)
        .Get<QueueOptions>();

        if (queueOptions == null ||
            string.IsNullOrWhiteSpace(queueOptions.ConnectionString) ||
            queueOptions.ConnectionString == "USE_DEVELOPMENT_PLACEHOLDER")
        {
            services.AddSingleton<QueueClient>(provider => null!);
        }
        else
        {
            services.AddSingleton(new QueueClient(
                queueOptions.ConnectionString,
                queueOptions.QueueName,
                new QueueClientOptions
                {
                    MessageEncoding = QueueMessageEncoding.Base64,
                }));
        }

        StorageOptions? storageOptions = configuration
        .GetSection(StorageOptions.SectionName)
        .Get<StorageOptions>();

        if (storageOptions == null ||
            string.IsNullOrWhiteSpace(storageOptions.ConnectionString) ||
            storageOptions.ConnectionString == "USE_DEVELOPMENT_PLACEHOLDER")
        {
            services.AddSingleton<BlobServiceClient>(provider => null!);
        }
        else
        {
            services.AddSingleton(new BlobServiceClient(
                storageOptions.ConnectionString));
        }

        services.AddScoped<AzureCommonAlertService>();

        services.AddHostedService<QueueProcessorWorker>();
        services.AddHostedService<ArchiveProcessorWorker>();

        return services;
    }
}