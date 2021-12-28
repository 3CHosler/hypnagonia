# Provides the metadata for each memory. Their script is contained within
# The script file with the same name under "res://src/dreamscape/Memories/"
# Each memory has an "amounts" key which is used populate both description
# and script. This allows us in the future to quickly tweak values without
# having to change multiple places
class_name MemoryDefinitions
extends Reference

# Defines when an artifact's effects are active.
# This allows us to know when to trigger artifact effects.
enum EffectContext {
	# This artifact's effects are active only outside battle
	OVERWORLD
	# This artifact's effects are active only during a battle
	BATTLE
	# This artifact triggers its effect only in the shop
	SHOP
}

"""
Keys:

* pathos: Which pathos is used to fill up this memory
* pathos_threshold_multiplier (default: 1): Normally the amount of pathos needed to fill up a memory is equal to
   the average progression for that pathos. This multiplier multiplies the amount of pathos needed to
   fill up that memory by this much. So e.g. with a multiplier of 2, frustration will go from needing 15 to fill up
   to needing 30.
* pathos_accumulation_divider (default: 2): If you want to increase the time taken to fill up a memory without increasing
   how much pathos will be used to do so, use this value. If used, the amount "sucked"
   from the memory any time pathos is released (typically the accumulation average), will be divided by this amount.
   Careful: A value of 1, means no released pathos will be accumulated while this memory is empty!

With a pathos_threshold_multiplier and a pathos_accumulation_divider of 2 each, on average
A memory will fill up every 4 encounters of that type. Typically you want these numbers to be higher
for common encounters like Enemies, and lower for rare encounters like elites.
In general, you want to aim for a memory to refill every 4-6 encounters
"""

const DamageAll := {
	"canonical_name": "DamageAll",
	"name": "The Big Fight",
	"description": "{memory_name} ({upgrades}): Recall this memory during an Ordeal to {damage} all torments for {damage_amount}",
	"upgrade_description": "Each upgrade on this memory increases its {damage} by {upgrade_multiplier}",
	"icon": preload("res://assets/icons/memories/portrait.png"),
	"context": EffectContext.BATTLE,
	"pathos": Terms.RUN_ACCUMULATION_NAMES.enemy,
	"pathos_threshold_multiplier": 2,
	"pathos_accumulation_divider": 1.8,
	"keys_modified_by_upgrade": ["damage_amount"],
	"amounts": {
		"damage_amount": 10,
		"upgrade_multiplier": 1
	},
}
const HealSelf := {
	"canonical_name": "HealSelf",
	"name": "Mother's Comfort",
	"description": "{memory_name} ({upgrades}): Recall this memory during an Ordeal to reduce your {anxiety} by {heal_amount}",
	"upgrade_description": "Each upgrade on this memory increases its reduced {anxiety} by {upgrade_multiplier}",
	"icon": preload("res://assets/icons/memories/portrait.png"),
	"context": EffectContext.BATTLE,
	"pathos": Terms.RUN_ACCUMULATION_NAMES.rest,
	"pathos_threshold_multiplier": 2,
	"pathos_accumulation_divider": 2.5,
	"keys_modified_by_upgrade": ["heal_amount"],
	"amounts": {
		"heal_amount": 5,
		"upgrade_multiplier": 1
	},
}
const BossFaster := {
	"canonical_name": "BossFaster",
	"name": "A Sense of Closure",
	"description": "{memory_name} ({upgrades}): Recall this memory during the Dream Journal "\
			+ "to increased your repressed %s by {pathos_amount}" % [Terms.RUN_ACCUMULATION_NAMES.boss],
	"upgrade_description": "Each upgrade on this memory increases the repressed %s gained by {upgrade_multiplier}" % [Terms.RUN_ACCUMULATION_NAMES.boss],
	"icon": preload("res://assets/icons/memories/portrait.png"),
	"context": EffectContext.OVERWORLD,
	"pathos": Terms.RUN_ACCUMULATION_NAMES.elite,
	"keys_modified_by_upgrade": ["pathos_amount"],
	"amounts": {
		"pathos_amount": 5,
		"upgrade_multiplier": 2
	},
}
const ProgressRandom := {
	"canonical_name": "ProgressRandom",
	"name": "ProgressRandom",
	"description": "{memory_name} ({upgrades}): Recall this memory during the Dream Journal to progress a random card by {progress_amount}",
	"upgrade_description": "Each upgrade on this memory increases its progress by {upgrade_multiplier}",
	"icon": preload("res://assets/icons/memories/portrait.png"),
	"context": EffectContext.OVERWORLD,
	"pathos": Terms.RUN_ACCUMULATION_NAMES.shop,
	"keys_modified_by_upgrade": ["progress_amount"],
	"amounts": {
		"progress_amount": 2,
		"upgrade_multiplier": 1
	},
}
const SpikeEnemy := {
	"canonical_name": "SpikeEnemy",
	"name": "Childhood Curiosity",
	"description": "{memory_name} ({upgrades}): Recall this memory during an Ordeal to {damage} one torment for {damage_amount}",
	"upgrade_description": "Each upgrade on this memory increases its {damage} by {upgrade_multiplier}",
	"icon": preload("res://assets/icons/memories/portrait.png"),
	"context": EffectContext.BATTLE,
	"pathos": Terms.RUN_ACCUMULATION_NAMES.nce,
	"pathos_threshold_multiplier": 2.5,
	"keys_modified_by_upgrade": ["damage_amount"],
	"amounts": {
		"damage_amount": 20,
		"upgrade_multiplier": 1
	},
}
const FortifySelf := {
	"canonical_name": "FortifySelf",
	"name": "Stand Against a Bully",
	"description": "{memory_name} ({upgrades}/{max_upgrades}): Recall this memory during an Ordeal to gain {effect_stacks} {fortify}",
	"upgrade_description": "Each upgrade on this memory decreases the cost to fill up this memory. It can only be upgraded up to {max_upgrades} times.",
	"icon": preload("res://assets/icons/memories/portrait.png"),
	"context": EffectContext.BATTLE,
	"pathos": Terms.RUN_ACCUMULATION_NAMES.elite,
	"keys_modified_by_upgrade": ["pathos_threshold_multiplier"],
	"amounts": {
		"effect_stacks": 1,
		"upgrade_multiplier": 0.1,
		"max_upgrades": 5,
	},
}

