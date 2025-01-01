using CommunityToolkit.Maui.Alerts;
using CommunityToolkit.Maui.Core;

namespace SensorStream.MAUI.Helpers
{
    public class UINotificationHelper : IUiNotificationHelper
    {
        public async Task DisplayAlertAsync(string title, string message, string cancel = "OK")
        {
            await Shell.Current.DisplayAlert(title, message, cancel);
        }
        public async Task DisplayToastAsync(string message, double fontSize = 14)
        {
            var toast = Toast.Make(message, ToastDuration.Short, fontSize);
            await toast.Show();
        }
    }
}
