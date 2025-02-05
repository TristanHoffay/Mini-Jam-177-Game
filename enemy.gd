class_name Enemy extends CharacterBody2D
@onready var sprite_2d = $Sprite2D
const BATTLE = preload("res://battle.tscn")
@export var speed: float = 300
@export var data: EnemyData
var direction : Vector2 = Vector2.ZERO
var can_move = true
@export var wanders: bool = true
var playerFound: CharacterBody2D
const PLAYER = preload("res://player.png")
const BOSS = preload("res://boss.png")
# Called when the node enters the scene tree for the first time.
func _ready():
	# Load data's texture
	if MusicPlayer.newgame and data.texture == BOSS:
		data.texture = PLAYER
	sprite_2d.texture = data.texture
	sprite_2d.scale *= data.sprite_scale
	MusicPlayer.enemies_in_world.append(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if can_move:
		if playerFound:
			velocity = (playerFound.position - position).normalized() * speed
			move_and_slide()
		elif wanders:
			if direction:
				# Chance to stop moving
				if randf() < .05:
					direction = Vector2.ZERO
				else:
					# Move and rotate randomly
					velocity = direction
					move_and_slide()
					direction.rotated(.5 * (randf()-0.5))
			else:
				if  randf() < 0.05:
					direction = Vector2.from_angle(randf() * PI * 2).normalized() * speed


func _on_player_detection_body_entered(body):
	playerFound = body


func _on_player_detection_body_exited(body):
	playerFound = null


func _on_battle_range_body_entered(body: CharacterBody2D):
	# Initiate battle with enemy
	var battle = get_node("../Battle")
	if not battle:
		print("Starting battle")
		battle = BATTLE.instantiate()
		add_sibling(battle)
	print(data.name + " joined the battle")
	battle.add_enemy(self)
	body.can_move = false
	can_move = false
