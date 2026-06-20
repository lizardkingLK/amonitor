using System.Text.Json.Serialization;
using AMonitor.API.Extensions.Logging;
using AMonitor.API.Models.Common;
using AMonitor.API.Models.Options;

namespace AMonitor.API.Extensions.Configuration;

[JsonSerializable(typeof(DatabaseOptions))]
[JsonSerializable(typeof(QueueOptions))]
[JsonSerializable(typeof(StorageOptions))]
[JsonSerializable(typeof(AzureCommonAlertPayload))]
internal partial class ConfigurationSerializerContext : JsonSerializerContext { }

public static class ConfigurationExtensions
{
    public static WebApplicationBuilder AddAppConfigurations(this WebApplicationBuilder builder)
    {
        builder.Logging.ClearProviders();
        builder.Logging.AddProvider(new ConsoleLoggerProvider());

        builder.Services.ConfigureHttpJsonOptions(options =>
        {
            options.SerializerOptions.TypeInfoResolverChain
                .Insert(0, ConfigurationSerializerContext.Default);
        });

        builder.Services.Configure<DatabaseOptions>(
            builder.Configuration.GetSection(DatabaseOptions.SectionName));

        builder.Services.Configure<QueueOptions>(
            builder.Configuration.GetSection(QueueOptions.SectionName));

        builder.Services.Configure<StorageOptions>(
            builder.Configuration.GetSection(StorageOptions.SectionName));

        return builder;
    }
}