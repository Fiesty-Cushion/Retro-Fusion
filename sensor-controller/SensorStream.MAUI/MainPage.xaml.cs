using SensorStream.MAUI.ViewModels;

namespace SensorStream.MAUI;

public partial class MainPage : ContentPage
{
	public MainPage(MainViewModel mainViewModel)
	{
		InitializeComponent();
		BindingContext = mainViewModel;
	}
}