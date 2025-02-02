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
@export var choose_enemy: bool = false
@export var PrimaryEffect: Effect
@export var SecondaryEffect: Effect
@export var rarity: float = 0
@export var magnitude: float = 1
@export var magnitude_secondary: float = 1

static func Generate_Card(luck: float):
	var newCard: CardData = CardData.new()
	newCard.PrimaryEffect = Effect.DAMAGE_FOE
	newCard.SecondaryEffect = Effect.HEAL_PLAYER
	newCard.magnitude = 17
	newCard.magnitude_secondary = 8
	return newCard

func get_primary_text():
	return (effect_names[PrimaryEffect] as String).replace('$', str(magnitude))
	
func get_secondary_text():
	return (effect_names[SecondaryEffect] as String).replace('$', str(magnitude_secondary))
	
func use_card(battle: Battle):
	if PrimaryEffect == Effect.NEGATE_CARD or SecondaryEffect == Effect.NEGATE_CARD:
		battle.dialog.add_line("The card vanished without doing a single thing...")
		await battle.wait(2.0)
	elif PrimaryEffect == Effect.SWAP_CARD or SecondaryEffect == Effect.SWAP_CARD:
		battle.dialog.add_line("Your card suddenly turned into a different one...")
		var newCardData = Generate_Card((magnitude + magnitude_secondary)/2)
		var newcard = battle.CARD.instantiate()
		newcard.card_data = newCardData
		newcard.battleScene = battle
		battle.cards.push_back(newcard)
		battle.hand.add_child(newcard)
		newcard.position.y = 1000
		await battle.use_card(newcard)
		await battle.wait(2.0)
	else:
		var eff1 = Callable(self, effect_funcs[PrimaryEffect])
		await eff1.call(battle, magnitude)
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
	enemy.freeze(magn)
	battle.dialog.add_line(enemy.data.name + " was frozen for the next " + str(magn) + " turns!")
	await battle.wait(1.5)
func poison_foe(battle: Battle, magn: float):
	var enemy = battle.enemies[battle.enemy_target]
	enemy.poison(ceili(magn))
	battle.dialog.add_line(enemy.data.name + " was poisoned at level " + str(magn) + "!")
	await battle.wait(1.5)
func player_invulnerable(battle: Battle, magn: float):
	battle.player_invuln_turns = ceili(magn)
	battle.dialog.add_line("You are now invulnerable for " + str(ceili(magn)) + " turns!")
	await battle.wait(1.5)
func boost_player_damage(battle: Battle, magn: float):
	battle.damage_factor *= magn
	battle.dialog.add_line("Your damage output has been booseted by " + str(magn) + " times!")
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
	var i = randi_range(0, battle.cards.size()-1)
	battle.cards[i].reveal_secondary()
	battle.dialog.add_line("Revealed the hidden effect of a card!")
	# negative effects
func negate_card(battle: Battle, magn: float):
	pass # doesnt need to be called? logic for negated card is inside use_card()
func damage_player(battle: Battle, magn: float):
	battle.hurt_player(magn, true) 
func heal_foe(battle: Battle, magn: float):
	battle.heal_enemy(magn)
func full_heal_foe(battle: Battle, magn: float):
	battle.heal_enemy(99999999)
func freeze_player(battle: Battle, magn: float):
	battle.player_frozen_turns = floori(magn)
	battle.dialog.add_line("You were frozen for the next " + str(magn) + " turns!")
	await battle.wait(1.5)
func poison_player(battle: Battle, magn: float):
	battle.player_poisoning = ceili(magn)
	battle.dialog.add_line("You were poisoned at level " + str(magn) + "!")
	await battle.wait(1.5)
func foe_invulnerable(battle: Battle, magn: float):
	var enemy = battle.enemies[battle.enemy_target]
	enemy.invuln_turns = ceili(magn)
	battle.dialog.add_line(enemy.data.name + " is now invulnerable for " + str(ceili(magn)) + " turns!")
	await battle.wait(1.5)
func boost_foe_damage(battle: Battle, magn: float):
	var enemy = battle.enemies[battle.enemy_target]
	enemy.attack_factor *= magn
	battle.dialog.add_line(enemy.data.name + "'s attack power was strengthened by " + str(magn) + " times!")
func boost_foe_defense(battle: Battle, magn: float):
	var enemy = battle.enemies[battle.enemy_target]
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
	pass 
func full_heall_all(battle: Battle, magn: float):
	pass
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
