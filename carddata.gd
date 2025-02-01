class_name CardData extends Resource
#
#Positive:
			#Deal X damage to foe
			#Insta-kill enemy (extremely rare or has horrible secondary effect)
			#Heal X health to player
			#Fully heal player
			#Magic/sweep attack (damage all foes)
			#Freeze foe for X-Y turns
			#Poison foe at X degree (damage every turn)
			#Make player invulnerable for X-Y turns (should be low number)
			#Boost attack of player
			#Boost defense of player
			#Cripple attack of foe
			#Cripple defense of foe
			#Reveal secondary effect of random card
		#Negative:
			#Cancel effect of card (card is a dud)
			#Deal X damage to player
			#Heal X damage to foe
			#Fully heal foe
			#Freeze player for X-Y turns
			#Poison player at X degree (damage every turn)
			#Make foe invulnerable for X-Y turns (should be low number)
			#Boost attack of foe
			#Boost defense of foe
			#Cripple attack of player
			#Cripple defense of player
			#
		#Ambiguous:
			#End battle
			#Use random other card
			#Recycle card (replace with random new card)
			#Bomb (damage all enemies and self)
			#Fully heal all battle participants
			#
	#World:
		#Primary:
			#Bomb (open walls)
			#Unlock door
			#Give player new battle card
			#
		#Secondary:
			#Deal X damage to player
			#Slow movement speed by X
#
var date = Time.get_datetime_dict_from_system()
var effect_names = [
	"Deal $ damage to an enemy",
	"Insta-kill an enemy",
	"Heal yourself by $",
	"Fully heal yourself",
	"Deal $ damage to all enemies",
	"Freeze an enemy for $ turns",
	"Poison an enemy at level $",
	"Become invulnerable for $ turns",
	"Boost your damage dealt by $ times",
	"Lower your damage taken by $ times",
	"Cripple an enemy's attack by $ times",
	"Cripple an enemy's defense by $ times",
	"Reveal the hidden effect on a random one of your cards",
	#negative
	"This card does nothing (dud)\nToo bad!",
	"Take $ damage\nThat's gotta hurt!",
	"Heal an enemy by $\nThey appreciate it!",
	"Fully heal an enemy\nIt doesn't mean they'll go easier on you...",
	"Get frozen for $ turns\nMaybe the enemy will defeat itself!",
	"Get poisoned for $ turns\nBetter hurry!",
	"Enemy becomes invulnerable for $ turns\nHope you made this turn count!",
	"Boost an enemy's attack by $ times\nNow look what you've done!",
	"Boost an enemy's defense by $ times\nGood luck hitting now!",
	"Lower your damage dealt by $ times\nWhat's wrong?",
	"Take $ times as much damage\nLooks like you broke something!",
	# ambiguous
	"End the battle immediately\nLooks like you got out of this one",
	"Use another random card from your hand\nHope it's a good one!",
	"Swap this card out with a new one\nOther effect is void",
	"Bomb\nExplosion damages everyone in the battle",
	"Fully heal everyone in the battle\nRound 2!",
	# world effects
	"Bomb a crumbling wall to reveal an opening",
	"Unlock a door",
	"Redeem for one (1) new battle card\nExpires " + str(date["month"]) + "/" + str(date["day"]) + "/" + str(date["year"]+1),
	"Cripple your movement speed by $ times\nAre we there yet?",
	"Boost your movement speed by $ times",
	"Take $ damage\nYou must've tripped",
	"Heal yourself by $"
	]
