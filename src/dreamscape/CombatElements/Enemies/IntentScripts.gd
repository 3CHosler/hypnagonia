class_name IntentScripts
extends Resource

const ICON_ATTACK := preload("res://assets/icons/terror.png")
const ICON_PIERCE := preload("res://assets/icons/pierced-heart.png")
const ICON_DEFEND := preload("res://assets/icons/shield.png")
const ICON_DEBUFF := preload("res://assets/icons/cursed-star.png")
const ICON_BUFF := preload("res://assets/icons/growth.png")
const ICON_SPECIAL := preload("res://assets/icons/uncertainty.png")

const KNOWN_ICONS := {
	"icon_attack" : ICON_ATTACK,
	"icon_pierce" : ICON_PIERCE,
	"icon_defend" : ICON_DEFEND,
	"icon_debuff" : ICON_DEBUFF,
	"icon_buff" : ICON_BUFF,
	"icon_special" : ICON_SPECIAL,
}

# This approach allows me to use this class both statically, 
# as well as a resource, which enables me to switch icons around when needed.
# Special enemies etc
export(StreamTexture) var icon_attack := ICON_ATTACK
export(StreamTexture) var icon_pierce := ICON_PIERCE
export(StreamTexture) var icon_defend := ICON_DEFEND
export(StreamTexture) var icon_debuff := ICON_DEBUFF
export(StreamTexture) var icon_buff := ICON_BUFF
export(StreamTexture) var icon_special := ICON_SPECIAL

var resource_icons := {
	"icon_attack" : icon_attack,
	"icon_pierce" : icon_pierce,
	"icon_defend" : icon_defend,
	"icon_debuff" : icon_debuff,
	"icon_buff" : icon_buff,
	"icon_special" : icon_special,
}


