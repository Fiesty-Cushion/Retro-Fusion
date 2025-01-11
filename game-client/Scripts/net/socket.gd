extends Node

var json := JSON.new()

var current_port := 0
var is_socket_active := false
var socket := WebSocketMultiplayerPeer.new()

var connected_users: Dictionary = {}
var max_connections: int = 1
var socket_mutex: Mutex = Mutex.new()
var user_mutex : Mutex = Mutex.new()

signal quaternion_updated(new_quaternion: Quaternion, sender_id: int)
signal accelerometer_updated(new_value: Vector3, sender_id: int)

func start_web_socket(no_of_connections: int) -> int:
	socket_mutex.lock()
	if not socket.peer_connected.is_connected(_on_client_connected):
		socket.peer_connected.connect(_on_client_connected)
	if not socket.peer_disconnected.is_connected(_on_client_disconnected):
		socket.peer_disconnected.connect(_on_client_disconnected)
		
	#TODO This is causing mobile app to fill up on every game start for now using constant port
	
	#max_connections = no_of_connections
	#socket.close()
	#var attempts := 0
	#while attempts < 10: 
		#var port := randi_range(1024 ,49151) # Registered Ports Range
		#var err := socket.create_server(port)
		#if err == OK:
			#print("Successfully started WebSocket on port: ", port)
			#is_socket_active = true
			#current_port = port
			#socket_mutex.unlock()
			#return port
		#attempts += 1
	#printerr("Failed to find available port")
	#socket_mutex.unlock()
	#return -1
	
	max_connections = no_of_connections
	socket.close()
	var err := socket.create_server(Globals.WEB_SOCKET_PORT)
	if err == OK:
		print("Successfully started WebSocket on port: ", Globals.WEB_SOCKET_PORT)
		is_socket_active = true
		current_port = Globals.WEB_SOCKET_PORT
		socket_mutex.unlock()
		return Globals.WEB_SOCKET_PORT
	printerr("Failed to find available port")
	socket_mutex.unlock()
	return -1
	

func stop_web_socket():
	socket_mutex.lock()
	if is_socket_active:
		socket.close()
		connected_users.clear()
		is_socket_active = false
		current_port = 0
		print("WebSocket server stopped")
	socket_mutex.unlock()

func _process(delta):
	socket.poll()
	while socket.get_available_packet_count() > 0:
		var pac := socket.get_packet()
		_on_data_received(pac.get_string_from_ascii())

func _on_client_connected(id):
	user_mutex.lock()
	if connected_users.size() >= max_connections:
		print("Connection limit reached. Rejecting connection from peer: ", id)
		socket.disconnect_peer(id)
		user_mutex.unlock()
		return
		
	var peer: WebSocketPeer = socket.get_peer(id)
	var uri: String = peer.get_requested_url()
	var query_params: Dictionary = _parse_query_params(uri)
	if query_params.has("username"):
		var username: String = query_params["username"]
		connected_users[id] = username
		send_message_to_userid(id, "SocketId:" + String.num_int64(id))
		Globals.user_connected.emit(username)
		print("Client connected with username: %s, id: %d" % [username, id])
	else:
		print("Invalid connection url. Include username in query parameter")
	user_mutex.unlock()

func _on_client_disconnected(id):
	user_mutex.lock()
	if connected_users.has(id):
		var username: String = connected_users[id]
		print("Client disconnected with username: %s, id: %d" % [username, id])
		connected_users.erase(id)
	else:
		print("Client disconnected with no username in dictionary, id: %d" % id)
	user_mutex.unlock()


func send_packet(pac: PackedByteArray):
	socket.put_packet(pac)


func send_message_to_userid(id: int, message: String):
	socket.get_peer(id).send_text(message)


func _on_data_received(data:String):
	if json.parse(data) != OK:
		printerr("Failed to parse JSON data: ", json.get_error_message())
		return
	var sender_id := int(json.data.id)
	var new_quater: Quaternion = Quaternion(
		-json.data.ori.x, -json.data.ori.z, json.data.ori.y, -json.data.ori.w
	)
	var new_data = Vector3(json.data.acc.x, json.data.acc.y, json.data.acc.z)
	quaternion_updated.emit(new_quater, sender_id)
	accelerometer_updated.emit(new_data, sender_id)


func _parse_query_params(uri: String) -> Dictionary:
	var query_params: Dictionary = {}
	var split_uri = uri.split("?")
	if split_uri.size() > 1:
		var query_string = split_uri[1]
		var query_pairs = query_string.split("&")
		for pair in query_pairs:
			var key_value = pair.split("=")
			if key_value.size() == 2:
				query_params[key_value[0]] = key_value[1]
	return query_params
