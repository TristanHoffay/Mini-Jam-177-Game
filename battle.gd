class_name Battle extends Node2D
@export var player_cards : Array[CardData]
@onready var camera_2d = $Camera2D
@onready var background = $Background
@export var padding: float = 300
@export var card_padding: float = 260
@onready var hand = $Hand
const CARD = preload("res://card.tscn")
@onready var end_battle_timer: Timer = $"End Battle"
var normal_cam : Camera2D
@onready var card_reveal_timer: Timer = $CardRevealTimer
@onready var dialog: Dialog = $Dialog
const BATTLE_ENEMY = preload("res://battle_enemy.tscn")
@onready var health_label = $"Health Particles/Health Label"
@onready var health_particles = $"Health Particles"
@onready var wait_timer = $"Wait Timer"
@onready var draw_area = $"Draw Area"


var player: Player
var enemies : Array[BattleEnemy]
var cards: Array[Card] = []
var card_to_use: int
var enemy_target: int
var damage_factor: float = 1
var defense_factor: float = 1
var anim_hurt:bool = false
var draw_card: Card
var player_invuln_turns = -1
var player_frozen_turns = -1
var player_poisoning = 0

# player does stuff on PLAYER_INPUT, their actions execute (show secondary effect, do card stuff) 
# on PLAYER_TURN, and enemy does stuff on ENEMY_TURN
enum State {PLAYER_INPUT, CHOOSE_ENEMY, PLAYER_TURN, ENEMY_TURN, PLAYER_DEAD}
var current_state = State.PLAYER_INPUT
func next_state():
	print("Changing state from " + str(current_state))
	if current_state == State.PLAYER_INPUT or current_state == State.CHOOSE_ENEMY:
		current_state = State.PLAYER_TURN
	elif current_state == State.PLAYER_TURN:
		current_state = State.ENEMY_TURN
	elif current_state == State.ENEMY_TURN:
		if (player_frozen_turns < 1):
			if (player_frozen_turns == 0):
				player_frozen_turns -= 1
				dialog.add_line("You thawed out!")
				await wait(1.0)
			current_state = State.PLAYER_INPUT
			new_draw_card()
		else:
			dialog.add_line("You are frozen for " + str(player_frozen_turns) + " more turns!")
			player_frozen_turns -= 1
			current_state = State.ENEMY_TURN
		
		player_invuln_turns -= 1
		if player_invuln_turns == 0:
			dialog.add_line("You are no longer invulnerable!")
		if current_state == State.ENEMY_TURN:
			do_enemy_turn()
		
	print("to state  " + str(current_state))

func new_draw_card(): # generate new random card that can be drawn this turn
	var luck = randf_range(-1,0.6)
	var newCardData: CardData = CardData.Generate_Card(luck)
	var newcard = CARD.instantiate()
	newcard.card_data = newCardData
	newcard.battleScene = self
	newcard.is_draw = true
	draw_area.add_child(newcard)
	if draw_card != null:
		draw_card.queue_free()
	draw_card = newcard
	newcard.goal_scale = newcard.scale
	newcard.scale = Vector2.ZERO
	(draw_card.sprite_2d as Sprite2D).modulate.a = 0.7
	
func add_enemy(enemy: Enemy):
	var new_enemy = BATTLE_ENEMY.instantiate()
	new_enemy.data = enemy.data
	new_enemy.battleScene = self
	new_enemy.overworld_instance = enemy
	add_child(new_enemy)
	new_enemy.position.y -= 150
	enemies.push_back(new_enemy)
func add_player_card(card: CardData):
	player_cards.push_back(card)
func player_can_input():
	return current_state == State.PLAYER_INPUT
func can_choose_enemy():
	return current_state == State.CHOOSE_ENEMY

func _ready():
	hide()
# Called when the node enters the scene tree for the first time.
func start_battle():
	player = get_node("../Player")
	if player:
		player_cards = player.cards
	else:
		end_battle()
	get_tree().paused = true
	normal_cam = get_viewport().get_camera_2d()
	camera_2d.make_current()
	if enemies.size() > 0:
		background.material = enemies[0].data.bgshader
	show()
	# Add enemies to scene, spaced out accordingly
	for i in player_cards.size():
		var card = player_cards[i]
		var newcard = CARD.instantiate()
		newcard.card_data = card
		newcard.battleScene = self
		cards.push_back(newcard)
		hand.add_child(newcard)
		newcard.position.y = 1000
	show_cards()
	new_draw_card()
	show_enemies()
	if enemies.size() > 1:
		var msg = ""
		for i in enemies.size():
			if i == 0:
				msg += enemies[i].data.name
			elif i == enemies.size()-1:
				msg += " and " + enemies[i].data.name
			else:
				msg += ", " + enemies[i].data.name
		dialog.set_text(msg + " draw near!")
	else:
		dialog.set_text(enemies[0].data.name + " approaches!")
	update_health()
		
func show_cards():
	for i in cards.size():
		cards[i].goal_pos = Vector2((i * card_padding), 0)
func show_enemies():
	for i in enemies.size():
		enemies[i].position.x = (i * padding) - ((enemies.size()-1)*padding/2)
	
func end_battle():
	end_battle_timer.start(1)
	player.cards = []
	for card in cards:
		player.cards.push_back(card.card_data)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if anim_hurt:
		camera_2d.position.y *= -.9


func _on_timer_timeout():
	start_battle()


