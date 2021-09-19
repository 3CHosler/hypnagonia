extends MenuButton

# This signal carries the chosen deck contents in a dictionary.
signal archetype_chosen(archetype)
# This value temporary holds all valid archetypes
# between looking at the decks to load, and selecting one.
var _archetypes_list := []

func _ready() -> void:
	# warning-ignore:return_value_discarded
	get_popup().connect("index_pressed", self, "_on_archetype_chosen")
	# warning-ignore:return_value_discarded
	connect("about_to_show", self, "_on_about_to_show")


# Triggered just after pressing the fiter button.
# Populates the menu options with one entry per archetype
func _on_about_to_show() -> void:
	# We need to clear the choices generated by previous presses.
	get_popup().clear()
	_archetypes_list = ["Clear Filters"] + Aspects.get_complete_archetype_list()
	for archetype in _archetypes_list:
		get_popup().add_item(archetype)


# Triggered when an archetype to filter against has been chosen from the popup menu.
# Emits a signal with the archetype cardlist.
func _on_archetype_chosen(index: int) -> void:
	# Since our temp archetypes list is an array, we can match the index of the
	# menu choice, with the index in the array
	var archetype = _archetypes_list[index]
	emit_signal("archetype_chosen",archetype)


func _on_ArchetypeFilter_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.get_button_index() == 2:
			emit_signal("archetype_chosen","Clear Filters")
