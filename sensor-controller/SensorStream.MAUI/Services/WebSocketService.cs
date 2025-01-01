using System.Net.WebSockets;
using System.Text;

namespace SensorStream.MAUI.Services;
public sealed class WebSocketService : IDisposable, IWebSocketService
{
    private ClientWebSocket _webSocket;
    private Task? _receivingTask;
    private const int ConnectionTimeout = 5000;

    public event Action<string>? MessageReceived;
    public event Action<Exception, string>? ErrorOccurred;
    public event Action? ServerConnected;
    public bool IsConnected => _webSocket.State == WebSocketState.Open;

    public WebSocketService()
    {
        _webSocket = new ClientWebSocket();
    }

    public async Task ConnectAsync(Uri serverUri, CancellationToken cancellationToken)
    {
        try
        {
            // Ensure WebSocket is in a valid state
            if (_webSocket.State == WebSocketState.Open || _webSocket.State == WebSocketState.Connecting)
            {
                throw new InvalidOperationException("WebSocket is already connected or connecting.");
            }

            // Needed if WebSocket is reconnected after a disconnection
            if (_webSocket.State == WebSocketState.Closed || _webSocket.State == WebSocketState.Aborted)
            {
                _webSocket.Dispose();
                _webSocket = new ClientWebSocket();
            }

            var connectTask = _webSocket.ConnectAsync(serverUri, cancellationToken);

            // Apply timeout for the connection attempt
            if (await Task.WhenAny(connectTask, Task.Delay(ConnectionTimeout, cancellationToken)) == connectTask)
            {
                await connectTask; // Await to catch any exceptions
                _receivingTask = ReceiveAsync(cancellationToken);
                ServerConnected?.Invoke();
            }
            else
            {
                throw new TimeoutException("Timed out, couldn't establish connection.");
            }
        }
        catch (Exception ex)
        {
            ErrorOccurred?.Invoke(ex, nameof(ConnectAsync));
            await CleanupWebSocket();
        }
    }

    public async Task SendAsync(string message, CancellationToken token)
    {
        try { 
            if (_webSocket.State != WebSocketState.Open)
                throw new InvalidOperationException("WebSocket connection is not open.");

            var bytes = Encoding.UTF8.GetBytes(message);
            await _webSocket.SendAsync(new ArraySegment<byte>(bytes), WebSocketMessageType.Text, true, token);
        }
        catch (Exception ex)
        {
            ErrorOccurred?.Invoke(ex, nameof(SendAsync));
        }
    }

    private async Task ReceiveAsync(CancellationToken cancellationToken)
    {
        var buffer = new byte[1024 * 4];

        try
        {
            while (_webSocket.State == WebSocketState.Open)
            {
                var result = await _webSocket.ReceiveAsync(new ArraySegment<byte>(buffer), cancellationToken);
                if (result.MessageType == WebSocketMessageType.Close)
                {
                    await _webSocket.CloseAsync(WebSocketCloseStatus.NormalClosure, "Closing", CancellationToken.None);
                }
                else
                {
                    var message = Encoding.UTF8.GetString(buffer, 0, result.Count);
                    MessageReceived?.Invoke(message);
                }
            }
        }
        catch (OperationCanceledException)
        {
            // Expected exception when the operation is canceled.
        }
        catch (Exception ex)
        {
            ErrorOccurred?.Invoke(ex, nameof(ReceiveAsync));
        }
    }

    public async Task DisconnectAsync()
    {
        if (_webSocket.State == WebSocketState.Open || _webSocket.State == WebSocketState.CloseReceived)
        {
            try
            {
                await _webSocket.CloseAsync(WebSocketCloseStatus.NormalClosure, "Closing", CancellationToken.None);
            }
            catch (WebSocketException ex) when (ex.WebSocketErrorCode == WebSocketError.InvalidState)
            {
                // Ignore InvalidState error since it's expected in certain scenarios
            }
            catch (WebSocketException ex)
            {
                ErrorOccurred?.Invoke(ex, nameof(DisconnectAsync));
            }
        }
    }
    private async Task CleanupWebSocket()
    {
        try
        {
            if (_webSocket.State == WebSocketState.Open)
            {
                await _webSocket.CloseAsync(WebSocketCloseStatus.NormalClosure, "Cleaning up", CancellationToken.None);
            }
        }
        catch
        {
            // Ignore exceptions during cleanup
        }
        finally
        {
            _webSocket.Dispose();
            _webSocket = new ClientWebSocket();
        }
    }

    public void Dispose()
    {
        _webSocket.Dispose();
    }
}
