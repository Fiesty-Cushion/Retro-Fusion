
namespace SensorStream.MAUI.Helpers
{
    public interface IUiNotificationHelper
    {
        Task DisplayAlertAsync(string title, string message, string cancel = "OK");
        Task DisplayToastAsync(string message, double fontSize = 14 );
    }
}