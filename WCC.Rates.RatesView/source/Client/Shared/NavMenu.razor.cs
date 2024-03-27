using Microsoft.FluentUI.AspNetCore.Components;

namespace WCC.Rates.RatesView.Client.Shared;
public partial class NavMenu
{
	private string searchValue;

	public OfficeColor? OfficeColor { get; set; }

	public DesignThemeModes Mode { get; set; }

	protected override void OnInitialized()
	{
		Console.WriteLine("NavMenu.OnInitialized");
	}
	private void Search()
	{
		navManager.NavigateTo($"CustomerSearch/{searchValue}", true);
	}

	void OnLoaded(LoadedEventArgs e)
	{
		//  DemoLogger.WriteLine($"Loaded: {(e.Mode == DesignThemeModes.System ? "System" : "")} {(e.IsDark ? "Dark" : "Light")}");
	}

	void OnLuminanceChanged(LuminanceChangedEventArgs e)
	{

	}

}
