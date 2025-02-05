extends CanvasLayer
@onready var animation_player = $AnimationPlayer

func _ready():
	fade_in()

func fade_out():
	animation_player.play("fade_to_black")

func fade_in():
	animation_player.play("fade_to_normal")

func fade_in_fast():
	animation_player.play("fade_in_fast")
