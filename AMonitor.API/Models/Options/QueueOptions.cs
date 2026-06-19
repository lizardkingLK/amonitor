namespace AMonitor.API.Models.Options;

public class QueueOptions
{
    public const string SectionName = "Queue";

    public string ConnectionString { get; set; } = string.Empty;

    public string QueueName { get; set; } = string.Empty;
}