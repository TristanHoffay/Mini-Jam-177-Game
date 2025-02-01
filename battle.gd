class_name Battle extends Node2D
@export var player_cards : Array[CardData]
@onready var camera_2d = $Camera2D
@onready var background = $Background
@export var padding: float = 300
@export var card_padding: float = 320
@onready var hand = $Hand
const CARD = preload("res://card.tscn")
@onready var end_battle_timer: Timer = $"End Battle"
var normal_cam : Camera2D

var player: CharacterBody2D
var enemies : Array[EnemyData]
var enemy_sprites: Array[Sprite2D] = []
var cards: Array[Node2D] = []

enum State {PLAYER_TURN, ENEMY_TURN}
var current_state = State.PLAYER_TURN
func next_state():
	if current_state == State.PLAYER_TURN:
		current_state = State.ENEMY_TURN
	elif current_state == State.ENEMY_TURN:
		current_state = State.PLAYER_TURN
		

func add_enemy(enemy: EnemyData):
	enemies.push_back(enemy)
func add_player_card(card: CardData):
	player_cards.push_back(card)
func is_player_turn():
	return current_state == State.PLAYER_TURN

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
		background.material = enemies[0].bgshader
	show()
	# Add enemies to scene, spaced out accordingly
	for i in enemies.size():
		var enemy = enemies[i]
		var newsprite = Sprite2D.new()
		newsprite.texture = enemy.texture
		enemy_sprites.append(newsprite)
		add_child(newsprite)
		newsprite.position.x += (i * padding) - ((enemies.size()-1)*padding/2)
		newsprite.position.y -= 250
	for i in player_cards.size():
		var card = player_cards[i]
		var newcard = CARD.instantiate()
		newcard.card_data = card
		newcard.battleScene = self
		cards.push_back(newcard)
		hand.add_child(newcard)
		newcard.position.x += (i * card_padding)
		
func end_battle():
	end_battle_timer.start(1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timer_timeout():
	start_battle()


func _on_end_battle_timeout():
	# Set updated cards back to player
	# Change camera back and delete battle scene
	normal_cam.make_current()
	player.cards = player_cards
	get_tree().paused = false
	queue_free()

func use_card(card: Node2D):
	# disable input, start timer (For player to read), then do card effect and proceed battle state
	next_state()
	pass
