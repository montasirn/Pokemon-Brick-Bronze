using System.Threading;
using System.Timers;
using System;
using System.Threading.Tasks;
using Game.Core;
using Godot;

namespace Game.Gameplay
{
	public partial class SceneTrigger : Area2D
	{
		[ExportCategory("Target Scene Vars")]
		[Export]
		public LevelName TargetLevelName;

		[Export]
		public int TargetLevelTrigger = 0;

		[ExportCategory("Current Scene Vars")]
		[Export]
		public int CurrentLevelTrigger = 0;

		[Export]
		public Vector2 EntryDirection;

		[Export]
		public bool Locked = false;


		public override void _Ready()
		{
			BodyEntered += OnBodyEntered;
		}

		public async void OnBodyEntered(Node2D body)
		{
			if (SceneManager.IsChanging)
				return;

			if (body.Name != "Player")
				return;

			if (Locked)
				Logger.Info("Uh oh!  The door is locked ...");

			SceneManager.ChangeLevel(levelName: TargetLevelName, trigger: TargetLevelTrigger);

			
		}

		private async void DelayMethod()
		{
    	await Task.Delay(TimeSpan.FromMilliseconds(1000));
		}

		public override void _EnterTree()
		{
			AddToGroup(LevelGroup.SCENETRIGGERS.ToString());
		}

		public override void _ExitTree()
		{
			RemoveFromGroup(LevelGroup.SCENETRIGGERS.ToString());
		}
	}
}
