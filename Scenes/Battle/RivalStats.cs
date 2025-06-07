using Godot;

public partial class PokemonStatus : Node
{
	[Signal]
	public delegate void AnimateHpDoneEventHandler();

	[Export(PropertyHint.None, "Pokemon Name")]
	private string _text = "";
	[Export]
	private int _level = 1;
	[Export]
	private int _hp = 1;
	[Export]
	private int _maxHp = 1;

	public string Text
	{
		get => _text;
		set => SetText(value);
	}
	public int Level
	{
		get => _level;
		set => SetLevel(value);
	}
	public int Hp
	{
		get => _hp;
		set => SetHp(value);
	}
	public int MaxHp
	{
		get => _maxHp;
		set => SetMaxHp(value);
	}

	private Label nameLabel;
	private Label levelLabel;
	private Label hpLabel;
	private ProgressBar hpBar;
	private Tween tween;

	public override void _Ready()
	{
		nameLabel = GetNode<Label>("name");
		levelLabel = GetNode<Label>("level");
		hpLabel = GetNode<Label>("hp_bar/hp");
		hpBar = GetNode<ProgressBar>("hp_bar/bar/line");
		tween = GetNode<Tween>("tween");
	}

	// public void SetFromPokemon(Resource pokemon)
	// {
	//     SetText(pokemon.Name);
	//     SetLevel(pokemon.Level);
	//     SetMaxHp(pokemon.MaxHp);
	//     SetHp(pokemon.Hp);
	// }

	public void SetText(string value)
	{
		_text = value;
		nameLabel.Text = value.ToUpper();
	}

	public void SetLevel(int value)
	{
		_level = value;
		levelLabel.Text = value.ToString();
	}

	public void SetHp(int value)
	{
		if (_maxHp <= 0)
			return;
		_hp = value;
		hpLabel.Text = $"{_hp} / {_maxHp}";
		hpBar.MinValue = 0;
		hpBar.MaxValue = _maxHp;
		hpBar.Value = _hp;
	}

	public void SetMaxHp(int value)
	{
		_maxHp = value;
		SetHp(_hp);
	}

	public Node AnimateHp(int value)
	{
		tween.Kill();
		tween.TweenProperty(this, "Hp", value, 1.0f);
		tween.Finished += () => EmitSignal(SignalName.AnimateHpDone);
		tween.Play();
		return this;
	}
}
