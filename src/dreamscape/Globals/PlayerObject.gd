class_name Player
extends Reference

var health: int = 90 setget set_health
var damage: int setget set_damage
var deck: Deck

var deck_groups : Dictionary = {
	Terms.CARD_GROUP_TERMS.class: null,
	Terms.CARD_GROUP_TERMS.race: null,
	Terms.CARD_GROUP_TERMS.item: null,
	Terms.CARD_GROUP_TERMS.life_goal: null,
}

func is_deck_completed() -> bool:
	for archetype in deck_groups:
		if not deck_groups[archetype]:
			return(false)
	return(true)

func setup() -> void:
	deck = Deck.new(deck_groups)
	for group in deck_groups:
		# Each deck group can modify the player's max health
		health += CardGroupDefinitions[group.to_upper()][deck_groups[group]].get(Terms.PLAYER_TERMS.health,0)
	deck.assemble_starting_deck()

func get_currrent_archetypes() -> Array:
	var all_archetypes := []
	for aspect in deck_groups:
		if deck_groups[aspect]:
			all_archetypes.append(deck_groups[aspect])
	return(all_archetypes)

func set_damage(value) -> void:
	damage = int(round(value))
	if damage > health: 
		damage = health
	elif damage < 0:
		damage = 0

func set_health(value) -> void:
	health = int(round(value))
	if health < 0:
		health = 0
	if damage > health: 
		damage = health
