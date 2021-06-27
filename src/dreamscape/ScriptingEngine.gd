#class_name DreamscapeScriptingEngine
extends ScriptingEngine

# Just calls the parent class.
func _init(state_scripts: Array,
		owner,
		_trigger_object: Node,
		_trigger_details: Dictionary).(state_scripts,
		owner,
		_trigger_object,
		_trigger_details) -> void:
	pass


func predict() -> void:
	run_type = CFInt.RunType.COST_CHECK
	var prev_subjects := []
	for task in scripts_queue:
		# We put it into another variable to allow Static Typing benefits
		var script: ScriptTask = task
		# We store the temp modifiers to counters, so that things like
		# info during targetting can take them into account
		cfc.NMAP.board.counters.temp_count_modifiers[self] = {
				"requesting_object": script.owner,
				"modifier": _retrieve_temp_modifiers(script,"counters")
			}
		# This is provisionally stored for games which need to use this
		# information before card subjects have been selected.
		cfc.card_temp_property_modifiers[self] = {
			"requesting_object": script.owner,
			"modifier": _retrieve_temp_modifiers(script, "properties")
		}
		script.subjects = predict_subjects(script, prev_subjects)
		prev_subjects = script.subjects
		#print("Scripting Subjects: " + str(script.subjects)) # Debug
		if script.script_name == "custom_script": # TODO
			# This class contains the customly defined scripts for each
			# card.
			var custom := CustomScripts.new(costs_dry_run())
			custom.custom_script(script)
		for entity in script.subjects:
#				entity.temp_properties_modifiers[self] = {
#					"requesting_object": script.owner,
#					"modifier": _retrieve_temp_modifiers(script, "properties")
#				}
			var prediction_method = "calculate_" + script.script_name
			if has_method(prediction_method):
				var amount = call(prediction_method, entity, script)
				if amount is GDScriptFunctionState:
					amount = yield(amount, "completed")
				entity.show_predictions(amount)

# Will return the adjusted amount of whatever the scripts are doing
# if there is one.
func predict_intent_amount() -> int:
	run_type = CFInt.RunType.COST_CHECK
	var total_amount := 0
	var prev_subjects := []
	for task in scripts_queue:
		# We put it into another variable to allow Static Typing benefits
		var script: ScriptTask = task
		# We store the temp modifiers to counters, so that things like
		# info during targetting can take them into account
		cfc.NMAP.board.counters.temp_count_modifiers[self] = {
				"requesting_object": script.owner,
				"modifier": _retrieve_temp_modifiers(script,"counters")
			}
		# This is provisionally stored for games which need to use this
		# information before card subjects have been selected.
		cfc.card_temp_property_modifiers[self] = {
			"requesting_object": script.owner,
			"modifier": _retrieve_temp_modifiers(script, "properties")
		}
		script.subjects = predict_subjects(script, prev_subjects)
		prev_subjects = script.subjects
		#print("Scripting Subjects: " + str(script.subjects)) # Debug
		if script.script_name == "custom_script": # TODO
			# This class contains the customly defined scripts for each
			# card.
			var custom := CustomScripts.new(costs_dry_run())
			custom.custom_script(script)
		var prediction_method = "calculate_" + script.script_name
		for entity in script.subjects:
#				entity.temp_properties_modifiers[self] = {
#					"requesting_object": script.owner,
#					"modifier": _retrieve_temp_modifiers(script, "properties")
#				}
			if has_method(prediction_method):
				var amount = call(prediction_method, entity, script)
				if amount is GDScriptFunctionState:
					amount = yield(amount, "completed")
				total_amount += amount
			# If there's multiple targets, we calculate the amount only for a single of them
			break
	return(total_amount)


func predict_subjects(script: ScriptTask, prev_subjects: Array) -> Array:
	match script.get_property(SP.KEY_SUBJECT):
		SP.KEY_SUBJECT_V_TARGET:
			return(cfc.get_tree().get_nodes_in_group("EnemyEntities"))
		SP.KEY_SUBJECT_V_PREVIOUS:
			return(prev_subjects)
		SP.KEY_SUBJECT_V_PLAYER:
			return([cfc.NMAP.board.dreamer])
		SP.KEY_SUBJECT_V_SELF:
			return([script.owner])
		_:
			return([])


func calculate_modify_health(subject: CombatEntity, script: ScriptTask) -> int:
	var modification: int
	var alteration = 0
	if str(script.get_property(SP.KEY_AMOUNT)) == SP.VALUE_RETRIEVE_INTEGER:
		# If the damage is requested, is only applies to stored integers
		# so we flip the stored_integer's value.
		modification = stored_integer
		if script.get_property(SP.KEY_IS_INVERTED):
			modification *= -1
	elif SP.VALUE_PER in str(script.get_property(SP.KEY_AMOUNT)):
		var per_msg = perMessage.new(
				script.get_property(SP.KEY_AMOUNT),
				script.owner,
				script.get_property(script.get_property(SP.KEY_AMOUNT)),
				null,
				script.subjects)
		modification = per_msg.found_things
	else:
		modification = script.get_property(SP.KEY_AMOUNT)
	alteration = _check_for_effect_alterants(script, modification, subject)
	if alteration is GDScriptFunctionState:
		alteration = yield(alteration, "completed")
	return(modification + alteration)


func modify_health(script: ScriptTask) -> int:
	var retcode: int
	var tags: Array = ["Scripted"] + script.get_property(SP.KEY_TAGS)
	for combat_entity in script.subjects:
		var modification = calculate_modify_health(combat_entity, script)
		# To allow effects like advantage to despawn
		yield(cfc.get_tree().create_timer(0.01), "timeout")
		retcode = combat_entity.modify_health(
				modification,
				costs_dry_run(),
				tags)
	return(retcode)


