extends Node

var json := JSON.new()
var socket := WebSocketMultiplayerPeer.new()
var connected_users: Dictionary = {}

signal quaternion_updated(new_quaternion: Quaternion)


func start_web_socket():
	var err := socket.create_server(Globals.WEB_SOCKET_PORT)
	if err:
		printerr("Couldn't establish web socket connection", err)
	socket.peer_connected.connect(_on_client_connected)
	socket.peer_disconnected.connect(_on_client_disconnected)


func _process(delta):
	socket.poll()
	while socket.get_available_packet_count() > 0:
		var pac := socket.get_packet()
		_on_data_received(pac.get_string_from_ascii())


func _on_client_connected(id):
	print("Connected %d" % id)
	var peer: WebSocketPeer = socket.get_peer(id)
	var uri: String = peer.get_requested_url()
	var query_params: Dictionary = _parse_query_params(uri)
	if query_params.has("username"):
		var username: String = query_params["username"]
		_add_connected_user(id, username)
		Globals.user_connected.emit(username)
	else:
		print("Invalid connection url. Include username in query parameter")


func _on_client_disconnected(id):
	if connected_users.has(id):
		var username: String = connected_users[id]
		print("Client disconnected with username: %s, id: %d" % [username, id])
		connected_users.erase(id)
	else:
		print("Client disconnected with no username in dictionary, id: %d" % id)


func send_packet(pac: PackedByteArray):
	socket.put_packet(pac)


func send_message_to_userid(id: int, message: String):
	socket.get_peer(id).send_text(message)


func _on_data_received(data):
	json.parse(data)
	_handle_received_data(json)


func _handle_received_data(json: JSON):
	var new_quater: Quaternion = Quaternion(
		-json.data.ori.x, -json.data.ori.z, json.data.ori.y, -json.data.ori.w
	)
	quaternion_updated.emit(new_quater)


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


func _add_connected_user(id: int, username: String):
	connected_users[id] = username
	send_message_to_userid(id, "SocketId:" + String.num_int64(id))
	print("Client connected with username: %s, id: %d" % [username, id])
	
