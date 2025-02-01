extends CharacterBody2D
@onready var camera_2d = $Camera2D
@export var cards: Array[CardData] = []


const SPEED = 700.0
var can_move = true


func _physics_process(delta):
	if can_move:
		var direction = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down")).normalized()
		if direction:
			velocity = direction * SPEED
		else:
			velocity = Vector2.ZERO

		move_and_slide()
