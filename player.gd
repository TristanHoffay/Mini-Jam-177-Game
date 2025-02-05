class_name Player extends CharacterBody2D
@onready var camera_2d = $Camera2D
@export var cards: Array[CardData] = []
@onready var health : Health = $Health
@onready var cpu_particles_2d = $CPUParticles2D
@export var start_with_new_cards: int = 4
@export var newgame: bool = false
const DUNGEON = preload("res://Music/dungeon.mp3")
const DUNGEON_3 = preload("res://Music/dungeon3.mp3")
const BACKGROUND = preload("res://Music/background.mp3")
const SPEED = 700.0
var can_move = true
const DUNGEON_2 = preload("res://Music/dungeon2.mp3")
const MYSTICAL = preload("res://Music/mystical.mp3")
@onready var sprite_2d = $Sprite2D
const BOSS = preload("res://boss.png")
func hurt():
	pass # make whole screen flash red?
const TOMB = preload("res://Music/tomb.mp3")
func _physics_process(delta):
	if can_move:
		var direction = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down")).normalized()
		if Input.is_action_pressed("left_click"):
			direction = (get_global_mouse_position() - position).normalized()
		if direction:
			velocity = direction * SPEED
			MusicPlayer.play_walk()
		else:
			MusicPlayer.stop_walk()
			velocity = Vector2.ZERO

		move_and_slide()
func _ready():
	MusicPlayer.fade_in(200)
	MusicPlayer.set_dungeon_bgm()
	TransitionScreen.fade_in()
	spawn_cards(false)
	if (newgame):
		sprite_2d.texture = BOSS

func spawn_cards(dead: bool):
	var luck = -.8 
	if dead:
		luck = 1 - (MusicPlayer.enemies_in_world.size() / 32.0)
	if newgame:
		luck = 1
	if start_with_new_cards > -1:
		cards = []
		for i in start_with_new_cards:
			var newcard = CardData.Generate_Card(luck)
			cards.append(newcard)

func _on_area_2d_body_entered(body):
	MusicPlayer.new_dungeon_bgm(DUNGEON)


func _on_area_2d_2_body_entered(body):
	MusicPlayer.new_dungeon_bgm(DUNGEON_3)


func _on_area_2d_3_body_entered(body):
	MusicPlayer.new_dungeon_bgm(DUNGEON_2)


func _on_area_2d_4_body_entered(body):
	MusicPlayer.new_dungeon_bgm(MYSTICAL)


func _on_area_2d_5_body_entered(body):
	MusicPlayer.new_dungeon_bgm(TOMB)


func _on_area_2d_6_body_entered(body):
	MusicPlayer.new_dungeon_bgm(BACKGROUND)
