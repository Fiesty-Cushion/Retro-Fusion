extends Node3D

@onready var mobile :CharacterBody3D = $bat;
var connected_users : Dictionary ={}

const BALL_VEL_MAX = 55
const BALL_VEL_MIN = 45

var quater : Quaternion = Quaternion(0, 0, 0.7, 0.7)
var REFERENCE_QUATER = Quaternion(0, 0, sqrt(2)/2, sqrt(2)/2)

var ball_scene : PackedScene = preload("res://Scenes/ball.tscn")

func _ready():
	mobile.global_transform.basis = Basis(quater).scaled(global_transform.basis.get_scale())
	print(_quater_relative(Quaternion(0, 0, 0.707, 0.707), Quaternion(0, 0, 0.707, 0.707)))

func _init():
	
	Socket.start_web_socket();
	# Signals
	Globals.socket_data_recieved.connect(_on_socket_data_received)
	Globals.user_connected.connect(_on_user_connected)
	Globals.user_disconnected.connect(_on_user_disconnected)
	
func _quater_relative(x : Quaternion, y : Quaternion):
	return x.inverse() * y
	
func _on_socket_data_received(json:JSON):
	#print(json.data.ori)
	var quater = Quaternion(json.data.ori.x, json.data.ori.y, json.data.ori.z, json.data.ori.w)
	var axis : Vector3 = quater.get_axis()
	
	
	var new_quater : Quaternion = Quaternion(-json.data.ori.x, -json.data.ori.z, json.data.ori.y , -json.data.ori.w )
	var relative_quater = _quater_relative(REFERENCE_QUATER, new_quater)	
	quater = quater.slerp(relative_quater, 0.8)	
	mobile.global_transform.basis = Basis(quater).scaled(global_transform.basis.get_scale())
	
	
func _input(event):
	#if Input.is_action_just_pressed("B_Key"):
		#spawn_ball()
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")	
	
	if Input.is_action_just_pressed("ui_accept"):
		Globals.isGameStarted = true  # Stop braodcasting after game has started, might be changed later on if needed
		var pac := "GameStart".to_ascii_buffer();
		Socket.send_packet(pac)
		
func _on_user_connected(id:int, username:String):
	connected_users[id] = username
	Socket.send_message_to_userid(id, "SocketId:"+String.num_int64(id))	
	print("Client connected with username: %s, id: %d" % [username, id])
	
func _on_user_disconnected(id):
	if connected_users.has(id):
		var username: String = connected_users[id]
		print("Client disconnected with username: %s, id: %d" % [username, id])
		connected_users.erase(id)
	else:
		print("Client disconnected with no username in dictionaty, id: %d" % id)


func spawn_ball():
	var ball_pos: Vector3 = Vector3(0, 8.7, -50)
	ball_pos.y = randf_range(8.,9)
	var ball := ball_scene.instantiate()
	ball.position = ball_pos
	ball.linear_velocity.z = randi_range(BALL_VEL_MIN, BALL_VEL_MAX)
	ball.name = "Ball"
	add_child(ball)


func _on_timer_timeout():
	spawn_ball()
	pass # Replace with function body.
