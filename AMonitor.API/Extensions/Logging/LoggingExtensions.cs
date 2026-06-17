namespace AMonitor.API.Extensions.Logging;

public static partial class LoggingExtensions
{
    [LoggerMessage(
        EventId = 1001,
        Level = LogLevel.Information,
        Message = "Azure Alert fired! Rule: {AlertRule}, Severity: {Severity}, Target: {TargetResourceName}")]
    public static partial void LogAzureAlert(this ILogger logger, string alertRule, string severity, string targetResourceName);
}
