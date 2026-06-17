namespace AMonitor.API.Models.Options;

public class DatabaseOptions
{
    public const string SectionName = "Database";

    public string ConnectionString { get; set; } = string.Empty;
}
