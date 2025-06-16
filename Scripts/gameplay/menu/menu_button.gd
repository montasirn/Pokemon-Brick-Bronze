@tool
extends HBoxContainer

@export var capitalize: bool: set = set_capitalize
@export var text: String: set = set_text
@export var selected: bool: set = set_selected
@export var off: bool

func set_text(value) -> void:
	text = str(value)
	if has_node("label"):
		$label.text = text.to_upper() if capitalize else text

func set_capitalize(value:bool) -> void:
	capitalize = value

func set_selected(value:bool) -> void:
	selected = value
	$pointer.modulate.a = 1.0 if selected else 0.0
