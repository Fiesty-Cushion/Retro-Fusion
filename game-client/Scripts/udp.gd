extends Node
const BROADCASTING_PORT := 9752
const BROADCASTING_DELAY := 3

var udp_network: PacketPeerUDP
var _broadcasting_timer: float = 0

var broadcast_addresses : Array[String]
var msg_buff : PackedByteArray

func _init():
	udp_network = PacketPeerUDP.new()
	udp_network.set_broadcast_enabled(true)
	var err = udp_network.bind(BROADCASTING_PORT)
	if err != OK:
		printerr("Failed to bind UDP socket: ", err)
			
	broadcast_addresses= get_broadcast_addresses()
	print(broadcast_addresses)
	
	var _name := _get_username() + "-" + OS.get_distribution_name() + OS.get_version()
	var message := _name + ";;" + String.num_int64(Globals.WEB_SOCKET_PORT)
	msg_buff = message.to_ascii_buffer()
	


func _process(delta):
	if Globals.isGameStarted: # Stop braodcasting after game has started, might be changed later on if needed
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


func _get_username() -> String:
	var name := ""
	if OS.has_environment("USERNAME"):
		name = OS.get_environment("USERNAME")
	else:
		var desktop_path = OS.get_system_dir(0).replace("\\", "/").split("/")
		name = desktop_path[desktop_path.size() - 2]
	return name
	
	
func _get_broadcast_addresses() -> Array[String]:
	var ip = IP.get_local_addresses()
	var addresses : Array[String]
	for addr in ip:
		if addr.begins_with("192.168") or addr.begins_with("10.") or addr.begins_with("172."):
			var parts = addr.split(".")
			parts[3] = "255"
			addresses.append(".".join(parts))
	return addresses


func get_broadcast_addresses() -> Array[String]:
	var addresses: Array[String] = []
	var ip_addresses = IP.get_local_addresses()

	# Filter to get only IPv4 local network addresses
	for addr in ip_addresses:
		# Skip IPv6 addresses
		if ":" in addr:
			continue
			
		# Skip localhost/loopback
		if addr.begins_with("127."):
			continue
			
		# Find the IP and subnet mask
		var network_info = get_network_info(addr)
		if network_info.is_empty():
			continue
			
		var broadcast = calculate_broadcast(network_info.ip, network_info.mask)
		if broadcast != "":
			addresses.append(broadcast)
	
	return addresses

func get_network_info(target_ip: String) -> Dictionary:
	if OS.has_feature("windows"):
		var output : Array[String]= []
		OS.execute("ipconfig", [], output)
		var lines := output[0].split("\n")
		
		var current_interface := ""
		var found_ip := false
		var mask := ""
		
		# Parse through lines
		for line in lines:
			line = line.strip_edges()
			
			# New interface section starts
			if line.ends_with(":"):
				current_interface = line
				found_ip = false
				mask = ""
				continue
				
			# Check for IP
			if "IPv4 Address" in line and target_ip in line:
				found_ip = true
				continue
				
			# If we found our IP, get the next subnet mask
			if found_ip and "Subnet Mask" in line:
				mask = line.split(":")[1].strip_edges()
				return {"ip": target_ip, "mask": mask}
	else:
		# Linux/Mac
		var output = []
		OS.execute("ip", ["addr"], output)
		if output[0].is_empty():
			OS.execute("ifconfig", [], output)
			
		var lines = output[0].split("\n")
		for i in range(lines.size()):
			var line = lines[i]
			if target_ip in line:
				# For 'ip addr' command
				if "inet" in line:
					var parts = line.split()
					for part in parts:
						if "/" in part and part.begins_with(target_ip):
							var prefix_length = part.split("/")[1].to_int()
							return {
								"ip": target_ip,
								"mask": prefix_to_netmask(prefix_length)
							}
				# For ifconfig
				elif i + 1 < lines.size():
					var next_line = lines[i + 1]
					if "netmask" in next_line:
						var mask = next_line.split("netmask")[1].split()[0]
						return {"ip": target_ip, "mask": mask}
	
	return {}

# Helper function to convert prefix length to netmask
func prefix_to_netmask(prefix_length: int) -> String:
	var mask = ""
	var full_octets = prefix_length / 8
	var remaining_bits = prefix_length % 8
	
	for i in range(4):
		if i < full_octets:
			mask += "255"
		elif i == full_octets and remaining_bits > 0:
			var octet = 0
			for bit in range(remaining_bits):
				octet |= 1 << (7 - bit)
			mask += str(octet)
		else:
			mask += "0"
			
		if i < 3:
			mask += "."
			
	return mask

func calculate_broadcast(ip: String, netmask: String) -> String:
	var ip_parts := ip.split(".")
	var mask_parts := netmask.split(".")
	
	if ip_parts.size() != 4 or mask_parts.size() != 4:
		return ""
		
	var broadcast_parts: Array[String]
	for i in range(4):
		var ip_octet = ip_parts[i].to_int()
		var mask_octet = mask_parts[i].to_int()
		broadcast_parts.append(str(ip_octet | (255 - mask_octet)))
	
	return ".".join(broadcast_parts)
