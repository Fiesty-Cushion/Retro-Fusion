extends Node

var json := JSON.new()
var socket := WebSocketMultiplayerPeer.new()

func start_web_socket():
	var err := socket.create_server(Globals.WEB_SOCKET_PORT);
	if err:
		printerr("Couldn't establish web socket connection", err)
	socket.peer_connected.connect(_on_client_connected)
	socket.peer_disconnected.connect(_on_client_disconnected)

func _process(delta):
	socket.poll()
	while socket.get_available_packet_count() > 0:
		var pac := socket.get_packet();
		_on_data_received(pac.get_string_from_ascii())
		
func _on_client_connected(id):
	print("Connected %d" % id)
	var peer: WebSocketPeer = socket.get_peer(id)
	var uri: String = peer.get_requested_url()
	var query_params: Dictionary = _parse_query_params(uri)
	if query_params.has("username"):
		var username: String = query_params["username"]
		Globals.user_connected.emit(id, username)
	else:
		print("Invalid connection url. Include username in query parameter")

func _on_client_disconnected(id):
	Globals.user_disconnected.emit(id)

func send_packet(pac:PackedByteArray):
	socket.put_packet(pac)

func send_message_to_userid(id: int, message: String):
	socket.get_peer(id).send_text(message);

func _on_data_received(data):
	json.parse(data)
	Globals.socket_data_recieved.emit(json)
	
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

