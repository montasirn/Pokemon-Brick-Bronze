extends Control
class_name Menu

signal activated(idx: int)
signal cancel

@export var menu_items: Array[NodePath] = []

var idx_: int = 0
var activate_sound_: AudioStreamPlayer
var select_sound_: AudioStreamPlayer
var cancel_sound_: AudioStreamPlayer
var input_: bool = false

func add_text_menu_item(text: String) -> void:
	var menu_item = preload("res://widgets/menu_button.tscn").instantiate()
	menu_item.capitalize = true
	menu_item.text = text
	add_menu_item(menu_item)

func add_menu_item(menu_item: Node) -> void:
	$col_1.add_child(menu_item) # Use $ shortcut for find_child("col_1")
	menu_items.append(menu_item.get_path()) # push_back -> append

	if menu_items.size() == 1:
		select_(0, true)

func clear() -> void:
	for node_path in menu_items:
		var node = get_node(node_path)
		if node:
			node.queue_free()
	menu_items.clear()

func _ready() -> void:
	activate_sound_ = AudioStreamPlayer.new()
	add_child(activate_sound_)
	
	select_sound_ = AudioStreamPlayer.new()
	add_child(select_sound_)
	
	cancel_sound_ = AudioStreamPlayer.new()
	add_child(cancel_sound_)


func _unhandled_input(event: InputEvent) -> void:
	input_ = true

	if event.is_action_pressed("ui_up"):
		up_()
	elif event.is_action_pressed("ui_down"):
		down_()
	elif event.is_action_pressed("ui_select"):
		activate_()
	elif event.is_action_pressed("ui_cancel"):
		cancel_sound_.play()
		emit_signal("cancel")

	input_ = false

func up_() -> void:
	if menu_items.is_empty():
		return
	select_((idx_ - 1) % menu_items.size())

func down_() -> void:
	if menu_items.is_empty():
		return
	select_((idx_ + 1) % menu_items.size())

func select_(idx: int, force: bool = false, sound: bool = input_) -> void:
	if idx_ == idx and not force:
		return

	var node = get_node(menu_items[idx])
	if node.has_method("is_off") and node.is_off():
		for i in menu_items.size():
			var ii = (idx + i + 1) % menu_items.size()
			var next_node = get_node(menu_items[ii])
			if not (next_node.has_method("is_off") and next_node.is_off()):
				select_(ii, force)
				return
		return

	if menu_items.size() > idx_:
		var prev_node = get_node(menu_items[idx_])
		if prev_node:
			prev_node.selected = false

	idx_ = idx
	var curr_node = get_node(menu_items[idx_])
	if curr_node:
		curr_node.selected = true

	if sound:
		select_sound_.play()

func activate_() -> void:
	activate_sound_.play()
	emit_signal("activated", idx_)
