extends Node

signal action_choosen
signal action_applied
signal done

@export var player: Resource
@export var enemy: Resource

@onready var info_box_ = get_node("info")
@onready var action_menu_ = find_child("action_menu")
@onready var items_ = find_child("items")
@onready var fight_ = find_child("fight_menu")
@onready var pokemon_ = find_child("pokemon_list")
@onready var yes_no_menu_ = find_child("yes_no_menu")
@onready var player_graphics_ = find_child("player")
@onready var enemy_graphics_ = find_child("enemy")

var menu_stack_ := []

func _ready():
		action_menu_.set_process_input(false)
		action_menu_.connect("activated", func(idx):
			match idx:
				0:
					push_menu_(fight_)
				1:
					push_menu_(items_)
				2:
					_on_run()
				3:
					push_menu_(pokemon_)
					pokemon_.info.set_text("Bring out which HATeMON?")
		)
		fight_.connect("activated", func(attack_idx):
			_on_attack_activated(attack_idx)
		)
		fight_.set_process_input(false)
		# Items Menu
		items_.connect("activated", func(item_idx):
			_on_item_activated(item_idx)
		)
		items_.set_process_input(false)
		# Pokemon Menu
		pokemon_.pokemon = player.pokemon
		pokemon_.set_process_input(false)
		pokemon_.connect("activated", func(pokemon_idx):
			_on_pokemon_select_activated(pokemon_idx)
			)
		# Yes/No Menu
		yes_no_menu_.set_process_input(false)
		yes_no_menu_.connect("activated", func(yes_no_idx):
			_on_yes_no_activated(yes_no_idx)
		)
		
		game_()

class Action:
	enum Type {
		item,
		attack,
		swap,
		cancel,
		run
	}
	
	func _init(type:int, idx:int) -> void:
		self.type = type
		self.idx = idx

	var type:int = Type.cancel
	var idx := 0

func push_menu_(menu) -> void:
	if not menu_stack_.is_empty():
		menu_stack_.back().visible = false
		menu_stack_.back().set_process_input(false)

	if menu_stack_.size() > 0:
		menu.connect("cancel", Callable(self, "pop_menu_").bind())

	menu_stack_.push_back(menu)
	menu.visible = true
	menu.set_process_input(true)

func pop_menu_() -> void:
	if menu_stack_.is_empty():
		return

	var popped_menu = menu_stack_.pop_back()
	popped_menu.visible = false
	popped_menu.set_process_input(false)
	if popped_menu.is_connected("cancel", Callable(self, "pop_menu_")):
		popped_menu.disconnect("cancel", Callable(self, "pop_menu_"))

	if menu_stack_.is_empty():
		return
	
	menu_stack_.back().set_process_input(true)
	menu_stack_.back().visible = true

func _on_run() -> void:
	emit_signal("action_choosen", Action.new(Action.Type.run, 0))

func _on_item_activated(item_idx:int) -> void:
	pop_menu_()

func _on_attack_activated(attack_idx:int) -> void:
	pop_menu_()
	pop_menu_()
	emit_signal("action_choosen", Action.new(Action.Type.attack, attack_idx))
	
func _on_pokemon_select_activated(pokemon_idx:int) -> void:
	pop_menu_()
	pop_menu_()
	emit_signal("action_choosen", Action.new(Action.Type.swap, pokemon_idx))

func _on_yes_no_activated(yes_no_idx:int) -> void:
	if yes_no_idx == 0:
		push_menu_(pokemon_)
	else:
		emit_signal("action_choosen", Action.new(Action.Type.cancel, 0))

func damage_(attacker, defender, move:MoveModel) -> float:
	var t1 = ((2.0 * attacker.level / 5.0) + 2.0)
	var t2 = (attacker.attack / defender.defense)
	var d =  ((t1 * move.power * t2) / 50.0) + 2.0
	return d

func get_next_player_move_():
	action_menu_.select_(0)
	push_menu_(action_menu_)
	return self

