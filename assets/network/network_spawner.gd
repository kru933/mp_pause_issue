extends Node

enum LOCATIONS {FARM, DISC, OBSERVATION, MOUNTAIN}

@export var boat_scene : PackedScene
@export var player_scene : PackedScene
@export var spawn_container : Node
@export var start_location : LOCATIONS

var avatars := {}
var boat : Node3D = null

func _ready()->void:
	NetworkEvents.on_client_start.connect(_on_client_start)
	NetworkEvents.on_client_stop.connect(_disconnected)
	NetworkEvents.on_server_start.connect(_on_server_start)
	NetworkEvents.on_server_stop.connect(_disconnected)
	NetworkEvents.on_peer_join.connect(_on_peer_join)
	NetworkEvents.on_peer_leave.connect(_peer_disconnected)

func _spawn_player(id : int)->void:
	var avatar : Player = player_scene.instantiate()
	# Setup before adding to tree
	avatars[id] = avatar
	avatar.name = "Player_%s" % id
	# Add to tree
	if 1:
		boat.add_child(avatar)
	else:
		spawn_container.add_child(avatar)
	# Setup after adding
	avatar.global_transform = _get_spawn_point(true, id == 1)
	# The Player is owned by the server but the PlayerInput is owned by the client
	avatar.set_multiplayer_authority(id)
	avatar.update_auth()
	#avatar.player_input.set_multiplayer_authority(id)
	#avatar.get_node("RollbackSynchronizer").process_settings()

func _spawn_boat(id : int)->void:
	boat = boat_scene.instantiate()
	# Add to tree
	spawn_container.add_child(boat)
	# Setup after adding
	boat.global_transform = _get_spawn_point(false, true)
	# The Boat is owned by the server but Input can be changed. Defaults to host
	boat.set_multiplayer_authority(1)
	boat.player_input.set_multiplayer_authority(1)

func _get_spawn_point(is_player : bool, first)->Transform3D:
	var spawn_transform := Transform3D()
	var start_txt : String = LOCATIONS.keys()[start_location].to_lower()
	
	for c in get_children():
		if start_txt in c.name.to_lower():
			if is_player and "player" in c.name.to_lower():
				if first or not first and "2" in c.name:
					spawn_transform = c.global_transform
					break
			elif not is_player and "boat" in c.name.to_lower():
				spawn_transform = c.global_transform
				break
	
	return spawn_transform

func _on_client_start(id : int)->void:
	_spawn_boat(id)
	_spawn_player(id)

func _on_server_start()->void:
	_spawn_boat(1)
	_spawn_player(1)

func _on_peer_join(id : int)->void:
	_spawn_player(id)

func _spawn_host_client()->void:
	_spawn_player(1)

func _peer_disconnected(id : int)->void:
	if avatars.has(id):
		avatars[id].queue_free()
		avatars.erase(id)

func _disconnected()->void:
	for key in avatars:
		avatars[key].queue_free()
	avatars.clear()
	
	if boat != null:
		boat.queue_free()
		boat = null
