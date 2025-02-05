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
var music = MusicPlayer
const BATTLE_1 = preload("res://Music/battle1.mp3")
const LEVEL = preload("res://level.tscn")
const MYSTICAL = preload("res://Music/mystical.mp3")
var player: Player
var enemies : Array[BattleEnemy]
var cards: Array[Card] = []
var card_to_use: int
var enemy_target: int
var damage_factor: float = 1
var defense_factor: float = 1
var anim_hurt:bool = false
var draw_card: Card
var dire_card: Card
var player_invuln_turns = -1
var player_frozen_turns = -1
var player_poisoning = 0
var card_hovered : Array[Card] = [] # quick fix to prevent multiple cards from updating ui when hovered

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
	var luck = 1 - (MusicPlayer.enemies_in_world.size() / 32.0)
	if player.newgame:
		luck = 1
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
	
func new_dire_card(): # generate new random card that can be drawn this turn
	var luck = randf_range(0.7,0.999)
	if player.newgame:
		luck = 1
	var newCardData: CardData = CardData.Generate_Card(luck)
	var newcard = CARD.instantiate()
	newcard.card_data = newCardData
	newcard.battleScene = self
	newcard.is_draw = true
	health_particles.add_child(newcard)
	if dire_card != null:
		dire_card.queue_free()
	dire_card = newcard
	newcard.goal_scale = newcard.scale
	newcard.scale = Vector2.ZERO
	(dire_card.sprite_2d as Sprite2D).modulate.a = 0.7
	
func add_enemy(enemy: Enemy):
	var new_enemy = BATTLE_ENEMY.instantiate()
	new_enemy.data = enemy.data
	new_enemy.battleScene = self
	new_enemy.overworld_instance = enemy
	add_child(new_enemy)
	new_enemy.goal_pos = Vector2.ZERO
	new_enemy.goal_scale = new_enemy.scale
	new_enemy.scale = Vector2.ZERO
	new_enemy.active = false
	enemies.push_back(new_enemy)
	show_enemies(true)
func add_player_card(card: CardData):
	var newcard = CARD.instantiate()
	newcard.card_data = card
	newcard.battleScene = self
	cards.push_back(newcard)
	hand.add_child(newcard)
	newcard.position.y = 1000
	player_cards.push_back(card)
	show_cards()
func player_can_input():
	return current_state == State.PLAYER_INPUT
func can_choose_enemy():
	return current_state == State.CHOOSE_ENEMY

func _ready():
	MusicPlayer.fade_out(400)
	MusicPlayer.play_enter_battle()
	hide()
	TransitionScreen.fade_out()
	
# Called when the node enters the scene tree for the first time.
func start_battle():
	for enemy in enemies:
		enemy.active = true
	TransitionScreen.fade_in_fast()
	var set:bool = false
	if enemies.size() > 0:
		for enemy in enemies:
			if enemy.data.battle_music and (enemy.data.is_boss or not set):
				MusicPlayer.set_score(enemy.data.battle_music)
				background.material = enemy.data.bgshader
				set = true
	if not set:
		MusicPlayer.set_score(BATTLE_1)
		background.material = enemies[0].data.bgshader
	MusicPlayer.fade_in(1000)
	player = get_node("../Player")
	if player:
		player_cards = player.cards
	else:
		end_battle()
	get_tree().paused = true
	normal_cam = get_viewport().get_camera_2d()
	camera_2d.make_current()
	show()
	# Add enemies to scene, spaced out accordingly
	for i in player_cards.size():
		add_player_card(player_cards[i])
		
	show_cards()
	new_draw_card()
	show_enemies(false)
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
	var rows: int = ceili(cards.size()/4.0)
	print(str(rows) + " rows")
	for r in rows:
		for i in cards.size()-(r*4):
			var card = cards[(r*4)+i]
			if r > 0:
				card.make_coll_small()
			else:
				card.make_coll_big()
			card.goal_pos = Vector2((i * card_padding), -r * card_padding/2)
			card.z_index = rows-r
func show_enemies(immeditate: bool):
	for i in enemies.size():
		if immeditate:
			enemies[i].position = Vector2((i * padding) - ((enemies.size()-1)*padding/2), -150)
		enemies[i].goal_pos = Vector2((i * padding) - ((enemies.size()-1)*padding/2), -150)
	
func end_battle():
	MusicPlayer.fade_out(500)
	TransitionScreen.fade_out()
	end_battle_timer.start(1)
	player.cards = []
	if current_state == State.PLAYER_DEAD:
		player.spawn_cards(true)
	else:
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
	var hpct = player.health.get_pct()
	(player.cpu_particles_2d.material as ShaderMaterial).set_shader_parameter("health_percent", hpct)
	TransitionScreen.fade_in()
	MusicPlayer.set_dungeon_bgm()
	MusicPlayer.fade_in(200)
	queue_free()

func use_card(card: Card):
	# disable input, start timer (For player to read), then do card effect and proceed battle state
	card_to_use = cards.find(card)
	if card_to_use == -1:
		if card != draw_card:
			card_to_use == -2
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
	elif card_to_use == -2:
		card = dire_card
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
	elif card_to_use == -2:
		card = dire_card
	else:
		card = cards.pop_at(card_to_use)
	await card.card_data.use_card(self)
	if is_instance_valid(draw_card) :
		draw_card.goal_scale = Vector2.ZERO
	else:
		draw_card = null
	card.queue_free()
	show_cards()

