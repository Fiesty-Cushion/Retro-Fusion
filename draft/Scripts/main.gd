extends Node3D

@onready var mobile: CharacterBody3D = $bat

var ball_scene: PackedScene = preload("res://Scenes/ball.tscn")


func _ready():
	Socket.start_web_socket()


func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().change_scene_to_file("res://Scenes/game_menu.tscn")

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
