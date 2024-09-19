extends Node3D

signal score_changed(amount)

var ball_states = {}  # Dictionary to store each ball's state (inner and outer circle status)

@onready var inner_circle = $inner_circle
@onready var outer_circle = $outer_circle

func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var to_remove: Node = null  # Temporary variable to store the ball to remove

	# Loop over balls to check their state
	for ball in ball_states.keys():
		if ball != null:  # Check if the ball instance is still valid
			var ball_state = ball_states[ball]  # Get the state of the current ball

			# Handle run calculation based on the ball's state if it's not in the boundary
			if ball.is_hit() and ball.get_speed() < 5:
				if ball_state["just_in_pitch"]:
					if ball_state["in_inner_circle"]:
						if ball_state["in_outer_circle"]:
							give_runs(2)  # 2 runs for outer circle
						else:
							give_runs(1)  # 1 run for inner circle
					else:
						give_runs(0)
				to_remove = ball  # Store the ball to remove and despawn
				break  # Exit loop after processing the ball
			elif (not ball.is_hit()) and ball_state["just_in_pitch"] and (ball_state["in_inner_circle"] or ball_state["in_outer_circle"]):
				print("Not hit")
				give_runs(-1)
				to_remove = ball

	# Remove and despawn the ball after the loop
	if to_remove != null:
		ball_states.erase(to_remove)  # Remove the ball's state
		to_remove.queue_free()  # Free the ball

	# Stop processing if no balls are left
	if ball_states.is_empty():
		set_process(false)
	

# Called when a ball enters the inner circle
func _on_inner_circle_body_entered(body):
	if body.is_in_group("ball"):
		# Initialize the state for this ball if not already tracked
		if body not in ball_states:
			ball_states[body] = {"just_in_pitch": false,
								"in_inner_circle": false, 
								"in_outer_circle": false}
		
		# Update the state only if not in the boundary
		ball_states[body]["in_inner_circle"] = true
		set_process(true)  # Start processing

# Called when a ball enters the outer circle
func _on_outer_circle_body_entered(body):
	if body.is_in_group("ball"):
		# Initialize the state for this ball if not already tracked
		if body not in ball_states:
			ball_states[body] = {"just_in_pitch": false,
								"in_inner_circle": false, 
								"in_outer_circle": false}
		# Update the state only if not in the boundar
		ball_states[body]["in_outer_circle"] = true
		set_process(true)  # Start processing

func _on_outer_pitch_area_body_entered(body):
	if body.is_in_group("ball"):
		if body in ball_states and body.is_hit():
			if ball_states[body]["in_outer_circle"] or ball_states[body]["in_inner_circle"]:
				give_runs(4)
			else:
				give_runs(6)
		body.queue_free()
	pass # Replace with function body.


func _on_pitch_body_entered(body):
	if body.is_in_group("ball"):
		# Initialize the state for this ball if not already tracked
		if body not in ball_states:
			ball_states[body] = {"just_in_pitch": false,
								"in_inner_circle": false, 
								"in_outer_circle": false}
		
		# Update the state only if not in the boundary
		ball_states[body]["just_in_pitch"] = true
		set_process(true)  # Start processing
	pass # Replace with function body.
	
		
func give_runs(runs):
	emit_signal("score_changed", runs)

