extends Resource
class_name PokemonModel

# Signals
signal name_changed(old, new)
signal level_changed(old, new)
signal hp_changed(old, new)
signal max_hp_changed(old, new)
signal xp_changed(old, new)

# Experience table (example)
const EXP_TABLE_FAST := [100, 51, 21, 6, 0]

# Exported variables with setters/getters
@export var name: String:
	set(value):
		var old = name
		name = value
		_emit_prop_change("name", old, value)
	get:
		return name

@export var hp: int:
	set(value):
		var old = hp
		hp = max(0, value)
		_emit_prop_change("hp", old, hp)
	get:
		return hp

@export var max_hp: int:
	set(value):
		var old = max_hp
		max_hp = value
		_emit_prop_change("max_hp", old, max_hp)
	get:
		return max_hp

@export var xp: int = 1:
	set(value):
		var old = xp
		xp = value
		_emit_prop_change("xp", old, xp)
	get:
		return xp

@export var exp_stat: int = 1
@export var attack: int = 1
@export var defense: int = 1
@export var speed: int = 1
@export var wild: bool = false
@export var moves: Array[Resource] = []
@export var moves_to_learn: Dictionary = {}
@export var battle_graphics: PackedScene

# Level is derived from XP and cannot be set directly
@export var level: int:
	get:
		return get_level()
	set(value):
		pass # Level is calculated from XP

# Helper function for property change signals
func _emit_prop_change(property: String, old, new) -> void:
	emit_signal(property + "_changed", old, new)
	emit_signal("changed")

# Utility functions
func is_dead() -> bool:
	return hp <= 0

func get_exp_if_beat() -> float:
	return float(get_level()) * float(exp_stat) * (1.0 if wild else 1.5)

func get_level() -> int:
	for i in EXP_TABLE_FAST.size():
		if xp >= EXP_TABLE_FAST[i]:
			return EXP_TABLE_FAST.size() - i
	return 1
