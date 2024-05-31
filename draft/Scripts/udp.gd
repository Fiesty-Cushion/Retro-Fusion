extends Node
const BROADCASTING_PORT := 9752;
const BROADCASTING_DELAY := 3;

var udp_network : PacketPeerUDP;
var _broadcasting_timer :float = 0;

func _init():
	udp_network = PacketPeerUDP.new();
	udp_network.set_broadcast_enabled(true);

func _process(delta):
	_broadcasting_timer -= delta;
	if _broadcasting_timer <= 0 && !Globals.isGameStarted: # Stop braodcasting after game has started, might be changed later on if needed
		_braodcast()

func _braodcast():
	_broadcasting_timer = BROADCASTING_DELAY;
	var _os := OS.get_distribution_name() + OS.get_version();
	var _name:=_get_username()+"-"+_os;
	var message := _name+";;"+String.num_int64(Globals.WEB_SOCKET_PORT);
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
