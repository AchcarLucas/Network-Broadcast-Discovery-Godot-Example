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

	return Error.OK

func close() -> void:
	_udp.close()

func has_packet_available() -> bool:
	return _udp.get_available_packet_count() > 0

func broadcast(packet: PackedByteArray) -> Error:
	_udp.set_dest_address(_BROADCAST_IP, _port)
	return _put_packet(packet)

func multicast(packet: PackedByteArray) -> Error:
	_udp.set_dest_address(_MULTICAST_IP, _port)
	return _put_packet(packet)

func _put_packet(packet: PackedByteArray) -> Error:
	var error := _udp.put_packet(packet)

	if error != OK:
		push_warning(
			"Failed to announce server: %s" % error_string(error)
		)
		return error

	return Error.OK

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
