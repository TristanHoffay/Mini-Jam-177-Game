class_name CardData extends Resource
#
static var does_choose_enemy = [
	
#Positive:
			true,#Deal X damage to foe
			true, #Insta-kill enemy (extremely rare or has horrible secondary effect)
			false, #Heal X health to player
			false, #Fully heal player
			false, #Magic/sweep attack (damage all foes)
			true, #Freeze foe for X-Y turns
			true,#Poison foe at X degree (damage every turn)
			false, #Make player invulnerable for X-Y turns (should be low number)
			false, #Boost attack of player
			false,#Boost defense of player
			true,#Cripple attack of foe
			true,#Cripple defense of foe
			#Reveal secondary effect of random card
		#Negative:
			false,#Cancel effect of card (card is a dud)
			false,#Deal X damage to player
			true,#Heal X damage to foe
			true,#Fully heal foe
			false,#Freeze player for X-Y turns
			false,#Poison player at X degree (damage every turn)
			true,#Make foe invulnerable for X-Y turns (should be low number)
			true,#Boost attack of foe
			true,#Boost defense of foe
			false,#Cripple attack of player
			false,#Cripple defense of player
			#
		#Ambiguous:
			false,#End battle
			false,#Use random other card
			false,#Recycle card (replace with random new card)
			false,#Bomb (damage all enemies and self)
			false,#Fully heal all battle participants
			#
	#World:
		#Primary:
			false,#Bomb (open walls)
			false,#Unlock door
			false,#Give player new battle card
			#
		#Secondary:
			false,#Deal X damage to player
			false,#Slow movement speed by X
			false,#win
			false#restart
#
]
var date = Time.get_datetime_dict_from_system()
static var base_magnitudes = [
	#Positive:
			45, #Deal X damage to foe
			1,#Insta-kill enemy (extremely rare or has horrible secondary effect)
			50, #Heal X health to player
			1,#Fully heal player
			30, #Magic/sweep attack (damage all foes)
			2, #Freeze foe for X-Y turns
			15, #Poison foe at X degree (damage every turn)
			2, #Make player invulnerable for X-Y turns (should be low number)
			1.3,#Boost attack of player
			1.3,#Boost defense of player
			1,#Cripple attack of foe
			0.8,#Cripple defense of foe
			1,#Reveal secondary effect of random card
		#Negative:
			1,#Cancel effect of card (card is a dud)
			20,#Deal X damage to player
			15, #Heal X damage to foe
			1, #Fully heal foe
			1, #Freeze player for X-Y turns
			5, #Poison player at X degree (damage every turn)
			1, #Make foe invulnerable for X-Y turns (should be low number)
			1.2, #Boost attack of foe
			1.2, #Boost defense of foe
			0.85, #Cripple attack of player
			0.9,#Cripple defense of player
			#
		#Ambiguous:
			1,#End battle
			1,#Use random other card
			1,#Recycle card (replace with random new card)
			20, #Bomb (damage all enemies and self)
			1,#Fully heal all battle participants
			#
	#World:
		#Primary:
			0,#Bomb (open walls)
			0,#Unlock door
			0,#Give player new battle card
			#
		#Secondary:
			0,#Deal X damage to player
			0,#Slow movement speed by X
			0,#win
			0,#restart
]
static var effect_names = [
	"Deal $ damage to an enemy",
	"Insta-kill an enemy",
	"Heal yourself by $",
	"Fully heal yourself",
	"Deal $ damage to all enemies",
	"Freeze an enemy for $ turns",
	"Poison an enemy at level $",
	"Become invulnerable for $ turns",
	"Boost your damage dealt by $ times",
	"Boost your defense by $ times",
	"Cripple an enemy's attack by $ times",
	"Cripple an enemy's defense by $ times",
	"Reveal the hidden effect on a random one of your cards",
	#negative
	"This card does nothing (dud)\nToo bad!",
	"Take $ damage\nThat's gotta hurt!",
	"Heal an enemy by $\nThey appreciate it!",
	"Fully heal an enemy\nIt doesn't mean they'll go easier on you...",
	"Get frozen for $ turns\nMaybe the enemy will defeat itself!",
	"Get poisoned at level $\nBetter hurry!",
	"Enemy becomes invulnerable for $ turns\nHope you made this turn count!",
	"Boost an enemy's attack by $ times\nNow look what you've done!",
	"Boost an enemy's defense by $ times\nGood luck hitting now!",
	"Lower your damage dealt by $ times\nWhat's wrong?",
	"Cripple your defense by $ times\nLooks like you broke something!",
	# ambiguous
	"End the battle immediately\nLooks like you got out of this one",
	"Use another random card from your hand\nHope it's a good one!",
	"Swap this card out with a new one\nOther effect is void",
	"Bomb\nExplosion damages everyone in the battle",
	"Fully heal everyone in the battle\nRound 2!",
	# world effects
	"Bomb a crumbling wall to reveal an opening",
	"Unlock a door",
	"Redeem for one (1) new battle card\nExpires " ,
	"Cripple your movement speed by $ times\nAre we there yet?",
	"Boost your movement speed by $ times",
	"Take $ damage\nYou must've tripped",
	"Heal yourself by $",
	"Win the game\nThe true ending",
	"New Game Plus\nRestart with maxed out luck"
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
	'heal_player_in_world',
	'win_game',
	'restart_game']
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
	BOMB_WALL, UNLOCK_DOOR, GIVE_BATTLE_CARD, CRIPPLE_MOVEMENT, BOOST_MOVEMENT, DAMAGE_PLAYER_IN_WORLD, HEAL_PLAYER_IN_WORLD, WIN_GAME, RESTART_GAME}