var effect_funcs = [
	# positive
	'damage_foe', 
	'ko_foe', 
	'heal_player', 
	'full_heal_player', 
	'damage_all_foe', 
	'freeze_foe', 
	'poison_foe', 
	'player_invulnerable', 
	'boost_player_damage',
	'boost_player_defense', 
	'cripple_foe_damage', 
	'cripple_foe_defense', 
	'reveal_random_secondary',
	# negative effects
	'negate_card', 
	'damage_player', 
	'heal_foe', 
	'full_heal_foe', 
	'freeze_player',
	'poison_player', 
	'foe_invulnerable', 
	'boost_foe_damage', 
	'boost_foe_defense', 
	'cripple_player_damage', 
	'cripple_player_defense',
	# ambiguous effects
	'end_battle', 
	'use_random_card', 
	'swap_card', 
	'bomb_in_battle', 
	'full_heall_all',
	# world effects
	'bomb_wall', 
	'unlock_door', 
	'give_battle_card', 
	'cripple_movement', 
	'boost_movement', 
	'damage_player_in_world', 
	'heal_player_in_world']
enum Effect {
	# positive effects
	DAMAGE_FOE, KO_FOE, HEAL_PLAYER, FULL_HEAL_PLAYER, DAMAGE_ALL_FOE, FREEZE_FOE, POISON_FOE, PLAYER_INVULNERABLE, 
	BOOST_PLAYER_DAMAGE, BOOST_PLAYER_DEFENSE, CRIPPLE_FOE_DAMAGE, CRIPPLE_FOE_DEFENSE, REVEAL_RANDOM_SECONDARY,
	# negative effects
	NEGATE_CARD, DAMAGE_PLAYER, HEAL_FOE, FULL_HEAL_FOE, FREEZE_PLAYER, POISON_PLAYER, FOE_INVULNERABLE, 
	BOOST_FOE_DAMAGE, BOOST_FOE_DEFENSE, CRIPPLE_PLAYER_DAMAGE, CRIPPLE_PLAYER_DEFENSE,
	# ambiguous effects
	END_BATTLE, USE_RANDOM_CARD, SWAP_CARD, BOMB_IN_BATTLE, FULL_HEALL_ALL,
	# world effects
	BOMB_WALL, UNLOCK_DOOR, GIVE_BATTLE_CARD, CRIPPLE_MOVEMENT, BOOST_MOVEMENT, DAMAGE_PLAYER_IN_WORLD, HEAL_PLAYER_IN_WORLD}

@export var usable_in_world: bool = false
@export var PrimaryEffect: Effect
@export var SecondaryEffect: Effect
@export var rarity: float = 0
@export var magnitude: float = 1

func get_primary_text():
	return (effect_names[PrimaryEffect] as String).replace('$', str(magnitude))
	
func get_secondary_text():
	return (effect_names[SecondaryEffect] as String).replace('$', str(magnitude))
	
func use_card(battle: Node2D):
	var callable = Callable(self, effect_funcs[PrimaryEffect])
	callable.call()
	
func damage_foe():
	pass
func ko_foe():
	pass
func heal_player():
	pass
func full_heal_player():
	pass
func damage_all_foe():
	pass
func freeze_foe():
	pass
func poison_foe():
	pass 
func player_invulnerable():
	pass
func boost_player_damage():
	pass
func boost_player_defense():
	pass
func cripple_foe_damage():
	pass
func cripple_foe_defense():
	pass
func reveal_random_secondary():
	pass
	# negative effects
func negate_card():
	pass
func damage_player():
	pass 
func heal_foe():
	pass
func full_heal_foe():
	pass 
func freeze_player():
	pass
func poison_player():
	pass
func foe_invulnerable():
	pass
func boost_foe_damage():
	pass
func boost_foe_defense():
	pass
func cripple_player_damage():
	pass 
func cripple_player_defense():
	pass
	# ambiguous effects
func end_battle():
	pass
func use_random_card():
	pass
func swap_card():
	pass
func bomb_in_battle():
	pass 
func full_heall_all():
	pass
	# world effects
func bomb_wall():
	pass
func unlock_door():
	pass
func give_battle_card():
	pass 
func cripple_movement():
	pass
func boost_movement():
	pass
func damage_player_in_world():
	pass
func heal_player_in_world():
	pass