func _on_end_battle_timeout():
	# Set updated cards back to player
	# Change camera back and delete battle scene
	normal_cam.make_current()
	get_tree().paused = false
	player.can_move = true
	queue_free()

func use_card(card: Card):
	# disable input, start timer (For player to read), then do card effect and proceed battle state
	card_to_use = cards.find(card)
	if card.card_data.choose_enemy and enemies.size() > 1:
		current_state = State.CHOOSE_ENEMY
		dialog.set_text("Which enemy?")
	else:
		if card.card_data.choose_enemy:
			enemy_target = 0
		else:
			enemy_target = randi_range(0, enemies.size()-1) # pick random  (card was not flagged as needed to pick)
		next_state() # change from input turn to player turn
		card.reveal_secondary()
		card_reveal_timer.start()
		card.animate_pick = true
		card.vanish_timer.wait_time = card_reveal_timer.wait_time * .9
		card.vanish_timer.start()
		if player_poisoning > 0:
			dialog.add_line("You took " + str(player_poisoning) + " poison damage!")
			player.health.take_damage(player_poisoning, true)
			await wait(2.0)
		dialog.set_text("")
		
func set_target(enemy: BattleEnemy):
	var card : Card
	if card_to_use == -1:
		card = draw_card
	else:
		card = cards[card_to_use]
	dialog.set_text("")
	enemy_target = enemies.find(enemy)
	next_state()
	card.reveal_secondary()
	card_reveal_timer.start()
	# add some effect to make the reveal more obvious
	card.animate_pick = true
	card.vanish_timer.wait_time = card_reveal_timer.wait_time * .9
	card.vanish_timer.start()
	dialog.set_text("")

func _on_card_reveal_timer_timeout():
	# do card effect, then change to enemy turn
	var card : Card
	if card_to_use == -1:
		card = draw_card
	else:
		card = cards.pop_at(card_to_use)
	await card.card_data.use_card(self)
	card.queue_free()
	if draw_card:
		draw_card.goal_scale = Vector2.ZERO
	else:
		draw_card = null
	show_cards()

func enemy_dead(enemy: BattleEnemy):
	var text = enemy.data.death_text
	if not text or text == "":
		text = enemy.data.name + " died!"
	dialog.add_line(text)
	enemies.remove_at(enemies.find(enemy))
	enemy.overworld_instance.queue_free()
	enemy.queue_free()
	if enemies.size() < 1:
		win()
	show_enemies()
func win():
	dialog.add_line("You won!")
	await wait(2.0)
	end_battle()

func do_enemy_turn():
	current_state = State.ENEMY_TURN
	await wait(2.0)
	for enemy in enemies:
		await wait(2.0)
		if (enemy.frozen_turns < 1):
			if (enemy.frozen_turns == 0):
				enemy.frozen_turns -= 1
				# end freeze animation
				dialog.add_line(enemy.data.name + " thawed out!")
				await wait(1.0)
			await enemy.attack(self)
		else:
			dialog.add_line(enemy.data.name + " is frozen for " + str(enemy.frozen_turns) + " more turns!")
			enemy.frozen_turns -= 1
	await wait(2.0)
	dialog.set_text("What will you do?")
	next_state()
	
func update_health():
	health_label.text = str(player.health.health) + " HP"
	(health_particles.material as ShaderMaterial).set_shader_parameter("health_percent", player.health.get_pct())
	
func hurt_player(dmg: float, survivable: bool): # should be called with attack factor already applied
	await wait(1.5)
	# play some hurt animation
	if player_invuln_turns > 0:
		dialog.add_line("You are invulnerable to the hit!")
	else:
		anim_hurt = true
		var dmg_taken = player.health.take_damage(dmg / defense_factor, survivable)
		camera_2d.position.y += dmg_taken*10
		await wait(1)
		anim_hurt = false
		camera_2d.position.y = 0
		dialog.add_line("You took " + str(dmg_taken) + " damage!")
		update_health()
		if player.health.is_dead:
			game_over()
	
func game_over():
	current_state = State.PLAYER_DEAD
	dialog.add_line("You died and dropped your cards!")
	await wait(4)
	player.position = Vector2.ZERO
	# maybe literally drop player's cards where they died? to pick back up
	cards = []
	end_battle()
	
func wait(seconds: int):
	wait_timer.wait_time = seconds
	wait_timer.start()
	await wait_timer.timeout

func heal_player(amount: float):
	var amounti = ceili(amount)
	if player.health.heal(amounti):
		dialog.add_line("You were fully healed!")
	else:
		dialog.add_line("You were healed by " + str(amounti))
	update_health()
	await wait(1.5)

func heal_enemy(amount: float):
	var enemy = enemies[enemy_target]
	var amounti = ceili(amount)
	if enemy.health.heal(amounti):
		dialog.add_line(enemy.data.name + " was fully healed!")
	else:
		dialog.add_line(enemy.data.name + " was healed by " + str(amounti))
	await wait(1.5)

func hurt_enemy(enemy: BattleEnemy, dmg: float, survivable: bool):
	# play some hurt animation
	if enemy.invuln_turns > 0:
		dialog.add_line(enemy.data.name + " is invulnerable to the hit!")
	else:
		anim_hurt = true
		var dmg_taken = enemy.health.take_damage(dmg / defense_factor, survivable)
		dialog.add_line("Dealt " + str(dmg) + " damage to " + enemy.data.name + '.')
		if enemy.health.is_dead:
			enemy_dead(enemy)
	await wait(1.5)
