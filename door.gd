extends StaticBody2D
var goal_rot
@onready var static_body_2d = $StaticBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if goal_rot:
		rotation = lerp(rotation, goal_rot, delta)


func _on_area_2d_body_entered(body):
	print("unlocked")
	goal_rot = rotation + 90
	static_body_2d.set_deferred("disabled", true)