# Generic memories which have a chance to appear in any playthrough
const GENERIC := [
	DamageAll,
	HealSelf,
	BossFaster,
	ProgressRandom,
	SpikeEnemy,
	FortifySelf,
]

# Archetype-specific memories which only appear in runs in which
# Their tied archetype is selected.
const ARCHETYPE := [
]

# These memories are only found in non-combat encounters
const ENCOUNTER := [
]


static func get_memories(
	archetype_memories := [],
	excluded_memories := []) -> Array:
	var ret_array := []
	for memory in GENERIC + archetype_memories:
		if not memory.canonical_name in excluded_memories:
			ret_array.append(memory)
	return(ret_array)


static func get_memory_bbcode_format(memory_definition: Dictionary, upgrades := 0) -> Dictionary:
	var format := {}
	format['memory_name'] = memory_definition.name
	format['upgrades'] = upgrades + 1
	for key in memory_definition.get('amounts', {}):
		var upgrade_modifier := 0
		if key in memory_definition.get("keys_modified_by_upgrade",[]) and upgrades > 0:
			upgrade_modifier = upgrades * memory_definition.amounts["upgrade_multiplier"]
		var amount = memory_definition.amounts[key] + upgrade_modifier
		format[key] = amount
	return(format)


static func get_complete_memories_array() -> Array:
	return(GENERIC + ARCHETYPE + ENCOUNTER)


static func find_memory_from_canonical_name(memory_canonical_name: String):
	for definition in get_complete_memories_array():
		if definition.canonical_name == memory_canonical_name:
			return(definition)


static func find_memory_from_name(memory_name: String):
	for definition in get_complete_memories_array():
		if definition.name == memory_name:
			return(definition)
