class_name NetworkBroadcastDiscoveryManager extends NetworkBroadcastDiscoveryManagerBase

var _port: int

func initialize(port: int = 47777) -> Error:
	if _udp != null:
		return Error.OK
	
	_udp = PacketPeerUDP.new()

	_port = port
	var error := _udp.bind(_port)

	if error != OK:
		push_error("Unable to open the UDP port: %s" % error_string(error))
		return error

	_udp.set_broadcast_enabled(true)

	for interface in IP.get_local_interfaces():
		print_debug("Address <%s> - Interface <%s>" % [interface["addresses"], interface["name"]])

		error = _udp.join_multicast_group(
			_MULTICAST_IP,
			interface["name"]
		)

		if error != OK:
			push_error("[%s] Multicast join failure: <%s> " % [
				interface["name"],
				error_string(error)
			])

	return Error.OK

func _put_packet(packet: PackedByteArray) -> Error:
	var error := _udp.put_packet(packet)

	if error != OK:
		push_warning(
			"Failed to 'put packet': %s" % error_string(error)
		)
		return error

	return Error.OK

func close() -> void:
	_udp.close()

func has_packet_available() -> bool:
	return _udp.get_available_packet_count() > 0

func broadcast(packet: PackedByteArray) -> void:
	var targets := get_broadcast_targets()
	for target in targets:
		print_debug("Package sent to <%s:%d>" % [target, _port])
		var error := _udp.set_dest_address(target, _port)
		if error != OK:
			push_warning("Unable to use the destination <%s> - error <%s>" % [target, error_string(error)])
			continue
		error = _put_packet(packet)
		if error != OK:
			push_warning("Unable to send the package to <%s> - error <%s>" % [target, error_string(error)])
			continue

func listener() -> Dictionary:
	var packet: PackedByteArray
	var sender_ip: String

	if _udp.get_available_packet_count() > 0:
		packet = _udp.get_packet()
		sender_ip = _udp.get_packet_ip()

	return {
		'packet': packet,
		'sender_ip': sender_ip
	}
