namespace AMonitor.API.Extensions.Logging;

public static partial class LoggingExtensions
{
    [LoggerMessage(
        EventId = 1000,
        Level = LogLevel.Information,
        Message = "info. {Message}")]
    public static partial void LogAmonitorInfo(this ILogger logger, string message);

    [LoggerMessage(
        EventId = 1001,
        Level = LogLevel.Error,
        Message = "info. {Message}")]
    public static partial void LogAmonitorError(this ILogger logger, string message);
}

public sealed class ConsoleLogger(string categoryName) : ILogger
{
    private readonly string _categoryName = categoryName;

    public void Log<TState>(
        LogLevel logLevel,
        EventId eventId,
        TState state,
        Exception? exception,
        Func<TState, Exception?, string> formatter)
    {
        string time = DateTime.Now.ToString("hh:mm:ss ");
        string message = formatter(state, exception);

        Console.WriteLine($"{time} {_categoryName}[{eventId.Id}] -> {message}");
    }

    public bool IsEnabled(LogLevel logLevel) => true;
    public IDisposable? BeginScope<TState>(TState state) where TState : notnull => null;
}

public sealed class ConsoleLoggerProvider : ILoggerProvider
{
    public ILogger CreateLogger(string categoryName) => new ConsoleLogger(categoryName);
    public void Dispose() { }
}
