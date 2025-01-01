using SensorStream.MAUI.ViewModels;

namespace SensorStream.MAUI;

public partial class LobbyPage : ContentPage
{
	public LobbyPage(LobbyViewModel lobbyViewModel)
	{
		InitializeComponent();
		BindingContext = lobbyViewModel;
        Shell.SetNavBarIsVisible(this, false);
    }
    protected override bool OnBackButtonPressed()
    {
        ShowExitConfirmation();
        return true; // Prevent default back button behavior
    }

    private async void ShowExitConfirmation()
    {
        bool confirm = await DisplayAlert("Confirm Exit", "Are you sure you want to exit? This will disconnect you from the server.", "Yes", "No");
        if (confirm)
        {
            var viewModel = BindingContext as LobbyViewModel;
            if (viewModel != null)
            {
                await viewModel.TerminateConnection();
            }
            await Shell.Current.GoToAsync("..");
        }
    }
}