@export var usable_in_world: bool = false
@export var choose_enemy: bool = false
@export var PrimaryEffect: Effect
@export var SecondaryEffect: Effect
@export var rarity: float = 0
@export var magnitude: float = 1
@export var magnitude_secondary: float = 1
var strength1:  float
var strength2: float

static func Generate_Card(luck: float): # luck -1 to 1, where 0 is normal randomness and 1 makes card luck top out at 1
	var newCard: CardData = CardData.new()
	var rare: float = 0
	luck = clamp(luck, -1,1)
	var card_luck: float = pow(randf(), 1-luck)
	print("luck " + str(luck))
	print("card luck " + str(card_luck))
	if card_luck < 0.02: # negative primary
		newCard.PrimaryEffect = randi_range(Effect.NEGATE_CARD, Effect.CRIPPLE_PLAYER_DEFENSE)
		rare -= 1
	elif card_luck < 0.1: # ambiguous primary
		newCard.PrimaryEffect = randi_range(Effect.END_BATTLE, Effect.FULL_HEALL_ALL)
		rare -= .1
	elif card_luck < 0.5: # damage foe
		newCard.PrimaryEffect == Effect.DAMAGE_FOE
		rare += .8
	elif card_luck <  0.6: # change stats
		newCard.PrimaryEffect = randi_range(Effect.BOOST_PLAYER_DAMAGE, Effect.REVEAL_RANDOM_SECONDARY)
		rare += .7
	else: # positive primary
		newCard.PrimaryEffect = randi_range(Effect.DAMAGE_FOE, Effect.PLAYER_INVULNERABLE)
		rare += 1
	var x = randf()
	var mag_mult
	if newCard.PrimaryEffect in [Effect.KO_FOE, Effect.FULL_HEAL_PLAYER, Effect.REVEAL_RANDOM_SECONDARY, 
	Effect.NEGATE_CARD, Effect.FULL_HEAL_FOE,
	Effect.END_BATTLE, Effect.USE_RANDOM_CARD, Effect.SWAP_CARD, Effect.FULL_HEALL_ALL]:
		mag_mult = 1
	else:
		if luck > 0:
			mag_mult = (1-luck)*(1+pow(x*2-1,3)) + luck * (2 + log(x)/log(10))
		else:
			mag_mult = (-luck*(1+pow(x*2-1,3))*x) + (1+luck)*(1+pow(x*2-1,3))
	newCard.magnitude = snapped(clampf(base_magnitudes[newCard.PrimaryEffect] * mag_mult, 0, 99999999), 0.001)
	print("rand " + str(x))
	print("magn times " + str(mag_mult))
	if newCard.PrimaryEffect == Effect.BOOST_PLAYER_DAMAGE or newCard.PrimaryEffect == Effect.BOOST_PLAYER_DEFENSE or newCard.PrimaryEffect == Effect.BOOST_FOE_DAMAGE or newCard.PrimaryEffect == Effect.BOOST_FOE_DEFENSE:
		newCard.magnitude = abs(newCard.magnitude-1)+1 # make sure it is over 1
	elif newCard.PrimaryEffect == Effect.CRIPPLE_FOE_DAMAGE or newCard.PrimaryEffect == Effect.CRIPPLE_FOE_DEFENSE or newCard.PrimaryEffect == Effect.CRIPPLE_PLAYER_DAMAGE or newCard.PrimaryEffect == Effect.CRIPPLE_PLAYER_DEFENSE:
		newCard.magnitude = (-abs(newCard.magnitude-1))+1 # make sure it is under 1
	
	newCard.choose_enemy = does_choose_enemy[newCard.PrimaryEffect]
	
	var card_luck2 = pow(randf(), 1-luck)
	print("card luck2 " + str(card_luck2))
	var rare2: float = 0
	if card_luck2 < 0.04: # negate card
		newCard.SecondaryEffect = Effect.NEGATE_CARD
		rare2 -= 1
	elif card_luck2 < 0.7: # negative secondary
		newCard.SecondaryEffect = randi_range(Effect.DAMAGE_PLAYER, Effect.CRIPPLE_PLAYER_DEFENSE)
		rare2 -= 1
	elif card_luck2 < 0.9: # ambiguous secondary
		newCard.SecondaryEffect = randi_range(Effect.END_BATTLE, Effect.FULL_HEALL_ALL)
		rare2 -= .1
	else: # positive secondary
		newCard.SecondaryEffect = randi_range(Effect.DAMAGE_FOE, Effect.REVEAL_RANDOM_SECONDARY)
		rare2 += 1
	x = randf()
	luck *= -1
	if newCard.SecondaryEffect in [Effect.KO_FOE, Effect.FULL_HEAL_PLAYER, Effect.REVEAL_RANDOM_SECONDARY, 
	Effect.NEGATE_CARD, Effect.FULL_HEAL_FOE,
	Effect.END_BATTLE, Effect.USE_RANDOM_CARD, Effect.SWAP_CARD, Effect.FULL_HEALL_ALL]:
		mag_mult = 1
	else:
		if luck > 0:
			mag_mult = (1-luck)*(1+pow(x*2-1,3)) + luck * (2 + log(x))
		else:
			mag_mult = (-luck*(1+pow(x*2-1,3))*x) + (1+luck)*(1+pow(x*2-1,3))
	newCard.magnitude_secondary = snapped(clampf(base_magnitudes[newCard.SecondaryEffect] * mag_mult, 0, 99999999), 0.001)
	print("rand2 " + str(x))
	print("magn2 times " + str(mag_mult))
	if newCard.SecondaryEffect == Effect.BOOST_PLAYER_DAMAGE or newCard.SecondaryEffect == Effect.BOOST_PLAYER_DEFENSE or newCard.SecondaryEffect == Effect.BOOST_FOE_DAMAGE or newCard.SecondaryEffect == Effect.BOOST_FOE_DEFENSE:
		newCard.magnitude_secondary = abs(newCard.magnitude_secondary-1)+1 # make sure it is over 1
	elif newCard.SecondaryEffect == Effect.CRIPPLE_FOE_DAMAGE or newCard.SecondaryEffect == Effect.CRIPPLE_FOE_DEFENSE or newCard.SecondaryEffect == Effect.CRIPPLE_PLAYER_DAMAGE or newCard.SecondaryEffect == Effect.CRIPPLE_PLAYER_DEFENSE:
		newCard.magnitude_secondary = (-abs(newCard.magnitude_secondary-1))+1 # make sure it is under 1
		
	rare *= clamp(newCard.magnitude/base_magnitudes[newCard.PrimaryEffect], 0, 2)/2
	print("rare " + str(rare))
	print("mult " + str(newCard.magnitude/base_magnitudes[newCard.PrimaryEffect]))
	rare2 *= clamp(newCard.magnitude_secondary/base_magnitudes[newCard.SecondaryEffect], 0, 2)/2
	print("mult2 " + str(newCard.magnitude_secondary/base_magnitudes[newCard.SecondaryEffect]))
	print("rare2 " + str(rare2))
	var combined_rare = max(0, rare + rare2)
	newCard.rarity = combined_rare
	newCard.strength1 = rare
	newCard.strength2 = rare2
	
	print(newCard.choose_enemy)
	print(effect_names[newCard.PrimaryEffect])
	print(effect_names[newCard.SecondaryEffect])
	print(newCard.rarity)
	print(newCard.magnitude)
	print(newCard.magnitude_secondary)
	return newCard

