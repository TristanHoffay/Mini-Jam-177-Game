class_name BattleEnemy extends Node2D
@onready var sprite_2d = $Sprite2D
@export var data: EnemyData
@onready var health: Health = $Health
const ENEMY_HURT = preload("res://enemy_hurt.tres")
const ENEMY_FROZEN = preload("res://enemy_frozen.tres")
@onready var hurt_anim = $HurtAnim
var frozen_turns: int = -1
var invuln_turns: int = -1
var poisoning: int = 0
var overworld_instance
@onready var death_timer = $DeathTimer

var battleScene: Battle
var attack_factor: float = 1
var goal_pos: Vector2
var goal_scale: Vector2
var active: bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite_2d.texture = data.texture
	sprite_2d.material = null
	health.max_health = data.health
	health.health = data.health
	sprite_2d.scale *= data.sprite_scale

func _process(delta):
	if active:
		position = lerp(position, goal_pos, delta * 10)
		scale = lerp(scale, goal_scale, delta * 10)

func hurt():
	# do effects for getting hurt
	var newShader = ShaderMaterial.new()
	newShader.shader = ENEMY_HURT
	sprite_2d.material = newShader
	hurt_anim.start()

func die():
	# do die animation and start timer for queuefree
	hurt()
	goal_scale = Vector2.ZERO
	death_timer.start()

func _on_area_2d_mouse_entered():
	if battleScene.can_choose_enemy():
		goal_scale = Vector2.ONE * 1.2


func _on_area_2d_mouse_exited():
	if battleScene.can_choose_enemy():
		goal_scale = Vector2.ONE


func _on_area_2d_input_event(viewport, event, shape_idx):
	if battleScene.can_choose_enemy() and event.is_action_pressed("left_click"):
		goal_scale = Vector2.ONE
		battleScene.set_target(self)


func _on_hurt_anim_timeout():
	if frozen_turns > 0:
		sprite_2d.material.shader = ENEMY_FROZEN
	else:
		sprite_2d.material = null

func attack(battle: Battle):
	var text = data.name + ' '
	var dmg = 0
	if data.attacks.size() < 1:
		if data.attack_text != "":
			text += data.attack_text
		else:
			text += "attacks!"
		dmg = data.damage
	else:
		print(data.attacks)
		var atk = randi_range(0,data.attacks.size()-1)
		text += data.attacks[atk]["text"]
		dmg = float(data.attacks[atk]["damage"])
	battle.dialog.add_line(text)
	if dmg != 0:
		dmg *= attack_factor
		await battle.hurt_player(dmg, false)
	if poisoning > 0:
		await battle.wait(2.0)
		battle.dialog.add_line(data.name + " took " + str(poisoning) + " poison damage!")
		health.take_damage(poisoning, false)
		if health.is_dead:
			battle.enemy_dead(self)
	invuln_turns -= 1
	if invuln_turns == 0:
		battle.dialog.add_line(data.name + " is no longer invulnerable!")

func freeze(turns: int):
	frozen_turns = turns
	var newShader = ShaderMaterial.new()
	newShader.shader = ENEMY_FROZEN
	sprite_2d.material = newShader
func poison(level: int):
	poisoning = level
