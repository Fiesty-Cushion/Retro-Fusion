extends Node3D

var ball_scene: PackedScene = preload("res://games/cricket/scenes/ball.tscn")

@onready var mobile: CharacterBody3D = $bat
@onready var scoreboard = $CanvasLayer/Scoreboard
@onready var stadium = $stadium
#@onready var wickets = $wickets

@onready var run_remark = $CanvasLayer/Run_Remark
@onready var remark_timer = $CanvasLayer/Run_Remark/Remark_Timer


var score = 0

func _ready():
	Socket.start_web_socket()
	scoreboard.visible = false
	Globals.striked_ball.connect(Callable(_on_striked_ball))
	Globals.score_changed.connect(Callable(_on_score_changed))
	#stadium.connect("score_changed", Callable(self, "_on_score_changed"))
	#wickets.connect("wicket_hit", Callable(self, "_on_wicket_hit"))

func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().change_scene_to_file("res://scenes/game_menu.tscn")
		
	if Input.is_key_pressed(KEY_M):
		print("M Pressed", scoreboard.visible)
		scoreboard.visible = not scoreboard.visible
		

	if Input.is_action_just_pressed("ui_accept"):
		Globals.isGameStarted = true  # Stop braodcasting after game has started, might be changed later on if needed
		var pac := "GameStart".to_ascii_buffer()
		Socket.send_packet(pac)


func _on_timer_timeout():
	spawn_ball()
	Globals.batShouldReset = true


func spawn_ball():
	var ball := ball_scene.instantiate()
	ball.name = "Ball"
	add_child(ball)
	
func _on_striked_ball():
	Socket.send_packet("striked_ball".to_ascii_buffer())
	
func _on_wicket_hit():
	give_remark("Wicket!")

func _on_score_changed(amount):
	score += amount if amount != -1 else 0
	if amount == 1 :
		give_remark("One Run!")
	elif amount == 2:
		give_remark("Two Runs!")
	elif amount == 4:
		give_remark("Chaukaaaaa!")
	elif amount == 6:
		give_remark("Chakkaaaaa!")
	elif amount == 0:
		give_remark("Aura -1000")
	elif amount == -1:
		give_remark("Miss!")

func give_remark(text):
	run_remark.text = text
	remark_timer.start()
	

func _on_remark_timer_timeout():
	run_remark.text = ""
	pass # Replace with function body.
