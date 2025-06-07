extends Node2D


var tween_
var tween__

func _ready() -> void:
	# Start the front/back wiggle loop
	$front.rotation_degrees = 5
	_start_front_wiggle()

func _start_front_wiggle():
	# Use SceneTreeTween for looping wiggle
	if tween__:
		tween__.kill()
	tween__ = create_tween()
	tween__.set_loops() # Infinite loop
	tween__.tween_property($front, "rotation_degrees", -5, 1.0).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween__.tween_property($front, "rotation_degrees", 5, 1.0).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

func show_back():
	$front.visible = false
	$back.visible = true

func show_front():
	$front.visible = true
	$back.visible = false

func faint():
	$faint.play()
	if tween_:
		tween_.kill()
	tween_ = create_tween()
	tween_.tween_property(self, "position:y", 200, 0.5).set_trans(Tween.TRANS_QUAD)
	await tween_.finished

func level_up():
	$level_up.play()

func learn():
	$learn.play()

func enter():
	$enter.pitch_scale = 1.0 + randf_range(-0.3, 0.9)
	$enter.play()
	if tween_:
		tween_.kill()
	scale = Vector2.ZERO
	tween_ = create_tween()
	tween_.tween_property(self, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_QUAD)
	await tween_.finished

func withdraw():
	if tween_:
		tween_.kill()
	tween_ = create_tween()
	tween_.tween_property(self, "scale", Vector2.ZERO, 0.5).set_trans(Tween.TRANS_QUAD)
	await tween_.finished
