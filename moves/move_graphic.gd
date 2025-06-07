extends Node2D
class_name MoveGraphic

signal done

var defender_graphics:Node2D
var attacker_graphics:Node2D
var info_box:Node
var tween_

var delta_sum_ := 0.0

func _play() -> void:
	pass

func play() -> Node:
	_play()
	return self

func play_audio_(node:AudioStreamPlayer, delay := 0.0) -> void:
	tween_.step_property(node, "playing", false, true, delay)

func wait_(delay:float) -> void:
	tween_.wait(delay)

func _ready():
	tween_
	add_child(tween_)

func _process(delta) -> void:
	delta_sum_ += delta
