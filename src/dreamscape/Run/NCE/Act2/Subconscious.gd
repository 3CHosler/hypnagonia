# Gives three choices to gain pathos. Each with increasing amount of anxiety gained

extends NonCombatEncounter

const DAMAGE_AMOUNT := 7

var secondary_choices := {
		'intrerpret': '[intrerpret]: Take {damage_amount} {anxiety}. Gain {subconscious}',
		'avoid': '[avoid]: Gain {lowest_pathos_amount} released {lowest_pathos}.',
	}
	
var nce_result_fluff := {
		'intrerpret': '<Intrerpret Choice Result - Story Fluff to be Done>',
		'avoid': '<Avoid Choice Result - Story Fluff to be Done>',
	}

var lowest_pathos: String
var lowest_pathos_amount: float

func _init():
	description = "<Subconscious - Story Fluff to be Done>. Select one Option...."

func begin() -> void:
	.begin()
	var pathos_org = globals.player.pathos.get_pathos_org("released", true)
	lowest_pathos = pathos_org["lowest_pathos"]["selected"]
	lowest_pathos_amount = round(globals.player.pathos.get_progression_average(lowest_pathos)\
			* 9 * CFUtils.randf_range(0.8,1.2))
	var scformat = {
		"lowest_pathos": lowest_pathos,
		"lowest_pathos_amount":  lowest_pathos_amount,
		"damage_amount":  DAMAGE_AMOUNT,
		"subconscious": _prepare_card_popup_bbcode("Subconscious", " an insight into your own mind."),
	}
	secondary_choices['intrerpret'] = secondary_choices['intrerpret'].format(scformat).format(Terms.get_bbcode_formats(18))
	secondary_choices['avoid'] = secondary_choices['avoid'].format(scformat).format(Terms.get_bbcode_formats(18))
	globals.journal.add_nested_choices(secondary_choices)

func continue_encounter(key) -> void:
	match key:
		"avoid":
			globals.player.pathos.modify_released_pathos(lowest_pathos, lowest_pathos_amount)
		"intrerpret":
			# warning-ignore:return_value_discarded
			globals.player.damage += DAMAGE_AMOUNT
			globals.player.deck.add_new_card("Subconscious")
	end()
	globals.journal.display_nce_rewards(nce_result_fluff[key])
