extends Node2D
@export var card_data : CardData
@onready var sprite_2d = $Sprite2D
@onready var primary_title = $PrimaryTitle
@onready var primary_subtitle = $PrimaryTitle/PrimarySubtitle
@onready var secondary_title = $SecondaryTitle
@onready var secondary_subtitle = $SecondaryTitle/SecondarySubtitle
var battleScene: Battle

func _ready():
	sprite_2d.material = sprite_2d.material.duplicate()
	(sprite_2d.material as ShaderMaterial).set_shader_parameter("Rarity", card_data.rarity)
	var prim_text = (card_data.get_primary_text() as String).split('\n')
	primary_title.text = prim_text[0]
	if prim_text.size() > 1:
		primary_subtitle.text = prim_text[1]
	# hide secondary
	secondary_title.text = ""
	secondary_subtitle.text = ""
	
func reveal_secondary():
	var sec_text = (card_data.get_secondary_text() as String).split('\n')
	secondary_title.text = sec_text[0]
	if sec_text.size() > 1:
		secondary_subtitle.text = sec_text[1]

func _on_area_2d_mouse_entered():
	if battleScene.is_player_turn():
		position.y -= 40


func _on_area_2d_mouse_exited():
	if battleScene.is_player_turn():
		position.y += 40


func _on_area_2d_input_event(viewport, event, shape_idx):
	if battleScene.is_player_turn() and event.is_action_pressed("left_click"):
		reveal_secondary()
		position.y -= 50
		# start timer, then at the end do the card effect
		battleScene.use_card(self)
