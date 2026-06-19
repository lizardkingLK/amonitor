using AMonitor.API.Jobs;
using AMonitor.API.Models.Options;
using AMonitor.API.Services;
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
        if (queueOptions == null || string.IsNullOrWhiteSpace(queueOptions.ConnectionString))
        {
            throw new InvalidOperationException(
                "error. queue ConnectionString is missing from configuration.");
        }

        services.AddSingleton(new QueueClient(queueOptions.ConnectionString, queueOptions.QueueName));

        services.AddScoped<IAzureCommonAlertService, AzureCommonAlertService>();

        services.AddHostedService<QueueProcessorWorker>();

        return services;
    }
}