class_name FakeBoat extends CharacterBody3D

@onready var player_input: Node = $Input

var curr_speed := 0.0

func _ready()->void:
	NetworkTime.on_tick.connect(_tick)

func _force_update_physics_transform():
	PhysicsServer3D.body_set_mode(get_rid(), PhysicsServer3D.BODY_MODE_STATIC)
	PhysicsServer3D.body_set_state(get_rid(), PhysicsServer3D.BODY_STATE_TRANSFORM, transform)
	PhysicsServer3D.body_set_mode(get_rid(), PhysicsServer3D.BODY_MODE_KINEMATIC)

func _tick(_delta: float, _tick: int) -> void:
	# Get the input direction and handle the movement/deceleration.
	var input_dir = player_input.input_dir
	
	if not is_zero_approx(input_dir.y):
		curr_speed += -input_dir.y
	elif curr_speed >= -0.1 and curr_speed <= 0.1:
		curr_speed = 0
	else:
		curr_speed -= signf(curr_speed) * 0.1
	curr_speed = clamp(curr_speed, -10.0, 10.0)
	
	velocity = transform.basis.z.normalized() * curr_speed
	velocity *= NetworkTime.physics_factor
	move_and_slide()
	velocity /= NetworkTime.physics_factor
	
	# Get colliders to catch up
	_force_update_physics_transform()
