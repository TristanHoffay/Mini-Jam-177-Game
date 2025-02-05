class_name Health extends Node2D

@export var max_health: int = 100
@export var health: int = 100
@export var defense: float = 1
@export var survives_secondary_effects: bool = true
var is_dead = false

# returns amount of damage taken
func take_damage(damage: float, is_survivable_secondary_effect: bool):
	var dmg = floori(damage/defense)
	health -= dmg
	get_parent().hurt()
	MusicPlayer.play_hurt()
	if health <= 0:
		if is_survivable_secondary_effect and survives_secondary_effects:
			health = 1
		else:
			health = 0
			is_dead = true
			return dmg
	return dmg

func get_pct():
	return float(health) / max_health

# returns if full healed or not
func heal(amount: int):
	health += amount
	if health >= max_health:
		health = max_health
		return true
	return false
