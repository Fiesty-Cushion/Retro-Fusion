using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using SensorStream.MAUI.Helpers;
using SensorStream.MAUI.Models;
using SensorStream.MAUI.Services;
using System.Numerics;
using System.Text.Json;

namespace SensorStream.MAUI.ViewModels;
[QueryProperty("LobbyParams", "LobbyParams")]
public sealed partial class LobbyViewModel : ObservableObject
{
    [ObservableProperty]
    LobbyParams lobbyParams;
    [ObservableProperty]
    string socketId = string.Empty;

    [ObservableProperty]
    Vector3 accelerometerData = new();
    [ObservableProperty]
    Vector3 gyroscopeData = new();
    [ObservableProperty]
    Quaternion orientationData = new();

    [ObservableProperty]
    [NotifyPropertyChangedFor(nameof(ShowStartButton))]
    [NotifyPropertyChangedFor(nameof(ShowSendingButton))]
    [NotifyPropertyChangedFor(nameof(ShowConnectingButton))]
    bool isSendingSensorData = false;
    [ObservableProperty]
    [NotifyPropertyChangedFor(nameof(ShowStartButton))]
    [NotifyPropertyChangedFor(nameof(ShowSendingButton))]
    [NotifyPropertyChangedFor(nameof(ShowConnectingButton))]
    bool isConnected = false;

    public bool ShowStartButton => IsConnected && !IsSendingSensorData;
    public bool ShowSendingButton => IsConnected && IsSendingSensorData;
    public bool ShowConnectingButton => !IsConnected;

    private readonly IWebSocketService _webSocketService;
    private readonly IUiNotificationHelper _uiNotificationHelper;
    private readonly IVibration _vibration;
    private readonly ISensorService _sensorService;

    private readonly Timer _sensorUIUpdateTimer;
    private readonly Timer _sensorDataSendTimer;
    private const int SensorRefreshIntervalMs = 20;

    private readonly CancellationTokenSource _cancellationTokenSource;
    public LobbyViewModel(IWebSocketService webSocketService, ISensorService sensorService, IUiNotificationHelper uiNotificationHelper, IVibration vibration)
    {
        _webSocketService = webSocketService;
        _uiNotificationHelper = uiNotificationHelper;
        _vibration = vibration;
        _sensorService = sensorService;

        _cancellationTokenSource = new CancellationTokenSource();

        _sensorService.StartIfNotStarted();
        _sensorDataSendTimer = new Timer(async _ =>
        {
            await SendSensorDataAsync();
        }, null, Timeout.Infinite, Timeout.Infinite);
        _sensorUIUpdateTimer = new Timer(_ =>
        {
            AccelerometerData = _sensorService.AccelerometerData;
            GyroscopeData = _sensorService.GyroscopeData;
            OrientationData = _sensorService.OrientationData;
        }, null, 0, SensorRefreshIntervalMs);
    }
    [RelayCommand]
    public void Start()
    {
        _sensorDataSendTimer.Change(0, SensorRefreshIntervalMs); // Starts sending data every interval
        IsSendingSensorData = true;
    }
    partial void OnLobbyParamsChanged(LobbyParams value)
    {
        if (value.Server is null || string.IsNullOrWhiteSpace(value.Username))
        {
            Shell.Current.DisplayAlert("Missing server or username", "Server or username is empty.", "OK");
            Shell.Current.GoToAsync("..");
            return;
        }
        var serverUri = new Uri($"ws://{value.Server.IP}:{value.Server.WS_Port}?username={value.Username}");

        _webSocketService.MessageReceived += OnMessageReceived;
        _webSocketService.ErrorOccurred += async (e, n)=> await OnSocketErrorOccurredAsync(e, n);
        _webSocketService.ServerConnected += async () =>
        {
            IsConnected = true;
            await _uiNotificationHelper.DisplayToastAsync("Connected to server");
        };

        _webSocketService.ConnectAsync(serverUri, _cancellationTokenSource.Token);
    }

    private void OnMessageReceived(string message)
    {
        if(IsSendingSensorData && message == "striked_ball")
        {
            _vibration.Vibrate(TimeSpan.FromMilliseconds(60));
            return;
        }
        if (message.StartsWith("SocketId:"))
        {
            SocketId = message.Replace("SocketId:", "");
            return;
        }
    }

    private async Task OnSocketErrorOccurredAsync(Exception ex, string nameOfMethod)
    {
        await TerminateConnection();

        MainThread.BeginInvokeOnMainThread(async () =>
        {
            await Shell.Current.GoToAsync("..");
            await _uiNotificationHelper.DisplayToastAsync($"Socket.{nameOfMethod}: {ex.Message}");
        });
    }
    private async Task SendSensorDataAsync()
    {
        var sensorData = new
        {
            id = SocketId,
            acc = new
            {
                x = _sensorService.AccelerometerData.X,
                y = _sensorService.AccelerometerData.Y,
                z = _sensorService.AccelerometerData.Z
            },
            gyro = new
            {
                x = _sensorService.GyroscopeData.X,
                y = _sensorService.GyroscopeData.Y,
                z = _sensorService.GyroscopeData.Z
            },
            ori = new
            {
                x = _sensorService.OrientationData.X,
                y = _sensorService.OrientationData.Y,
                z = _sensorService.OrientationData.Z,
                w = _sensorService.OrientationData.W
            }
        };
        var json = JsonSerializer.Serialize(sensorData);
        await _webSocketService.SendAsync(json, _cancellationTokenSource.Token);
    }

    public async Task TerminateConnection()
    {
        _cancellationTokenSource.Cancel();
        _sensorDataSendTimer.Change(Timeout.Infinite, Timeout.Infinite); // Stop the timer
        _sensorUIUpdateTimer.Change(Timeout.Infinite, Timeout.Infinite); // Stop the timer
        _sensorService.StopIfStarted();
        if (_webSocketService != null)
        {
            await _webSocketService.DisconnectAsync();
        }
        IsConnected = false;
    }
}