func calculate_assign_defence(subject: CombatEntity, script: ScriptTask) -> int:
	var modification: int
	var alteration = 0
	if str(script.get_property(SP.KEY_AMOUNT)) == SP.VALUE_RETRIEVE_INTEGER:
		# If the modification is requested, is only applies to stored integers
		# so we flip the stored_integer's value.
		modification = stored_integer
		if script.get_property(SP.KEY_IS_INVERTED):
			modification *= -1
	elif SP.VALUE_PER in str(script.get_property(SP.KEY_AMOUNT)):
		var per_msg = perMessage.new(
				script.get_property(SP.KEY_AMOUNT),
				script.owner,
				script.get_property(script.get_property(SP.KEY_AMOUNT)),
				null,
				script.subjects)
		modification = per_msg.found_things
	else:
		modification = script.get_property(SP.KEY_AMOUNT)
	alteration = _check_for_effect_alterants(script, modification, subject)
	if alteration is GDScriptFunctionState:
		alteration = yield(alteration, "completed")
	return(modification + alteration)
	
func assign_defence(script: ScriptTask) -> int:
	var retcode: int
	var tags: Array = ["Scripted"] + script.get_property(SP.KEY_TAGS)
	for combat_entity in script.subjects:
		var defence = calculate_assign_defence(combat_entity, script)
		# To allow effects like advantage to despawn
		yield(cfc.get_tree().create_timer(0.01), "timeout")
		retcode = combat_entity.receive_defence(
				defence,
				costs_dry_run(),
				tags)
	return(retcode)

func apply_effect(script: ScriptTask) -> int:
	var retcode: int
	var modification: int
	var alteration = 0
	var effect_name: String = script.get_property(SP.KEY_EFFECT)
	# We inject the tags from the script into the tags sent by the signal
	var tags: Array = ["Scripted"] + script.get_property(SP.KEY_TAGS)
	if str(script.get_property(SP.KEY_MODIFICATION)) == SP.VALUE_RETRIEVE_INTEGER:
		modification = stored_integer
		if script.get_property(SP.KEY_IS_INVERTED):
			modification *= -1
	elif SP.VALUE_PER in str(script.get_property(SP.KEY_MODIFICATION)):
		var per_msg = perMessage.new(
				script.get_property(SP.KEY_MODIFICATION),
				script.owner,
				script.get_property(script.get_property(SP.KEY_MODIFICATION)),
				null,
				script.subjects)
		modification = per_msg.found_things
		print_debug(per_msg.found_things, modification)
	else:
		modification = script.get_property(SP.KEY_MODIFICATION)
	var set_to_mod: bool = script.get_property(SP.KEY_SET_TO_MOD)
	if not set_to_mod:
		alteration = _check_for_alterants(script, modification)
		if alteration is GDScriptFunctionState:
			alteration = yield(alteration, "completed")
	var stacks_diff := 0
	for e in script.subjects:
		var entity: CombatEntity = e
		var current_stacks: int
		# If we're storing the integer, we want to store the difference
		# cumulative difference between the current and modified effect stacks
		# among all the tasrgets
		# If we set set stacks to 1, and one entity had 3 stacks,
		# while another had 0
		# The total stored integer would be -1
		# This allows us to do an effect like
		# Remove all Poison stacks from all entities, gain 1 health for each stack removed.
		if script.get_property(SP.KEY_STORE_INTEGER):
			current_stacks = entity.active_effects.get_effect_stacks(effect_name)
			if set_to_mod:
				stacks_diff += modification + alteration - current_stacks
			elif current_stacks + modification + alteration < 0:
				stacks_diff += -current_stacks
			else:
				stacks_diff = modification + alteration
		retcode = entity.active_effects.mod_effect(effect_name,
				modification + alteration,set_to_mod,costs_dry_run(), tags)
	if script.get_property(SP.KEY_STORE_INTEGER):
		stored_integer = stacks_diff
	return(retcode)


func remove_card_from_game(script: ScriptTask) -> int:
	var retcode: int = CFConst.ReturnCode.CHANGED
	if not costs_dry_run():
		# We inject the tags from the script into the tags sent by the signal
		var tags: Array = ["Scripted"] + script.get_property(SP.KEY_TAGS)
		for card in script.subjects:
			card.remove_from_game()
	return(retcode)


# Initiates a seek through the owner and target combat entity to see if there's any effects
# which modify the intensity of the task in question
func _check_for_effect_alterants(script: ScriptTask, value: int, subject: CombatEntity) -> int:
	var total_alteration = 0
	var alteration_details = {}
	var source_object: CombatEntity
	var new_value := value
	if script.owner.get_class() == "Card":
		source_object = cfc.NMAP.board.dreamer
	elif "combat_entity" in script.owner:
		source_object = script.owner.combat_entity
	else:
		source_object = script.owner
	var all_source_effects = source_object.active_effects.get_ordered_effects()
	for effect in all_source_effects:
		var alteration : int = effect.get_effect_alteration(script, new_value, self, true, costs_dry_run())
		alteration_details[effect] = alteration
		new_value += alteration
	var all_subject_effects = subject.active_effects.get_ordered_effects()
	for effect in all_subject_effects:
		var alteration : int = effect.get_effect_alteration(script, new_value, self, false, costs_dry_run())
		alteration_details[effect] = alteration
		new_value += alteration
	return(new_value - value)