func get_primary_text():
	var mag_clamped = magnitude
	if PrimaryEffect in [Effect.HEAL_PLAYER, Effect.FREEZE_FOE, Effect.PLAYER_INVULNERABLE, Effect.FREEZE_PLAYER, Effect.FOE_INVULNERABLE, Effect.POISON_FOE, Effect.POISON_FOE]:
		mag_clamped = ceili(mag_clamped)
	return (effect_names[PrimaryEffect] as String).replace('$', str(mag_clamped))
	
func get_secondary_text():
	var mag_clamped = magnitude_secondary
	if SecondaryEffect in [Effect.HEAL_PLAYER, Effect.FREEZE_FOE, Effect.PLAYER_INVULNERABLE, Effect.FREEZE_PLAYER, Effect.FOE_INVULNERABLE, Effect.POISON_FOE, Effect.POISON_FOE]:
		mag_clamped = ceili(mag_clamped)
	return (effect_names[SecondaryEffect] as String).replace('$', str(mag_clamped))
	
func use_card(battle: Battle):
	if PrimaryEffect == Effect.NEGATE_CARD or SecondaryEffect == Effect.NEGATE_CARD:
		battle.dialog.add_line("The card vanished without doing a single thing...")
		await battle.wait(2.0)
		battle.do_enemy_turn()
	elif PrimaryEffect == Effect.SWAP_CARD or SecondaryEffect == Effect.SWAP_CARD:
		battle.dialog.add_line("Your card suddenly turned into a different one...")
		var luck = (magnitude + magnitude_secondary)/2
		if battle.player.newgame:
			luck = 1
		var newCardData = Generate_Card(luck)
		var newcard = battle.CARD.instantiate()
		newcard.card_data = newCardData
		newcard.battleScene = battle
		battle.cards.push_back(newcard)
		battle.hand.add_child(newcard)
		newcard.position.y = 1000
		newcard.scale = Vector2.ZERO
		await battle.wait(2.0)
		await battle.use_card(newcard)
	else:
		var eff1 = Callable(self, effect_funcs[PrimaryEffect])
		await eff1.call(battle, magnitude)
		# make sure enemies arent all dead
		if battle.enemies.size() < 1: return
		var eff2 = Callable(self, effect_funcs[SecondaryEffect])
		await eff2.call(battle, magnitude_secondary)
		# wait for input? or time?
		if PrimaryEffect != Effect.USE_RANDOM_CARD and SecondaryEffect != Effect.USE_RANDOM_CARD:
			battle.do_enemy_turn()
	
