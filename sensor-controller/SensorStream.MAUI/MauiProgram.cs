using CommunityToolkit.Maui;
using Microsoft.Extensions.Logging;
using SensorStream.MAUI.Helpers;
using SensorStream.MAUI.Services;
using SensorStream.MAUI.ViewModels;

namespace SensorStream.MAUI
{
    public static class MauiProgram
    {
        public static MauiApp CreateMauiApp()
        {
            var builder = MauiApp.CreateBuilder();
            builder
                .UseMauiApp<App>()
                .UseMauiCommunityToolkit()
                .ConfigureFonts(fonts =>
                {
                    fonts.AddFont("OpenSans-Regular.ttf", "OpenSansRegular");
                    fonts.AddFont("OpenSans-Semibold.ttf", "OpenSansSemibold");
                });

            builder.Services.AddSingleton<IConnectivity>(Connectivity.Current);
            builder.Services.AddSingleton<IVibration>(Vibration.Default);
            builder.Services.AddSingleton<IUiNotificationHelper, UINotificationHelper>();
            builder.Services.AddSingleton<IWebSocketService, WebSocketService>();
            builder.Services.AddSingleton<ISensorService, SensorService>();

            builder.Services.AddTransient<IUdpService, UdpService>();

            builder.Services.AddSingleton<MainPage>();
            builder.Services.AddSingleton<MainViewModel>();

            builder.Services.AddTransient<LobbyPage>();
            builder.Services.AddTransient<LobbyViewModel>();

#if DEBUG
    		builder.Logging.AddDebug();
#endif

            return builder.Build();
        }
    }
}
