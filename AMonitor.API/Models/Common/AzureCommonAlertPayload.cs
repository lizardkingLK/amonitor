using System.Text.Json;
using System.Text.Json.Serialization;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace AMonitor.API.Models.Common;

public class AzureCommonAlertPayload
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public Guid Id { get; set; }

    [JsonPropertyName("schemaId")]
    public string? SchemaId { get; set; }

    [NotMapped]
    [JsonPropertyName("data")]
    public AlertData? Data { get; set; }

    [Column("data", TypeName = "jsonb")]
    [JsonIgnore]
    public string? DataJson { get; set; }
}

public class AlertData
{
    [JsonPropertyName("essentials")]
    public Essentials? Essentials { get; set; }

    [JsonPropertyName("customProperties")]
    public Dictionary<string, string>? CustomProperties { get; set; }

    [JsonPropertyName("alertContext")]
    public JsonElement? AlertContext { get; set; }

    [JsonExtensionData]
    public Dictionary<string, JsonElement>? ExtensionData { get; set; }
}

public class Essentials
{
    [JsonPropertyName("alertId")]
    public string? AlertId { get; set; }

    [JsonPropertyName("alertRule")]
    public string? AlertRule { get; set; }

    [JsonPropertyName("alertRuleId")]
    public string? AlertRuleId { get; set; }

    [JsonPropertyName("severity")]
    public string? Severity { get; set; }

    [JsonPropertyName("signalType")]
    public string? SignalType { get; set; }

    [JsonPropertyName("monitorCondition")]
    public string? MonitorCondition { get; set; }

    [JsonPropertyName("monitoringService")]
    public string? MonitoringService { get; set; }

    [JsonPropertyName("alertTargetIDs")]
    public List<string>? AlertTargetIDs { get; set; }

    [JsonPropertyName("targetResourceName")]
    public string? TargetResourceName { get; set; }

    [JsonPropertyName("targetResource")]
    public string? TargetResource { get; set; }

    [JsonPropertyName("targetResourceGroup")]
    public string? TargetResourceGroup { get; set; }

    [JsonPropertyName("targetResourceType")]
    public string? TargetResourceType { get; set; }

    [JsonPropertyName("configurationItems")]
    public List<string>? ConfigurationItems { get; set; }

    [JsonPropertyName("originAlertId")]
    public string? OriginAlertId { get; set; }

    [JsonPropertyName("firedDateTime")]
    public DateTimeOffset? FiredDateTime { get; set; }

    [JsonPropertyName("resolvedDateTime")]
    public DateTimeOffset? ResolvedDateTime { get; set; }

    [JsonPropertyName("description")]
    public string? Description { get; set; }

    [JsonPropertyName("essentialsVersion")]
    public string? EssentialsVersion { get; set; }

    [JsonPropertyName("alertContextVersion")]
    public string? AlertContextVersion { get; set; }
}
