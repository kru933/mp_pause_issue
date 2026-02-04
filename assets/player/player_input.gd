extends BaseNetInput

@onready var camera_3d: Camera3D = %Camera3D

var jump_pressed := false
var run_pressed := false
var input_dir := Vector2()

var is_setup := false

var mouse_rotation: Vector2 = Vector2.ZERO
var look_angle: Vector2 = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return
	
	if event.is_action_pressed("pause"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		mouse_rotation.y += event.relative.x * 0.005
		mouse_rotation.x += event.relative.y * 0.005

func _gather()->void:
	if not is_setup:
		is_setup = true
		camera_3d.current = true
	
	jump_pressed = Input.is_action_pressed("jump")
	run_pressed = Input.is_action_pressed("run")
	input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	look_angle = Vector2()
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		look_angle = Vector2(-mouse_rotation.y, -mouse_rotation.x)
	mouse_rotation = Vector2.ZERO
