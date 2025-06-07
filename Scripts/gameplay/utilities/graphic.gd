extends Marker2D

@onready var stats = find_child("stats")
@onready var trainer = find_child("trainer"): get = get_trainer, set = set_trainer
var pokemon : get = get_pokemon, set = set_pokemon

func set_pokemon(value):
	if get_pokemon():
		get_pokemon().free()
	find_child("pokemon").add_child(value.instantiate())

func get_pokemon() -> Node:
	if find_child("pokemon").get_child_count() > 0:
		return find_child("pokemon").get_child(0)
	return null

func set_trainer(value):
	trainer = value

func get_trainer():
	return get_node_or_null("trainer")