func damage_foe(battle: Battle, magn: float):
	var enemy = battle.enemies[battle.enemy_target]
	battle.hurt_enemy(enemy, magn * battle.damage_factor, false)
	
func ko_foe(battle: Battle, magn: float):
	battle.enemy_dead(battle.enemies[battle.enemy_target])
func heal_player(battle: Battle, magn: float):
	battle.heal_player(magn)
func full_heal_player(battle: Battle, magn: float):
	battle.heal_player(9999999) #should be enough, right?
func damage_all_foe(battle: Battle, magn: float):
	for enemy in battle.enemies:
		battle.hurt_enemy(enemy, magn * battle.damage_factor, false)
		await battle.wait(1.5)
func freeze_foe(battle: Battle, magn: float):
	var enemy = battle.enemies[battle.enemy_target]
	enemy.freeze(ceili(magn))
	battle.dialog.add_line(enemy.data.name + " was frozen for the next " + str(ceili(magn)) + " turns!")
	await battle.wait(1.5)
func poison_foe(battle: Battle, magn: float):
	var enemy = battle.enemies[battle.enemy_target]
	enemy.poison(ceili(magn))
	battle.dialog.add_line(enemy.data.name + " was poisoned at level " + str(ceili(magn)) + "!")
	await battle.wait(1.5)