func enemy_dead(enemy: BattleEnemy):
	var text = enemy.data.name + ' ' + enemy.data.death_text
	if not text or text == "":
		text = enemy.data.name + " died!"
	MusicPlayer.play_enemy_dead()
	dialog.add_line(text)
	enemies.remove_at(enemies.find(enemy))
	MusicPlayer.enemies_in_world.remove_at(MusicPlayer.enemies_in_world.find(enemy.overworld_instance))
	enemy.overworld_instance.queue_free()
	enemy.die()
	dialog.add_line(enemy.data.name + " dropped some cards!")
	var luck = (enemy.data.drop_luck + (1 - (MusicPlayer.enemies_in_world.size() / 32.0))) / 2
	if player.newgame:
		luck = 1
	for i in round(randf_range(1, 4 + (2*luck))):
		if (cards.size() >= 12):
			dialog.add_line("You can't hold any more cards!")
			break
		var newcard = CardData.Generate_Card(luck)
		add_player_card(newcard)
	await wait(2.0)
	if enemies.size() < 1:
		current_state = State.ENEMY_TURN
		if MusicPlayer.enemies_in_world.size() <= 0:
			await wait(4.0)
			MusicPlayer.fade_out(10)
			dialog.set_text("")
			await wait(1)
			dialog.add_line("You defeated everyone in the crypt!")
			await wait(2.0)
			MusicPlayer.set_score(MYSTICAL)
			MusicPlayer.fade_in(100)
			if dire_card != null:
				dire_card.goal_scale = Vector2.ZERO
				await wait(.5)
				dire_card.queue_free()
			for i in range(cards.size()-1, -1, -1):
				var card = cards[i]
				card.goal_scale = Vector2.ZERO
				await wait(0.3)
				card.queue_free()
			cards = []
			show_cards()
			await wait(2.0)
			var newcard: CardData = CardData.new()
			newcard.rarity = 2
			newcard.strength1 = 1
			newcard.strength2 = -1
			newcard.PrimaryEffect = CardData.Effect.WIN_GAME
			newcard.SecondaryEffect = CardData.Effect.RESTART_GAME
			add_player_card(newcard)
			show_cards()
			current_state = State.PLAYER_INPUT
			dialog.set_text("")
			await wait(3.0)
			dialog.set_text("...")
			await wait(7.0)
			dialog.set_text("What will you do?")
			await wait(8.0)
			dialog.add_line("Are you going to use it?")
			await wait(9.0)
			dialog.set_text("Are you ready for everything to start over again?")
			await wait(10.0)
			dialog.set_text("...")
			await wait(3.0)
			dialog.set_text("What will you do?")
			await wait(15.0)
			dialog.set_text("I'll use it if you won't...")
			await wait(11.0)
			dialog.add_line("I'm serious, you know.")
			await wait(14.0)
			dialog.set_text("You better use that card.")
			await wait(10.0)
			dialog.set_text("You have ten seconds to use that card.")
			await wait(5.0)
			dialog.add_line("Five seconds.")
			await wait(2)
			dialog.add_line("Three...")
			await wait(1)
			dialog.add_line("Two...")
			await wait(1)
			dialog.add_line("One...")
			await wait(1)
			dialog.set_text("...")
			await wait(3)
			dialog.set_text("You asked for it.")
			await wait(1)
			use_card(cards[0])
		else:
			win()
	show_enemies(false)
	
func win_game():
	MusicPlayer.fade_out(100)
	dialog.set_text("")
	await wait(1.0)
	dialog.set_text("...")
	await wait(2.0)
	dialog.set_text("See you on the other side...")
	TransitionScreen.fade_out()
	await wait(3.5)
	MusicPlayer.newgame = true
	var newlevel = LEVEL.instantiate()
	var newplayer = newlevel.get_node("Player")
	newplayer.newgame = true
	newlevel.name = "level"
	var thislevel = get_tree().root.get_node("level")
	thislevel.name = "old_level"
	print("\n\n\n" + thislevel.name + "\n\n\n")
	get_tree().root.add_child(newlevel)
	(newplayer.get_node("Camera2D") as Camera2D).make_current()
	get_tree().paused = false
	get_tree().root.remove_child(thislevel)
	thislevel.queue_free()
	
func win():
	dialog.add_line("You won!")
	MusicPlayer.play_battle_win()
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
	var hpct = player.health.get_pct()
	(health_particles.material as ShaderMaterial).set_shader_parameter("health_percent", hpct)
	(player.cpu_particles_2d.material as ShaderMaterial).set_shader_parameter("health_percent", hpct)
	if hpct <= 0.1 and  hpct > 0:
		new_dire_card()
	
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
	player.health.health = player.health.max_health
	player.health.is_dead =  false
	# maybe literally drop player's cards where they died? to pick back up
	cards = []
	end_battle()
	
func wait(seconds: float):
	wait_timer.wait_time = seconds
	wait_timer.start()
	await wait_timer.timeout

func heal_player(amount: float):
	var amounti = ceili(amount)
	if player.health.heal(amounti):
		dialog.add_line("You were fully healed!")
	else:
		dialog.add_line("You were healed by " + str(amounti))
	MusicPlayer.play_lifeup()
	update_health()
	await wait(1.5)

func heal_enemy(enemy: BattleEnemy, amount: float):
	if (not enemy) or (enemy == null) or (not is_instance_valid(enemy)) or (typeof(enemy) == TYPE_NIL):
		if enemies.size() < 1:
			return
		if enemy_target > enemies.size()-1:
			enemy = enemies[0]
		else:
			enemy = enemies[enemy_target]
	var amounti = ceili(amount)
	if enemy.health and enemy.health.heal(amounti):
		dialog.add_line(enemy.data.name + " was fully healed!")
	else:
		dialog.add_line(enemy.data.name + " was healed by " + str(amounti))
	MusicPlayer.play_lifeup()
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
