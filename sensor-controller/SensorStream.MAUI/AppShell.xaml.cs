namespace SensorStream.MAUI
{
    public partial class AppShell : Shell
    {
        public AppShell()
        {
            InitializeComponent();
            Routing.RegisterRoute(nameof(LobbyPage), typeof(LobbyPage));
        }
    }
}
