namespace Game.Core
{
	#region Debugging
	public enum LogLevel
	{
		DEBUG,
		INFO,
		WARNING,
		ERROR,
	}
	#endregion

	#region Characters
	public enum ECharacterAnimation
	{
		idle_down,
		idle_up,
		idle_left,
		idle_right,
		turn_down,
		turn_up,
		turn_left,
		turn_right,
		walk_down,
		walk_up,
		walk_left,
		walk_right,
	}
	#endregion

	#region levels
	public enum LevelName
	{
		pallet_town,
		pallet_town_professor,
		pallet_town_player_house_1F,
		pallet_town_player_house_2F,
		pallet_town_route1,
	}

	public enum LevelGroup
	{
		SPAWNPOINTS,
		SCENETRIGGERS,
	}
	#endregion
}
