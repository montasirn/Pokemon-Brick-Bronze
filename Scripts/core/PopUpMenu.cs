using Godot;
using System;
using System.Runtime.CompilerServices;

public partial class PopUpMenu : MarginContainer
{

	[ExportCategory("Menu")]
	[Export] public MarginContainer menu;

	[Export] public VBoxContainer buttons;
	public static void toggleVisibility(MarginContainer v)
	{
		v.Visible = !v.Visible;
	}

	public override void _Input(InputEvent @event)
	{
		menu.ProcessMode = Node.ProcessModeEnum.Always; 

		if (@event is InputEventKey keyEvent && keyEvent.Pressed)
		{
			if (keyEvent.Keycode == Key.X)
			{
				toggleVisibility(menu);
				GetTree().Paused = menu.Visible;
			}
		}

		if (@event is InputEventMouseButton mouseEvent && mouseEvent.Pressed && mouseEvent.ButtonIndex == MouseButton.Left)
		{
			var buttonRect = buttons.GetGlobalRect();
			if (buttonRect.HasPoint(mouseEvent.Position))
			{
				toggleVisibility(menu);
				GetTree().Paused = menu.Visible;
			}
		}
	}

	private void OnButtonPressed()
	{
		toggleVisibility(menu);
	}

}
