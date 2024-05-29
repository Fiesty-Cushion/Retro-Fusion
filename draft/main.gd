extends Node3D

@onready var mobile :StaticBody3D= $mobile;
var connected_users : Dictionary ={}

func _init():
	Socket.start_web_socket();
	# Signals
	Globals.socket_data_recieved.connect(_on_socket_data_received)
	Globals.user_connected.connect(_on_user_connected)
	Globals.user_disconnected.connect(_on_user_disconnected)
	
func _on_socket_data_received(json:JSON):
	var quater : Quaternion = Quaternion(json.data.ori.x, json.data.ori.z, -json.data.ori.y , -json.data.ori.w )	
	mobile.global_transform.basis = Basis(quater).scaled(global_transform.basis.get_scale())
	
func _input(event):
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

