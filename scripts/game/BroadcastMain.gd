extends Control

var _network_discovery: NetworkDiscoveryManager

const ANNOUNCE_INTERVAL = 2.0

var _start_sending_broadcast: bool = false
var _start_listing_broadcast: bool = false

var _timer:float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _network_discovery == null:
		return
	
	

	if 	_start_sending_broadcast:
		_timer += delta
		if _timer >= ANNOUNCE_INTERVAL:
			var packet :PackedByteArray = %BroadcastSendingTextEdit.text.to_utf8_buffer()
			_network_discovery.broadcast(
				packet
			)
			_timer = 0.0

	if _start_listing_broadcast:
		if _network_discovery.has_packet_available():
			var response:Dictionary = _network_discovery.listener()
			
			_append_broadcast_listener(
				"Sender <%s>: %s" % [response.get('sender_ip'), response.get('packet').get_string_from_utf8()]
			)

func _append_broadcast_logger(message: String) -> void:
	%BroadcastLoggerTextEdit.text += "%s\n" % [message]
	%BroadcastLoggerTextEdit.scroll_vertical = (
		%BroadcastLoggerTextEdit.get_line_count()
	)

func _append_broadcast_listener(message: String) -> void:
	%BroadcastListenerTextEdit.text += "%s\n" % [message]
	%BroadcastListenerTextEdit.scroll_vertical = (
		%BroadcastListenerTextEdit.get_line_count()
	)

func _on_start_stop_broadcast_button_pressed() -> void:
	print(" - %s - %d" % [get_stack()[0]["function"], get_instance_id()])

	if _network_discovery == null:
		_network_discovery = NetworkDiscoveryManager.new()

		var port:int = int(%UDPPortLineEdit.text)
		var error = _network_discovery.initialize(port)

		if error != Error.OK:
			_append_broadcast_logger(
				"An error occurred while initializing the broadcast %s" % [error_string(error)]
			)
			return
		
		_append_broadcast_logger(
			"Broadcast binding was successfully initialized on the port <%d>" % [port]
		)

		%StartStopBroadcastButton.text = "Close Broadcast UDP"
	else:
		_network_discovery.close()
		_network_discovery = null

		_append_broadcast_logger(
			"The broadcast bind was successfully closed"
		)

		%StartStopBroadcastButton.text = "Initialize Broadcast UDP"

func _on_start_broadcast_listener_button_pressed() -> void:
	print(" - %s - %d" % [get_stack()[0]["function"], get_instance_id()])

	_start_sending_broadcast = !_start_sending_broadcast

	if _start_sending_broadcast:
		%StartBroadcastListenerButton.text = "Stop Broadcast Listening"
	else:
		%StartBroadcastListenerButton.text = "Start Broadcast Listening"
	

func _on_start_broadcast_sending_button_pressed() -> void:
	print(" - %s - %d" % [get_stack()[0]["function"], get_instance_id()])

	_start_listing_broadcast = !_start_listing_broadcast

	if _start_listing_broadcast:
		%StartBroadcastSendingButton.text = "Stop Sending Broadcast Message"
	else:
		%StartBroadcastSendingButton.text = "Start Sending Broadcast Message"
