extends Node
const BROADCASTING_PORT := 9752
const BROADCASTING_DELAY := 3

var udp_network: PacketPeerUDP
var _broadcasting_timer: float = 0
var is_broadcasting := false

var broadcast_addresses : Array[String]
var msg_buff : PackedByteArray

func _init():
	udp_network = PacketPeerUDP.new()
	udp_network.set_broadcast_enabled(true)
	var err = udp_network.bind(BROADCASTING_PORT)
	if err != OK:
		printerr("Failed to bind UDP socket: ", err)
			
	broadcast_addresses = Ip.get_broadcast_addresses()

func start_broadcasting(ws_port : int):	
	# Create identification message in format: username-OS_nameOS_version;;port
	var _name := _get_username() + "-" + OS.get_distribution_name() + OS.get_version()
	var message := _name + ";;" + String.num_int64(ws_port)
	msg_buff = message.to_ascii_buffer()
	is_broadcasting = true
	
func stop_broadcasting():
	is_broadcasting = false

func _process(delta):
	if not is_broadcasting:
		return
		
	_broadcasting_timer -= delta
	if _broadcasting_timer > 0:  
		return
	
	_broadcast()
	_broadcasting_timer = BROADCASTING_DELAY


func _broadcast():
	for addr in broadcast_addresses:
		udp_network.set_dest_address(addr, BROADCASTING_PORT)
		var error := udp_network.put_packet(msg_buff)
		if error != OK:
			printerr("Error broadcasting to ", addr, ": ", error)

# Returns the current user's username from environment variables or system directory
func _get_username() -> String:
	var name := ""
	if OS.has_environment("USERNAME"):
		name = OS.get_environment("USERNAME")
	else:
		var desktop_path = OS.get_system_dir(0).replace("\\", "/").split("/")
		name = desktop_path[desktop_path.size() - 2]
	return name
	
