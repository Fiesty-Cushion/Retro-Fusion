using SensorStream.MAUI.Models;

namespace SensorStream.MAUI.Services
{
    public interface IUdpService
    {
        event Action<BroadcastMessageModel> MessageReceived;

        void Dispose();
        Task StartListeningAsync(int port);
        void StopListening();
    }
}