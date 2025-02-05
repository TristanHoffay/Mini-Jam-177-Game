class_name EnemyData extends Resource

@export var texture: Texture
@export var name: String
@export var death_text: String
@export var attack_text: String
@export var health: int 
#@export var attack: int
#@export var defense: int
@export var damage: int
@export var bgshader: ShaderMaterial
@export var attacks: Array[Dictionary]
@export var battle_music: AudioStreamMP3
@export var drop_luck: float
@export var sprite_scale: float = 1
@export var is_boss: bool = false
# attacks should have "text" and "damage" keys
#example: {"text":"threw a rock at you!", "damage":5}
