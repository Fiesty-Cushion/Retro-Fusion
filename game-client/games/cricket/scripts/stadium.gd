extends Node3D

var scored_runs = 0

func _ready():
	Globals.ball_despawned.connect(give_runs)

func give_runs(ball : Node):
	if ball != null:
		Globals.runs_scored.emit(scored_runs) # null ball means game has stopped
	scored_runs = 0;

# Reward no runs when ball remains in the pitch
func _body_entered_pitch(body):
	if body.is_in_group("ball") and body.is_hit():
		scored_runs = 0
		print("Ball entered Pitch")

# Reward 1 run when ball enters inner circle
func _on_body_entered_inner_circle(body):
	if body.is_in_group("ball") and body.is_hit():
		scored_runs = 1
		print("Ball in Inner Circle")

# Reward 2 runs when ball enters outer circle
func _body_entered_outer_circle(body):
	if body.is_in_group("ball") and body.is_hit():
		scored_runs = 2
		print("Ball entered Outer Circle")

# Reward 4 runs when ball exits outer circle (has contact with the field)
func _on_body_exited_outer_circle(body):
	if body.is_in_group("ball") and body.is_hit():
		scored_runs = 4
		print("Ball exited Outer Circle")

# TODO: Logic for 6 runs