func get_next_enemy_move_() -> int:
	return int(round(randf_range(0, enemy.active_pokemon.moves.size() - 1)))

func apply_player_swap_pokemon_(pokemon_idx:int) -> void:
	apply_swap_pokemon_(player, pokemon_idx, get_node("player"))

func apply_enemy_swap_pokemon_(pokemon_idx:int) -> void:
	apply_swap_pokemon_(enemy, pokemon_idx, get_node("enemy"))

func invalidate_attack_menu_(pokemon) -> void:
	fight_.clear()

	for move in pokemon.moves:
		fight_.add_text_menu_item(move.name)

func apply_swap_pokemon_(trainer:TrainerModel, pokemon_idx:int, graphics:Node) -> void:
	if trainer.pokemon.size() <= pokemon_idx:
		return

	var pokemon:PokemonModel = trainer.pokemon[pokemon_idx]

	if trainer.active_pokemon:
		if trainer.active_pokemon.hp > 0:
			await info_box_.set_text("Enough! Come back!").done
			graphics.stats.visible = false
			await graphics.pokemon.withdraw().done
			graphics.pokemon.queue_free()

	graphics.trainer.exit($tween)
	await $tween.block().done

	var go_text = "Go! %s!" % pokemon.name
	if not trainer.is_player:
		go_text = "%s sent out %s." % [trainer.name, pokemon.name]

	await info_box_.set_text(go_text).done
	graphics.stats.visible = true

	graphics.pokemon = pokemon.battle_graphics

	if trainer.is_player:
		graphics.pokemon.show_back()
	else:
		graphics.pokemon.show_front()

	trainer.active_pokemon = pokemon
	graphics.find_child("stats").set_from_pokemon(pokemon)
	
	if trainer.is_player:
		invalidate_attack_menu_(pokemon)
	
	await graphics.pokemon.enter().done

	info_box_.clear_text()

	emit_signal("action_applied")

func apply_player_attack_(move_idx:int) -> void:
	apply_attack_(player.active_pokemon, enemy.active_pokemon, get_node("player"), get_node("enemy"), move_idx)

func apply_enemy_attack_(move_idx:int) -> void:

	apply_attack_(enemy.active_pokemon, player.active_pokemon, get_node("enemy"), get_node("player"), move_idx)
func apply_attack_(attacking_pokemon:PokemonModel, defending_pokemon:PokemonModel, attacking_graphics:Node, defending_graphics:Node, move_idx:int) -> void:
	if attacking_pokemon.moves.size() <= move_idx:
		return

	var move:MoveModel = attacking_pokemon.moves[move_idx]

	var e := "Enemy " if attacking_pokemon == enemy.active_pokemon else ""

	await info_box_.set_text("%s%s used %s!" % [e, attacking_pokemon.name, move.name]).done
	if move.fx:
		var fx = move.fx.instantiate()
		fx.defender_graphics = defending_graphics.find_child("pokemon")
		fx.attacker_graphics = attacking_graphics.find_child("pokemon")
		fx.info_box = info_box_
		add_child(fx)
		await fx.play().done
		fx.queue_free()
	
	var damage = damage_(attacking_pokemon, defending_pokemon, move)
	var critical = 2.0 if randf() > 0.9 else 1.0
	
	defending_pokemon.hp -= damage * critical
	await defending_graphics.find_child("stats").animate_hp(defending_pokemon.hp).animate_hp_done

	if critical >= 2.0:
		await info_box_.set_text_for_confirm("Critical hit!").done

	info_box_.clear_text()
	emit_signal("action_applied")

