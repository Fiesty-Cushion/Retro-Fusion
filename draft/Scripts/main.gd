extends Node3D

var ball_scene: PackedScene = preload("res://Scenes/ball.tscn")

@onready var mobile: CharacterBody3D = $bat
@onready var scoreboard = $CanvasLayer/Scoreboard
@onready var stadium = $stadium

@onready var score_label = $CanvasLayer/Score
@onready var run_remark = $CanvasLayer/Run_Remark
@onready var remark_timer = $CanvasLayer/Run_Remark/Remark_Timer


var score = 0

func _ready():
	Socket.start_web_socket()
	scoreboard.visible = false
	Globals.striked_ball.connect(Callable(_on_striked_ball))
	stadium.connect("score_changed", Callable(self, "_on_score_changed"))

func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().change_scene_to_file("res://Scenes/game_menu.tscn")
		
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

func _on_score_changed(amount):
	score += amount
	if amount == 1 :
		run_remark.text = "One Run!"
	elif amount == 2:
		run_remark.text = "Two Runs!"
	elif amount == 4:
		run_remark.text = "Chaukaaaaa!"	
	elif amount == 6:
		run_remark.text = "Chakkaaaaa!"
	elif amount == 0:
		run_remark.text = "Aura -1000"
	remark_timer.start()
	score_label.text = "Score : " + str(score)
	


func _on_remark_timer_timeout():
	run_remark.text = ""
	pass # Replace with function body.
