extends Node
const BACKGROUND = preload("res://Music/background.mp3")
const DUNGEON_2 = preload("res://Music/dungeon2.mp3")
@onready var sfx_player = $"SFX Player"
const BATTLEWIN = preload("res://sfx/battlewin.mp3")
const CARDFLY = preload("res://sfx/cardfly.mp3")
const ENEMYDEAD = preload("res://sfx/enemydead.mp3")
const ENTERBATTLE = preload("res://sfx/enterbattle.mp3")
const HURT = preload("res://sfx/hurt.mp3")
const LIFEUP = preload("res://sfx/lifeup.mp3")
const PICKCARD = preload("res://sfx/pickcard.mp3")
const WALK = preload("res://sfx/walk.mp3")
var fading_out: float = 0.0
var fading_in: float = 0.0
var pause_at: float = 0.0
var dungeon_bgm = BACKGROUND
var enemies_in_world: Array[Enemy] = []
var newgame: bool = false
const TOMB = preload("res://Music/tomb.mp3")
@onready var audio_player = $Audio_Player

func set_score(music: AudioStreamMP3):
	if audio_player.stream == dungeon_bgm:
		pause_at = audio_player.get_playback_position()
	audio_player.stream = music
	audio_player.play()

func set_dungeon_bgm():
	audio_player.stream = dungeon_bgm
	audio_player.play(pause_at)
	
func new_dungeon_bgm(track: AudioStreamMP3):
	if dungeon_bgm != track:
		dungeon_bgm = track
		pause_at = 0
		set_dungeon_bgm()
	

func _process(delta):
	audio_player.volume_db -= fading_out * delta
	audio_player.volume_db += fading_in * delta
	if audio_player.volume_db > 1:
		audio_player.volume_db = 1

func mute():
	audio_player.volume_db = -100

func fade_out(speed: float):
	fading_in = 0
	fading_out = speed
func fade_in(speed: float):
	mute()
	fading_in = speed
	fading_out = 0
func play_battle_win():
	sfx_player.stream = BATTLEWIN
	sfx_player.play()
func play_card_fly():
	sfx_player.stream = CARDFLY
	sfx_player.play()
func play_enemy_dead():
	sfx_player.stream = ENEMYDEAD
	sfx_player.play()
func play_enter_battle():
	sfx_player.stream = ENTERBATTLE
	sfx_player.play()
func play_hurt():
	sfx_player.stream = HURT
	sfx_player.play()
func play_lifeup():
	sfx_player.stream = LIFEUP
	sfx_player.play()
func play_pick_card():
	sfx_player.stream = PICKCARD
	sfx_player.play()
func play_walk():
	if sfx_player.stream != WALK or not sfx_player.playing:
		sfx_player.stream = WALK
		sfx_player.play()
func stop_walk():
	if sfx_player.stream == WALK and sfx_player.playing:
		sfx_player.stop()
