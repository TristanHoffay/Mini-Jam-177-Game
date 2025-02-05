class_name Card extends Node2D
@export var card_data : CardData
@onready var sprite_2d = $Sprite2D
var battleScene: Battle
var animate_pick: bool = false
var animate_vanish: bool = false
var is_draw = false
var goal_pos: Vector2
var goal_scale: Vector2
@onready var primary_title = $Sprite2D/PrimaryTitle
@onready var primary_subtitle = $Sprite2D/PrimaryTitle/PrimarySubtitle
@onready var secondary_title = $Sprite2D/SecondaryTitle
@onready var secondary_subtitle = $Sprite2D/SecondaryTitle/SecondarySubtitle
@onready var vanish_timer: Timer = $VanishTimer
@onready var collision_shape_2d = $Area2D/CollisionShape2D

func _ready():
	sprite_2d.material = sprite_2d.material.duplicate()
	(sprite_2d.material as ShaderMaterial).set_shader_parameter("Rarity", card_data.rarity)
	(sprite_2d.material as ShaderMaterial).set_shader_parameter("primary_strength", card_data.strength1)
	(sprite_2d.material as ShaderMaterial).set_shader_parameter("secondary_strength", card_data.strength2)
	var prim_text = (card_data.get_primary_text() as String).split('\n')
	primary_title.text = prim_text[0]
	if prim_text.size() > 1:
		primary_subtitle.text = prim_text[1]
	else:
		primary_subtitle.text = ""
	# hide secondary
	secondary_title.text = ""
	secondary_subtitle.text = ""
	
	if not goal_scale:
		goal_scale = scale
	if not goal_pos:
		goal_pos = position
	
func reveal_secondary():
	var sec_text = (card_data.get_secondary_text() as String).split('\n')
	secondary_title.text = sec_text[0]
	if sec_text.size() > 1:
		secondary_subtitle.text = sec_text[1]

func make_coll_small():
	collision_shape_2d.shape = RectangleShape2D.new()
	(collision_shape_2d.shape as RectangleShape2D).size = Vector2(600,260)
	collision_shape_2d.position.y = -200
	
func make_coll_big():
	collision_shape_2d.shape = RectangleShape2D.new()
	(collision_shape_2d.shape as RectangleShape2D).size = Vector2(600,800)
	collision_shape_2d.position.y = 0

func _on_area_2d_mouse_entered():
	if battleScene.player_can_input():
		if is_draw:
			sprite_2d.modulate.a = 1
		goal_pos.y -= 40


func _on_area_2d_mouse_exited():
	if battleScene.player_can_input():
		if is_draw:
			sprite_2d.modulate.a = 0.7
		goal_pos.y += 40


func _on_area_2d_input_event(viewport, event, shape_idx):
	if battleScene.player_can_input() and event.is_action_pressed("left_click"):
		goal_pos.y -= 50
		# start timer, then at the end do the card effect
		battleScene.use_card(self)
		MusicPlayer.play_pick_card()
		#(viewport as Viewport).set_input_as_handled()

func _process(delta):
	if animate_pick:
		z_index = 100
		position = lerp(position, Vector2(0,-400), delta*4)
		scale = lerp(scale, Vector2.ONE*0.8,  delta*4)
	elif animate_vanish:
		position = lerp(position, Vector2(0,-500), delta*20)
		scale = lerp(scale, Vector2(0.1,0), delta*40)
	else:
		position = lerp(position, goal_pos, delta*4)
		scale = lerp(scale, goal_scale,  delta*4)


func _on_vanish_timer_timeout():
	animate_pick = false
	animate_vanish = true
	MusicPlayer.play_card_fly()
	print("ok")
	
