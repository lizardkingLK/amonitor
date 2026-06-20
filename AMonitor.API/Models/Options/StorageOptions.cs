namespace AMonitor.API.Models.Options;

public class StorageOptions
{
    public const string SectionName = "Storage";

    public string ConnectionString { get; set; } = string.Empty;
    public string StorageName { get; set; } = string.Empty;
}