using SensorStream.MAUI.Helpers;
using SensorStream.MAUI.Models;
using System.Net;
using System.Net.Sockets;
using System.Text;

namespace SensorStream.MAUI.Services;

public sealed class UdpService : IDisposable, IUdpService
{
    private UdpClient? _udpClient;
    private CancellationTokenSource? _cancellationTokenSource;
    private readonly IUiNotificationHelper _uiNotificationHelper;
    private static readonly string[] messageSeparator = new[] { ";;" };

    public event Action<BroadcastMessageModel>? MessageReceived;

    public UdpService(IUiNotificationHelper uiNotificationHelper)
    {
        _uiNotificationHelper = uiNotificationHelper;
    }

    public async Task StartListeningAsync(int port)
    {
        try
        {
            _udpClient = new UdpClient();
            _udpClient.Client.Bind(new IPEndPoint(IPAddress.Any, port));
            _cancellationTokenSource = new CancellationTokenSource();
            await Task.Run(() => ReceiveMessages(_cancellationTokenSource.Token), _cancellationTokenSource.Token);
        }
        catch(Exception ex)
        {
            await _uiNotificationHelper.DisplayAlertAsync("Error listening to UDP broadcast", ex.Message);
        }
    }

    public void StopListening()
    {
        _cancellationTokenSource?.Cancel();
        _udpClient?.Close();

        Dispose();
    }

    private async Task ReceiveMessages(CancellationToken cancellationToken)
    {
        try
        {
            while (!cancellationToken.IsCancellationRequested)
            {
                var result = await _udpClient!.ReceiveAsync(cancellationToken);
                string message = Encoding.ASCII.GetString(result.Buffer);
                var serverIP = result.RemoteEndPoint.Address.ToString();
                var broadcastMessage = ParseMessage(message, serverIP);
                if (broadcastMessage != null)
                {
                    MessageReceived?.Invoke(broadcastMessage);
                }
            }
        }
        catch (OperationCanceledException) { } // Expected exception
        catch (Exception ex)
        {
            await _uiNotificationHelper.DisplayAlertAsync("Error", ex.Message);
        }
    }
    /// <summary>
    /// Returns a BroadcastMessage if the message is in the correct format else returns null. 
    /// Message must be in format [Name];;[Port]
    /// </summary>
    private static BroadcastMessageModel? ParseMessage(string message, string ip)
    {
        var parts = message.Split(messageSeparator, StringSplitOptions.None);
        if (parts.Length == 2 && int.TryParse(parts[1], out var port))
        {
            return new BroadcastMessageModel(parts[0], ip, port);
        }
        return null;
    }

    public void Dispose()
    {
        _cancellationTokenSource?.Dispose();
        _udpClient?.Dispose();
    }
}
