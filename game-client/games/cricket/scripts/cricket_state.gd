extends GameState
class_name CricketState

var current_batsman: String = "Anon"
var total_score: int = 0
var current_batsman_runs: int = 0
var current_batsman_balls_faced: int = 0
var wickets_fallen: int = 0
var total_balls_bowled: int = 0

func get_state() -> CricketState:
	var state = CricketState.new()
	state.current_batsman = current_batsman
	state.total_score = total_score
	state.current_batsman_runs = current_batsman_runs
	state.current_batsman_balls_faced = current_batsman_balls_faced
	state.wickets_fallen = wickets_fallen
	state.total_balls_bowled = total_balls_bowled
	return state

func serialize() -> Dictionary:
	return {
		"current_batsman": current_batsman,
		"total_score": total_score,
		"current_batsman_runs": current_batsman_runs,
		"current_batsman_balls_faced": current_batsman_balls_faced,
		"wickets_fallen": wickets_fallen,
		"total_balls_bowled": total_balls_bowled
	}
	
func apply_update(data: Dictionary) -> void:
	for key in data:
		if key in self:
			self[key] = data[key]
	
	state_changed.emit(get_state())
	
