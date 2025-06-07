extends Node2D
class_name TrainerGraphic

@onready var front_position_: Vector2 = $front.position
@onready var back_position_: Vector2 = $back.position

func begin() -> void:
	$front.position.x = -40
	$back.position.x = 180
	var tween = create_tween().set_parallel(true)
	tween.tween_property($front, "position:x", front_position_.x, 1.0)
	tween.tween_property($back, "position:x", back_position_.x, 1.0)
	if $front.visible:
		tween.tween_property($enter, "playing", true, 1.0)
	# Fade out and in for front
	tween.tween_property($front, "modulate:a", 0.0, 1.0)
	tween.tween_property($front, "modulate:a", 1.0, 1.2)
	# Fade out and in for back
	tween.tween_property($back, "modulate:a", 0.0, 1.0)
	tween.tween_property($back, "modulate:a", 1.0, 1.2)

func exit() -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property($front, "position:x", 200, 0.2)
	tween.tween_property($back, "position:x", -50, 0.2)

func enter() -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property($front, "position:x", front_position_.x, 0.2)
	tween.tween_property($back, "position:x", back_position_.x, 0.2)

func show_back() -> void:
	$front.visible = false
	$back.visible = true

func show_front() -> void:
	$front.visible = true
	$back.visible = false
	
func replace_child_with_scene(scene: PackedScene) -> Node:
	var new_child = scene.instantiate()
	return new_child