const STRESS := [
	{
		"name": "modify_damage",
		"tags": ["Attack", "Intent"],
		"subject": "dreamer",
		"amount": null,
		"icon": "icon_attack",
		"description": "Stress: Will cause the dreamer to take the specified amount of {anxiety}."
	}
]
const PERPLEX := [
	{
		"name": "assign_defence",
		"tags": ["Intent"],
		"subject": "self",
		"amount": null,
		"icon": "icon_defend",
		"description": "Perplex: Will give this Torment the specified amount of {perplexity}."
	}
]
const PERPLEX_GROUP := [
	{
		"name": "assign_defence",
		"tags": ["Intent"],
		"subject": "boardseek",
		"amount": null,
		"subject_count": "all",
		"filter_state_seek": [{
			"filter_group": "EnemyEntities",
		},],
		"icon": "icon_defend",
		"description": "Perplex Group: Will give all Torments the specified amount of {perplexity}."
	}
]
const DEBUFF := [
	{
		"name": "apply_effect",
		"effect_name": null,
		"tags": ["Intent", "Delayed"],
		"subject": "dreamer",
		"modification": null,
		"icon": "icon_debuff",
		"description": "This Torment is planning to apply a debuff to the Dreamer."
	}
]
const BUFF := [
	{
		"name": "apply_effect",
		"effect_name": null,
		"tags": ["Intent"],
		"subject": "self",
		"modification": null,
		"icon": "icon_buff",
		"description": "This Torment is planning to buff itself."
	}
]
const BUFF_GROUP := [
	{
		"name": "apply_effect",
		"effect_name": null,
		"tags": ["Intent"],
		"subject": "boardseek",
		"modification": null,
		"subject_count": "all",
		"filter_state_seek": [{
			"filter_group": "EnemyEntities",
		},],
		"icon": "icon_buff",
		"description": "This Torment is planning to buff all Torments."
	}
]
const STARE := [
	{
		"name": "perturb",
		"card_name": "Dread",
		"dest_container": "discard",
		"object_count": 1,
		"tags": ["Intent"],
		"icon": preload("res://assets/icons/alien-stare.png"),
		"description": "Stare: [i]It's not blinking...[/i]"
	}
]
const DELIGHT := [
	{
		"name": "apply_effect",
		"effect_name": Terms.ACTIVE_EFFECTS.delighted.name,
		"subject": "dreamer",
		"modification": 1,
		"tags": ["Intent", "Delayed"],
		"icon": preload("res://assets/icons/smitten.png"),
		"description": "Delightful: [i]Aww, it's adorable![/i]"
	}
]
const LETHARGY := [
	{
		"name": "apply_effect",
		"effect_name": Terms.ACTIVE_EFFECTS.drain.name,
		"subject": "dreamer",
		"modification": null,
		"show_modification_in_intent": true,
		"tags": ["Intent"],
		"icon": preload("res://assets/icons/shrug.png"),
		"description": "Lethargy: Next turn you will have this amount less {immersion}\n"\
				+ "[i]I need to see behind it...[/i]"
	}
]
const EVIDENT := [
	{
		"name": "modify_damage",
		"tags": ["Unblockable", "Intent"],
		"subject": "self",
		"amount": null,
		"icon": preload("res://assets/icons/spectacle-lenses.png"),
		"description": "Evident: This will cause this Torment the specified amount of {damage}."
	}
]
const FRUSTRATE := [
	{
		"name": "modify_pathos",
		"tags": ["Intent"],
		"pathos": Terms.RUN_ACCUMULATION_NAMES.enemy,
		"pathos_type": "repressed",
		"amount": null,
		"icon": preload("res://assets/icons/traffic-cone.png"),
		"description": "Frustrate: This will increase the dreamer's repressed frustration by the shown amount.\n"\
				+ "[i]Every day the same deal...[/i]"
	}
]
const DISHEARTEN := [
	{
		"name": "modify_pathos",
		"tags": ["Intent"],
		"pathos": Terms.RUN_ACCUMULATION_NAMES.enemy,
		"pathos_type": "released",
		"amount": null,
		"icon": preload("res://assets/icons/traffic-cone.png"),
		"description": "Dishearten: This will decrease the dreamer's released frustration by the shown amount.\n"\
				+ "[i]I'll never make it in time...[/i]"
	}
]
const UNFOCUS := [
	{
		"name": "apply_effect",
		"effect_name": Terms.ACTIVE_EFFECTS.strengthen.name,
		"subject": "self",
		"modification": "per_effect_stacks",
		"per_effect_stacks": {
			"subject": "self",
			"effect_name": Terms.ACTIVE_EFFECTS.rebalance.name,
			"is_inverted": true,
		},
		"tags": ["Intent"],
		"icon": preload("res://assets/icons/uncertainty.png"),
		"description": "Unfocus: [i]Somehow this doesn't feel as important as it first appeared...[/i]"
	}
]
const PENCILS_READY := [
	{
		"name": "apply_effect",
		"effect_name": Terms.ACTIVE_EFFECTS.the_exam.name,
		"subject": "dreamer",
		"modification": "per_effect_stacks",
		"per_effect_stacks": {
			"subject": "self",
			"effect_name": Terms.ACTIVE_EFFECTS.rebalance.name,
		},
		"tags": ["Intent"],
		"icon": preload("res://assets/icons/pencil.png"),
		"description": "Pencils Ready: [i]I could feel the teacher's eyes hovering over me.[/i]"
	}
]
const MEMORY_FAILING := [
	{
		"name": "move_card_to_container",
		"subject": "index",
		"subject_index": "random",
		"src_container": "hand",
		"dest_container": "forgotten",
		"tags": ["Intent"],
		"icon": preload("res://assets/icons/uncertainty.png"),
		"description": "Memory Failing: [i]I know I had studied this. What was it...[/i]"
	},
]
const INCREASE_COMPLEXITY := [
	{
		"name": "modify_damage",
		"tags": ["Attack", "Intent"],
		"subject": "dreamer",
		"store_integer": true,
		"amount": 10,
		"icon": "icon_attack",
		"description": "Stress: Will cause the dreamer to take the specified amount of {anxiety}."
	},
	{
		"name": "modify_damage",
		"tags": ["Healing", "Intent"],
		"subject": "self",
		"amount": "retrieve_integer",
		"is_inverted": true,
		"hide_amount_in_intent": true,
		"icon": "icon_special",
		"description": "Increase Complexity: [i]I felt I was losing understanding of the situation.[/i]"
	},
]

const GUT := [
	{
		"name": "null_script",
		"tags": ["GUT", "Intent"],
		"icon": "icon_special",
		"description": "GUT Testing"
	}
]

func get_scripts(intent_name: String) -> Dictionary:
	var scripts := {
		"Stress": STRESS,
		"Perplex": PERPLEX,
		"PerplexGroup": PERPLEX_GROUP,
		"Debuff": DEBUFF,
		"Buff": BUFF,
		"BuffGroup": BUFF_GROUP,
		"Stare": STARE,
		"Delight": DELIGHT,
		"Lethargy": LETHARGY,
		"Evident": EVIDENT,
		"Frustrate": FRUSTRATE,
		"Dishearten": DISHEARTEN,
		"Unfocus": UNFOCUS,
		"Pencils Ready": PENCILS_READY,
		"Memory Failing": MEMORY_FAILING,
		"Increase Complexity": INCREASE_COMPLEXITY,
		# Unit Testing #
		"GUT": GUT,
	}
	# If the icon is a string, then it's format form.
	var intents_array = scripts.get(intent_name,{}).duplicate(true)
	for intent_def in intents_array:
		if intent_def.has("icon") and typeof(intent_def["icon"]) == TYPE_STRING:
			if resource_icons.has(intent_def["icon"]):
				intent_def["icon"] = resource_icons[intent_def["icon"]]
			elif KNOWN_ICONS.has(intent_def["icon"]):
				intent_def["icon"] = KNOWN_ICONS[intent_def["icon"]]
			else:
				printerr("WARNING:IntentScripts: Icon key '%s' could not be found. Defaulting to special icon" % [intent_def["icon"]])
				intent_def["icon"] = KNOWN_ICONS["icon_special"]
	return(intents_array)
