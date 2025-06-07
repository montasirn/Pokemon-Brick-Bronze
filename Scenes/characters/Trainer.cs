using Godot;

public partial class TrainerGraphic : Node2D
{
	[Export] public NodePath FrontPath;
	[Export] public NodePath BackPath;
	[Export] public NodePath EnterPath;

	private Node2D front;
	private Node2D back;
	private AnimationPlayer enter;

	private Vector2 frontPosition;
	private Vector2 backPosition;

	public override void _Ready()
	{
		front = GetNode<Node2D>(FrontPath);
		back = GetNode<Node2D>(BackPath);
		enter = GetNode<AnimationPlayer>(EnterPath);

		frontPosition = front.Position;
		backPosition = back.Position;
	}

	public void Begin(Tween tween)
	{
		// Move instantly to start positions
		front.Position = new Vector2(-40, front.Position.Y);
		back.Position = new Vector2(180, back.Position.Y);

		// Animate positions
		tween.TweenProperty(front, "position:x", frontPosition.X, 1.0f).From(-40);
		tween.TweenProperty(back, "position:x", backPosition.X, 1.0f).From(180);

		// Play animation if front is visible
		if (front.Visible)
		{
			tween.TweenCallback(Callable.From(() => enter.Play("playing")));
		}

		// Animate alpha (modulate.a)
		// Fade out and in for front
		tween.TweenProperty(front, "modulate:a", 0.0f, 1.0f).From(1.0f);
		tween.TweenProperty(front, "modulate:a", 1.0f, 1.2f).From(0.0f);

		// Fade out and in for back
		tween.TweenProperty(back, "modulate:a", 0.0f, 1.0f).From(1.0f);
		tween.TweenProperty(back, "modulate:a", 1.0f, 1.2f).From(0.0f);

		tween.Play();
	}

	public void Exit(Tween tween)
	{
		tween.TweenProperty(front, "position:x", 200.0f, 0.2f);
		tween.TweenProperty(back, "position:x", -50.0f, 0.2f);
		tween.Play();
	}

	public void Enter(Tween tween)
	{
		tween.TweenProperty(front, "position:x", frontPosition.X, 0.2f);
		tween.TweenProperty(back, "position:x", backPosition.X, 0.2f);
		tween.Play();
	}

	public void ShowBack()
	{
		front.Visible = false;
		back.Visible = true;
	}

	public void ShowFront()
	{
		front.Visible = true;
		back.Visible = false;
	}
}