func game_() -> void:
	player_graphics_.trainer.show_back()
	enemy_graphics_.trainer.show_front()
	player_graphics_.trainer.begin($tween)
	enemy_graphics_.trainer.begin($tween)
	await $tween.block().done
	
	var begin_battle = enemy.battle_begin
	for line in begin_battle.text.split("\n"):
		await info_box_.set_text_for_confirm(line).done

	await info_box_.set_text_for_confirm("%s wants to fight!" % enemy.name).done
	info_box_.clear_text()

	apply_enemy_swap_pokemon_(0)
	await self.action_applied
	
	apply_player_swap_pokemon_(0)
	await self.action_applied

	while true:
		var player_action = await get_next_player_move_().action_choosen
		var enemy_move = get_next_enemy_move_()
		
		pop_menu_()
		pop_menu_()
		
		match player_action.type:
			Action.Type.attack:
				apply_player_attack_(player_action.idx)
				await self.action_applied
			Action.Type.swap:
				apply_player_swap_pokemon_(player_action.idx)
				await self.action_applied
			Action.Type.run:
				await info_box_.set_text_for_confirm("You begin to run away...").done
				await info_box_.set_text_for_confirm("You ran in a circle by mistake.").done

		if enemy.active_pokemon.is_dead():
			enemy_graphics_.stats.visible = false
			await enemy_graphics_.get_pokemon().faint().done
			await info_box_.set_text_for_confirm("Enemy %s fainted!" % enemy.active_pokemon.name).done

			var last_level = player.active_pokemon.level
			player.active_pokemon.xp += enemy.active_pokemon.get_exp_if_beat()
			await info_box_.set_text_for_confirm("%s gained %d EXP." % [player.active_pokemon.name, enemy.active_pokemon.get_exp_if_beat()]).done
			
			if last_level != player.active_pokemon.level:
				player_graphics_.pokemon.level_up()
				player_graphics_.stats.set_from_pokemon(player.active_pokemon)
				await info_box_.set_text_for_confirm("%s leveled up!" % [player.active_pokemon.name]).done
				var move_to_learn = player.active_pokemon.moves_to_learn.get(player.active_pokemon.level)
				if move_to_learn:
					player_graphics_.pokemon.learn()
					await info_box_.set_text_for_confirm("%s learnt %s!" % [player.active_pokemon.name, move_to_learn.name]).done
					player.active_pokemon.moves.push_back(move_to_learn)
					invalidate_attack_menu_(player.active_pokemon)

			if enemy.is_dead():
				await info_box_.set_text_for_confirm("%s is defeated!" % enemy.name).done
				break

			var next_enemy_pokemon_idx = enemy.pokemon.find(enemy.active_pokemon) + 1
			var next_enemy_pokemon = enemy.pokemon[next_enemy_pokemon_idx]
			await info_box_.set_text("%s is about to use %s." % [enemy.name, next_enemy_pokemon.name]).done
			await info_box_.set_text("Will %s change HATeMON?" % [player.name], 0.0).done

			push_menu_(yes_no_menu_)
			var action:Action = await self.action_choosen
			info_box_.clear_text()
			if action.type == Action.Type.swap:
				apply_player_swap_pokemon_(action.idx)
				await self.action_applied
			
			pop_menu_()

			apply_enemy_swap_pokemon_(next_enemy_pokemon_idx)
			await self.action_applied
			continue
			
		apply_enemy_attack_(enemy_move)
		await self.action_applied
		
		if player.active_pokemon.hp <= 0:
			await info_box_.set_text("%s fainted." % player.active_pokemon.name).done
			player_graphics_.stats.visible = false
			await player_graphics_.pokemon.faint().done
			
			if player.is_dead():
				await info_box_.set_text("You are out of pokemon. You loose").done
				break
			else:
				push_menu_(pokemon_)
				pokemon_.info.set_text("Bring out which POKeMON?")
				info_box_.clear_text()
				var action:Action = await self.action_choosen
				apply_player_swap_pokemon_(action.idx)
				await self.action_applied

	if enemy.is_dead():
		player_graphics_.stats.visible = false
		enemy_graphics_.trainer.enter($tween)
		await $tween.block().done
		
		var battle_loose = enemy.battle_loose
		for line in battle_loose.text.split("\n"):
			await info_box_.set_text_for_confirm(line).done


	enemy.active_pokemon = null
	player.active_pokemon = null

	emit_signal("done")