func player_invulnerable(battle: Battle, magn: float):
	battle.player_invuln_turns = ceili(magn)
	battle.dialog.add_line("You are now invulnerable for " + str(ceili(magn)) + " turns!")
	await battle.wait(1.5)
func boost_player_damage(battle: Battle, magn: float):
	battle.damage_factor *= magn
	battle.dialog.add_line("Your damage output has been boosted by " + str(magn) + " times!")
	await battle.wait(1.5)
func boost_player_defense(battle: Battle, magn: float):
	battle.defense_factor *= magn
	battle.dialog.add_line("Your defense was fortified by " + str(magn) + " times!")
	await battle.wait(1.5)
func cripple_foe_damage(battle: Battle, magn: float):
	var enemy = battle.enemies[battle.enemy_target]
	enemy.attack_factor *= magn
	battle.dialog.add_line(enemy.data.name + "'s attack power was weakened by " + str(magn) + " times!")
	await battle.wait(1.5)
func cripple_foe_defense(battle: Battle, magn: float):
	var enemy = battle.enemies[battle.enemy_target]
	enemy.health.defense *= magn
	battle.dialog.add_line(enemy.data.name + "'s defense was crippled by " + str(magn) + " times!")
	await battle.wait(1.5)
func reveal_random_secondary(battle: Battle, magn: float):
	await battle.wait(1)
	if battle.cards.size() > 0:
		var i = randi_range(0, battle.cards.size()-1)
		battle.cards[i].reveal_secondary()
		battle.dialog.add_line("Revealed the hidden effect of a card!")
	# negative effects
func negate_card(battle: Battle, magn: float):
	pass # doesnt need to be called? logic for negated card is inside use_card()
func damage_player(battle: Battle, magn: float):
	battle.hurt_player(magn, true) 
func heal_foe(battle: Battle, magn: float):
	battle.heal_enemy(null, magn)
func full_heal_foe(battle: Battle, magn: float):
	battle.heal_enemy(null, 99999999)
func freeze_player(battle: Battle, magn: float):
	battle.player_frozen_turns = ceili(magn)
	battle.dialog.add_line("You were frozen for the next " + str(ceili(magn)) + " turns!")
	await battle.wait(1.5)
func poison_player(battle: Battle, magn: float):
	battle.player_poisoning = ceili(magn)
	battle.dialog.add_line("You were poisoned at level " + str(ceili(magn)) + "!")
	await battle.wait(1.5)
