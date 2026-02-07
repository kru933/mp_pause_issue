extends Node

var input_dir := Vector2()
var temp := false

func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return
	
	# Hack way to get the host to move the boat forward
	if event.is_action_pressed("debug"):
		temp = not temp

func _process(_delta):
	if not is_multiplayer_authority():
		return
	
	_gather()

# Called by networking class
func _gather() -> void:
	if temp:
		input_dir = Vector2(0, -1)
	else:
		input_dir = Vector2()
