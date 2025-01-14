extends Control

@onready var player_name = $MarginContainer/MarginContainer/PlayerStats/PlayerName
@onready var rich_text_label :RichTextLabel= $MarginContainer/MarginContainer/TotalScore/RichTextLabel
@onready var player_score = $MarginContainer/MarginContainer/PlayerStats/MarginContainer/PlayerScore
@onready var player_balls = $MarginContainer/MarginContainer/PlayerStats/MarginContainer/MarginContainer/PlayerBalls

var state: CricketState = null

func set_state(new_state: CricketState) -> void:
	if state:
		state.disconnect("state_changed", Callable(self, "_on_state_changed"))
	
	state = new_state
	if state:
		state.connect("state_changed", Callable(self, "_on_state_changed"))
		
func _on_state_changed(new_state: CricketState):
	# total scores
	rich_text_label.clear()
	var new_score_label = "[center]" + str(new_state.total_score) + " - " + str(new_state.wickets_fallen) + "[/center]"
	rich_text_label.append_text(new_score_label)
	
	# player scores
	player_score.clear()
	player_score.append_text(str(new_state.current_batsman_runs))
	player_balls.clear()
	player_balls.append_text("("+str(new_state.current_batsman_balls_faced)+")")
	
	player_name.clear()
	player_name.append_text(new_state.current_batsman)
