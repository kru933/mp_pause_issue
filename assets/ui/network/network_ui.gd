extends Control

@onready var host_button: Button = $HBoxContainer/Host
@onready var client_button: Button = $HBoxContainer/Client

var ip_address := "127.0.0.1"
var port := 65123

func _enter_tree() -> void:
	NetworkEvents.on_client_start.connect(func(__): hide())
	NetworkEvents.on_server_start.connect(func(): hide())
	NetworkEvents.on_client_stop.connect(func(): show())
	NetworkEvents.on_server_stop.connect(func(): show())

func _ready()->void:
	host_button.pressed.connect(_pressed_host_button)
	client_button.pressed.connect(_pressed_client_button)
	show()

func _pressed_host_button()->void:
	var peer := ENetMultiplayerPeer.new()
	
	if peer.create_server(port) != OK:
		OS.alert("Failed to create server, port already being used?")
		return
	
	get_tree().get_multiplayer().multiplayer_peer = peer
	
	await NetworkCommon.async_condition(
		func():
			return peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTING
	)
	
	if peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		OS.alert("Failed to start the server")
		return
	
	get_tree().get_multiplayer().server_relay = true
	hide()
	

func _pressed_client_button()->void:
	var peer := ENetMultiplayerPeer.new()
	
	var err = peer.create_client(ip_address, port)
	if err != OK:
		OS.alert("Failed to create client, %s" % error_string(err))
		return
	
	get_tree().get_multiplayer().multiplayer_peer = peer
	
	
	await NetworkCommon.async_condition(
		func():
			return peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTING
	)
	
	if peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		OS.alert("Failed to connect to server")
		return
	
	hide()
