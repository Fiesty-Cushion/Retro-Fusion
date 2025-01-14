extends Node3D

@onready var stadium = $stadium
#@onready var wickets = $wickets

# UI
@onready var scoreboard = $CanvasLayer/Scoreboard
@onready var run_remark = $CanvasLayer/Run_Remark
@onready var remark_timer = $CanvasLayer/Run_Remark/Remark_Timer
@onready var hud: Control = $CanvasLayer/Hud
@onready var camera: Camera3D = $Camera3D

var state : CricketState = CricketState.new();
# Making methods bcz godot got has_method() but not has_property()
func serialize() -> Dictionary:
	return state.serialize()
	
var ball_scene: PackedScene = preload("res://games/cricket/scenes/ball.tscn")
var ball_lifetime: float = 5.0
var current_ball: Node = null
var _is_game_started := false

func _ready():
	hud.set_state(state)
	scoreboard.visible = false
	
	Globals.striked_ball.connect(Callable(_on_striked_ball))
	Globals.runs_scored.connect(Callable(_on_runs_scored))
	Socket.user_connected.connect(_on_user_connected)
	Socket.user_disconnected.connect(_on_user_disconnected)
		
	#wickets.connect("wicket_hit", Callable(self, "_on_wicket_hit"))
	
	# TODO: make this look better
	run_remark.text = "Waiting for mobile to connect..."

func start_game():
	_is_game_started = true
	run_remark.text = ""
	spawn_ball()

func stop_game() :
	_is_game_started = false
	run_remark.text = "Waiting for mobile to connect..."
	camera.reset()
	if current_ball:
		current_ball.queue_free()
		current_ball = null
	
func spawn_ball():
	if current_ball:
		return  # Only one ball at a time
		
	current_ball= ball_scene.instantiate()
	current_ball.name = "Ball"
	add_child(current_ball)
	Globals.ball_spawned.emit(current_ball)
	Globals.batShouldReset = true
	
	# TODO: constant lifetime ko thau ma ball pitch bata tadha gaye sangai lifetime badhney?
	get_tree().create_timer(ball_lifetime).timeout.connect(_on_ball_timeout.bind(current_ball))

func _on_ball_timeout(ball: Node):
	if ball == null:
		return
	if ball == current_ball:
		current_ball.queue_free()
		current_ball = null
		Globals.ball_despawned.emit(ball)
		
func _on_user_connected(username: String, _id : int):
	state.apply_update({
		"current_batsman": username
	})
	print("User connected: ", username)
	print("Updated state: ", state.serialize())
		
	# currently there is no mechanism to detect pressing of start button 
	# hence relying on this timer. shall be improved on future iteration
	run_remark.text = "Press start to begin..."
	get_tree().create_timer(1.0).timeout.connect(start_game)

func _on_user_disconnected(username: String, _id: int):
	if state.current_batsman == username:
		state.apply_update({
			"current_batsman": "Anon"
		})
		stop_game()
		
func _on_wicket_hit():
	state.apply_update({
		"wickets_fallen": state.wickets_fallen + 1,
		"current_batsman_runs": 0,
		"current_batsman_balls_faced": 0,
		"total_balls_bowled": state.total_balls_bowled + 1
	})
	give_remark("Wicket!")
	
	# This might be changed later on with a cutscene and then spawn
	get_tree().create_timer(1.0).timeout.connect(func(): 
		if _is_game_started:
			spawn_ball()
	)
	
func _on_runs_scored(runs: int):
	# Schedule next ball spawn after a lil delay 
	get_tree().create_timer(0.5).timeout.connect(func(): 
		if _is_game_started:
			spawn_ball()
	)
	
	state.apply_update({
		"total_score": state.total_score + runs,
		"current_batsman_runs": state.current_batsman_runs + runs,
		"current_batsman_balls_faced": state.current_batsman_balls_faced + 1,
		"total_balls_bowled": state.total_balls_bowled + 1
	})
	print("Runs: ", runs)
	print("Updated state: ", state.serialize())
	
	give_remark(_get_remark_text(runs))
	
func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE):
		GameManager.goto_game_menu()
		
	if Input.is_key_pressed(KEY_M):
		print("M Pressed", scoreboard.visible)
		scoreboard.visible = not scoreboard.visible
		
func _on_striked_ball():
	Socket.send_packet("striked_ball".to_ascii_buffer()) # Send haptic feedback to mobile
	
func give_remark(text):
	run_remark.text = text
	remark_timer.start()
	
func _on_remark_timer_timeout():
	run_remark.text = ""
	
func _get_remark_text(runs: int) -> String:
	match runs:
		1: return "One Run!"
		2: return "Two Runs!"
		4: return "Chaukaaaaa!"
		6: return "Chakkaaaaa!"
		0: return "Aura -1000"
		-1: return "Miss!"
		_: return ""
