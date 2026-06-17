using System.Text.Json.Serialization;
using AMonitor.API.Models.Common;
using AMonitor.API.Models.Options;

namespace AMonitor.API.Extensions.Configuration;

[JsonSerializable(typeof(DatabaseOptions))]
[JsonSerializable(typeof(AzureCommonAlertPayload))]
internal partial class ConfigurationSerializerContext : JsonSerializerContext { }

public static class ConfigurationExtensions
{
    public static WebApplicationBuilder AddAppConfigurations(this WebApplicationBuilder builder)
    {
        builder.Services.ConfigureHttpJsonOptions(options =>
        {
            options.SerializerOptions.TypeInfoResolverChain
                .Insert(0, ConfigurationSerializerContext.Default);
        });

        builder.Services.Configure<DatabaseOptions>(
            builder.Configuration.GetSection(DatabaseOptions.SectionName));

        return builder;
    }
}