using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using SensorStream.MAUI.Helpers;
using SensorStream.MAUI.Models;
using SensorStream.MAUI.Services;
using System.Collections.ObjectModel;

namespace SensorStream.MAUI.ViewModels;

public sealed partial class MainViewModel: ObservableObject, IDisposable
{
    const int UDP_BROADCAST_PORT = 9752;

    private readonly IConnectivity _connectivity;
    private readonly IUdpService _udpService;
    private readonly IUiNotificationHelper _uiNotificationHelper;
    public MainViewModel(IConnectivity connectivity, IUdpService udpService, IUiNotificationHelper uiNotificationHelper)
    {
        _connectivity = connectivity;
        _udpService = udpService;
        _uiNotificationHelper = uiNotificationHelper;

        _udpService.MessageReceived += OnMessageReceived;
    }

    [ObservableProperty]
    ObservableCollection<BroadcastMessageModel> broadcastMessages = new();
    [ObservableProperty]
    string username = Preferences.Default.Get("username", "");

    [ObservableProperty]
    [NotifyPropertyChangedFor(nameof(IsSearchStopped))]
    bool isSearchRunning = false;

    public bool IsSearchStopped => !IsSearchRunning;
    [RelayCommand]
    async Task SearchHost()
    {
        if(_connectivity.NetworkAccess != NetworkAccess.Internet)
        {
            await _uiNotificationHelper.DisplayToastAsync("Please connect to a network first");
            return;
        }
        if (string.IsNullOrEmpty(Username))
        {
            await _uiNotificationHelper.DisplayToastAsync("Please enter a username first");
            return;
        }

        IsSearchRunning = true;
        await _udpService.StartListeningAsync(UDP_BROADCAST_PORT);

        Preferences.Default.Set("username", Username);
    }
    [RelayCommand]
    void StopSearch()
    {
        IsSearchRunning = false;
        _udpService.StopListening();
    }
    [RelayCommand]
    async Task SelectServer(BroadcastMessageModel selectedServer)
    {
        if (string.IsNullOrEmpty(Username))
        {
            await _uiNotificationHelper.DisplayToastAsync("Please enter a username first");
            return;
        }
        await Shell.Current.GoToAsync(nameof(LobbyPage),
            new Dictionary<string, object>
            {
                {"LobbyParams", new LobbyParams(selectedServer, Username) }
            });
    }
    public void Dispose()
    {
        _udpService.MessageReceived -= OnMessageReceived;
        _udpService.Dispose();
    }
    private void OnMessageReceived(BroadcastMessageModel message)
    {
        if (!BroadcastMessages.Contains(message))
        {
            MainThread.BeginInvokeOnMainThread(() =>
            {
                BroadcastMessages.Add(message);
            });
        }
    }
}
