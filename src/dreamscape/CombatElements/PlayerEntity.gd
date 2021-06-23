class_name PlayerEntity
extends CombatEntity

func _ready() -> void:
	entity_type = "dreamer"


# THe player does not really have health, they have an anxiety meter
# which makes them wakeup when full.
# As such we want to reverse the health to show it increasing instead of 
# decreasing when taking damage
# But we keep the underlying mechanics the same to stay consistent.
func _update_health_label() -> void:
	health_label.text = str(max_health - health) + '/' + str(max_health)
	defence_label.text = '(' + str(defence) + ')'
