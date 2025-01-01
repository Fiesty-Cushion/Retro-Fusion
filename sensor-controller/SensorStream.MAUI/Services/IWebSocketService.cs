

namespace SensorStream.MAUI.Services;

public interface IWebSocketService
{
    bool IsConnected { get; }

    event Action<string> MessageReceived;
    event Action<Exception, string> ErrorOccurred;
    event Action? ServerConnected;

    Task ConnectAsync(Uri serverUri, CancellationToken cancellationToken);
    Task DisconnectAsync();
    void Dispose();
    Task SendAsync(string message, CancellationToken cancellationToken);
}
