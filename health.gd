extends Node2D

@export var max_health: int = 100
@export var health: int = 100
@export var survives_secondary_effects: bool = true

# returns if alive or not
func take_damage(damage: int, is_survivable_secondary_effect: bool):
	health -= damage
	if health <= 0:
		if is_survivable_secondary_effect and survives_secondary_effects:
			health = 1
			# play effect
		else:
			return false
	return true
