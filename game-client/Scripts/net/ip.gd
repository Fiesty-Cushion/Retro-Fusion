extends Node

# Returns a list of broadcast addresses for all local network interfaces
static func get_broadcast_addresses() -> Array[String]:
	var addresses: Array[String] = []
	var ip_addresses := IP.get_local_addresses()

	# Filter to get only IPv4 local network addresses
	for addr in ip_addresses:
		# Skip IPv6 addresses
		if ":" in addr:
			continue
			
		# Skip localhost/loopback
		if addr.begins_with("127."):
			continue
			
		var network_info = get_network_info(addr)
		if network_info.is_empty():
			continue
			
		var broadcast = calculate_broadcast(network_info.ip, network_info.mask)
		if broadcast != "":
			addresses.append(broadcast)
	
	return addresses

# Retrieves network information (IP and subnet mask) for a given IP address
static func get_network_info(target_ip: String) -> Dictionary:
	if OS.has_feature("windows"):
		return _get_windows_network_info(target_ip)
	else:
		return _get_unix_network_info(target_ip)

static func _get_windows_network_info(target_ip: String) -> Dictionary:
	var output : Array[String] = []
	OS.execute("ipconfig", [], output)
	var lines := output[0].split("\n")
	
	var found_ip := false
	
	for line in lines:
		line = line.strip_edges()
		
		if line.ends_with(":"):
			found_ip = false
			continue
			
		if "IPv4 Address" in line and target_ip in line:
			found_ip = true
			continue
			
		if found_ip and "Subnet Mask" in line:
			return {"ip": target_ip, "mask": line.split(":")[1].strip_edges()}
	
	return {}

static func _get_unix_network_info(target_ip: String) -> Dictionary:
	var output : Array[String] = []
	OS.execute("ip", ["addr"], output)
	if output[0].is_empty():
		OS.execute("ifconfig", [], output)
		
	var lines := output[0].split("\n")
	for i in range(lines.size()):
		var line := lines[i]
		if target_ip in line:
			# For 'ip addr' command
			if "inet" in line:
				var parts := line.split()
				for part in parts:
					if "/" in part and part.begins_with(target_ip):
						var prefix_length := part.split("/")[1].to_int()
						return {
							"ip": target_ip,
							"mask": prefix_to_netmask(prefix_length)
						}
			# For ifconfig
			elif i + 1 < lines.size():
				var next_line = lines[i + 1]
				if "netmask" in next_line:
					var mask := next_line.split("netmask")[1].split()[0]
					return {"ip": target_ip, "mask": mask}
	return {}
	
# Converts CIDR prefix length to subnet mask format
static func prefix_to_netmask(prefix_length: int) -> String:
	var mask := ""
	var full_octets := prefix_length / 8
	var remaining_bits := prefix_length % 8
	
	for i in range(4):
		if i < full_octets:
			mask += "255"
		elif i == full_octets and remaining_bits > 0:
			var octet := 0
			for bit in range(remaining_bits):
				octet |= 1 << (7 - bit)
			mask += str(octet)
		else:
			mask += "0"
			
		if i < 3:
			mask += "."
			
	return mask

static func calculate_broadcast(ip: String, netmask: String) -> String:
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
