class_name NetworkBroadcastDiscoveryManagerBase extends Node

const _BROADCAST_IP: String = "255.255.255.255"
const _MULTICAST_IP: String = "239.255.77.77"

var _udp :PacketPeerUDP

func is_ipv4(address: String) -> bool:
	var octets := address.split(".")

	if octets.size() != 4:
		return false

	for octet in octets:
		if not octet.is_valid_int():
			return false

		var value := int(octet)
		if value < 0 or value > 255:
			return false

	return true

func get_broadcast_targets() -> Array[String]:
	var unique_targets: Array[String] = [
		_MULTICAST_IP,
		_BROADCAST_IP
	]

	for interface_value in IP.get_local_interfaces():
		var interface: Dictionary = interface_value
		var addresses: Array = interface.get("addresses", [])

		for address_value in addresses:
			var address := str(address_value)

			if not is_ipv4(address):
				continue

			var octets := address.split(".")
			var first := int(octets[0])

			# Ignora loopback, link-local e multicast.
			if first == 127 or first == 169:
				continue
			if first == 0 or first >= 224:
				continue

			# APROXIMAÇÃO: assume máscara /24.
			var broadcast := "%s.%s.%s.255" % [
				octets[0],
				octets[1],
				octets[2]
			]

			unique_targets.append(broadcast)

	return unique_targets