extends Node3D

@onready var mobile :StaticBody3D= $mobile;

const BROADCASTING_PORT := 9752;
const BROADCASTING_DELAY := 3;

var socket := WebSocketMultiplayerPeer.new()
var WEB_SOCKET_PORT := 9642; # MAKE CONFIGURABLE?
var udp_network : PacketPeerUDP;
var _broadcasting_timer :float = 0;
var isStarted := false;

var connected_users : Dictionary ={}

func _init():
	udp_network = PacketPeerUDP.new();
	udp_network.set_broadcast_enabled(true);
	_start_web_socket();
	
func _process(delta):
	_broadcasting_timer -= delta;
	if _broadcasting_timer <= 0 && !isStarted:
		_braodcast()
	socket.poll()
	while socket.get_available_packet_count() > 0:
		var pac := socket.get_packet();
		_on_data_received(pac.get_string_from_ascii())

func _input(event):
	if Input.is_action_just_pressed("ui_accept"):
		isStarted = true
		var pac := "GameStart".to_ascii_buffer();
		socket.put_packet(pac)
	
# ------------- UDP BROADCAST --------------	
func _braodcast():
	_broadcasting_timer = BROADCASTING_DELAY;
	var _os := OS.get_distribution_name() + OS.get_version();
	var _name:=_get_username()+"-"+_os;
	var message := _name+";;"+String.num_int64(WEB_SOCKET_PORT);
	var pac := message.to_ascii_buffer();
	udp_network.set_dest_address("255.255.255.255", BROADCASTING_PORT);
	var error := udp_network.put_packet(pac);
	if error == 1:
		printerr("Error broadcasting: ",error);

func _get_username()->String:
	var name := "";
	if OS.has_environment("USERNAME"):
		name = OS.get_environment("USERNAME")
	else:
		var desktop_path = OS.get_system_dir(0).replace("\\", "/").split("/")
		name = desktop_path[desktop_path.size() - 2]
	return name;
	
	
	
	
# ------------ WEB SOCKET -----------
func _start_web_socket():
	var err := socket.create_server(WEB_SOCKET_PORT);
	if err:
		printerr("Couldn't establish web socket connection", err)
	socket.peer_connected.connect(_on_client_connected)
	socket.peer_disconnected.connect(_on_client_disconnected)
	
func _on_client_connected(id):
	print("Connected %d" % id)
	var peer: WebSocketPeer = socket.get_peer(id)
	var uri: String = peer.get_requested_url()
	var query_params: Dictionary = _parse_query_params(uri)
	if query_params.has("username"):
		var username: String = query_params["username"]
		connected_users[id] = username
		socket.get_peer(id).send_text("SocketId:"+String.num_int64(id));
		print("Client connected with username: %s, id: %d" % [username, id])
	else:
		print("Client connected with id: %d" % id)

func _on_client_disconnected(id):
	if connected_users.has(id):
		var username: String = connected_users[id]
		print("Client disconnected with username: %s, id: %d" % [username, id])
		connected_users.erase(id)
	else:
		print("Client disconnected with id: %d" % id)

var json := JSON.new()

func _on_data_received(data):
	json.parse(data)
	var quater : Quaternion = Quaternion(json.data.ori.x, json.data.ori.z, -json.data.ori.y , -json.data.ori.w )

	mobile.global_transform.basis = Basis(quater).scaled(global_transform.basis.get_scale())
	
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

