extends Resource
class_name GameState 

# Signal emitted when the state changes.
# This signal should be emitted whenever the state is updated.
signal state_changed(state: GameState)

# Returns the current state as a GameState object.
# This method should be overridden by child classes to return a copy of the current state.
# The returned object should be immutable
func get_state() -> GameState:
	return null 

# Converts the current state into a dictionary.
# This method should be overridden by child classes to return a dictionary representation of the state.
func serialize() -> Dictionary:
	return {}

# Updates the state based on the provided dictionary.
# This method should be overridden by child classes to apply updates to the state.
# The input dictionary contains key-value pairs representing the new state values.
# After updating the state, the `state_changed` signal should be emitted
func apply_update(data: Dictionary) -> void:
	pass 
