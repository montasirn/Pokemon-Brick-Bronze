extends Control

@onready var info = $info

@export var pokemon = []

func set_pokemon(value) -> void:
	pokemon = value
	invalidate_()

func get_pokemon():
	return pokemon

func invalidate_() -> void:
	clear()
	for p in pokemon:
		var menu_item = preload("res://widgets/menu_button.tscn").instantiate()
		var mini_pokemon_info = preload("res://widgets/pokemon_info_mini.tscn").instantiate()
		mini_pokemon_info.set_from_pokemon(p)
		menu_item.add_child(mini_pokemon_info)
		menu_item.off = p.hp <= 0
		add_menu_item(menu_item)
	for i in pokemon.size():
		if pokemon[i].hp > 0:
			select_(i, true)
			break

func clear():
	for child in get_children():
		remove_child(child)
		child.queue_free()

func add_menu_item(item):
	add_child(item)  # Or add to a specific container

func select_(index, value):
	# Implement your selection logic here
	pass

func _on_visibility_changed():
	if visible:
		invalidate_()