func foe_invulnerable(battle: Battle, magn: float):
	var enemy
	if battle.enemies.size() < 1:
		return
	if battle.enemy_target < battle.enemies.size():
		if battle.enemies[battle.enemy_target]:
			enemy = battle.enemies[battle.enemy_target]
		else:
			enemy = battle.enemies[0]
	if enemy:
		enemy.invuln_turns = ceili(magn)
		battle.dialog.add_line(enemy.data.name + " is now invulnerable for " + str(ceili(magn)) + " turns!")
		await battle.wait(1.5)
func boost_foe_damage(battle: Battle, magn: float):
	if battle.enemies.size() < 1:
		return
	var enemy
	if battle.enemy_target < battle.enemies.size():
		enemy = battle.enemies[battle.enemy_target]
	else:
		enemy = battle.enemies[randi_range(0,battle.enemies.size()-1)]
	enemy.attack_factor *= magn
	battle.dialog.add_line(enemy.data.name + "'s attack power was strengthened by " + str(magn) + " times!")
func boost_foe_defense(battle: Battle, magn: float):
	if battle.enemies.size() < 1:
		return
	var enemy
	if battle.enemy_target < battle.enemies.size():
		enemy = battle.enemies[battle.enemy_target]
	else:
		enemy = battle.enemies[randi_range(0,battle.enemies.size()-1)]
	enemy.health.defense *= magn
	battle.dialog.add_line(enemy.data.name + "'s defense was fortified by " + str(magn) + " times!")
func cripple_player_damage(battle: Battle, magn: float):
	battle.damage_factor *= magn
	battle.dialog.add_line("Your damage output has been weakened by " + str(magn) + " times!")
	await battle.wait(1.5)
func cripple_player_defense(battle: Battle, magn: float):
	battle.defense_factor *= magn
	battle.dialog.add_line("Your defense was crippled by " + str(magn) + " times!")
	await battle.wait(1.5)
	# ambiguous effects
func end_battle(battle: Battle, magn: float):
	battle.dialog.add_line("Say goodbye! The battle is over now.")
	await battle.wait(2)
	battle.end_battle()
func use_random_card(battle: Battle, magn: float):
	await battle.wait(1)
	if battle.cards.size() > 0:
		var i = randi_range(0, battle.cards.size()-1)
		var card = battle.cards[i]
		card.goal_pos.y -= 150
		battle.dialog.add_line("You used another card!")
		await battle.wait(2.0)
		await battle.use_card(card)
	else:
		battle.dialog.add_line("You have no other cards to use!")
		battle.do_enemy_turn()
func swap_card(battle: Battle, magn: float):
	pass # this is also done in use_card() since it cancels the other effect
func bomb_in_battle(battle: Battle, magn: float):
	battle.dialog.add_line("Your card burst into a fiery explosion!")
	await battle.wait(1)
	battle.hurt_player(magn, true) 
	for enemy in battle.enemies:
		battle.hurt_enemy(enemy, magn * battle.damage_factor, false)
		await battle.wait(1.5)
func full_heall_all(battle: Battle, magn: float):
	battle.heal_player(9999999)
	for enemy in battle.enemies:
		battle.heal_enemy(enemy, 9999999)
	# world effects
func bomb_wall(battle: Battle, magn: float):
	pass
func unlock_door(battle: Battle, magn: float):
	pass
func give_battle_card(battle: Battle, magn: float):
	pass 
func cripple_movement(battle: Battle, magn: float):
	pass
func boost_movement(battle: Battle, magn: float):
	pass
func damage_player_in_world(battle: Battle, magn: float):
	pass
func heal_player_in_world(battle: Battle, magn: float):
	pass
func win_game(battle: Battle, magn: float):
	battle.win_game()
func restart_game(battle: Battle, magn: float):
	pass
