class_name FakeBoat extends CharacterBody3D

@onready var player_input: Node = $Input

var curr_speed := 0.0

func _ready()->void:
	if is_multiplayer_authority():
		NetworkTime.on_tick.connect(_tick)

func _force_update_physics_transform():
	PhysicsServer3D.body_set_mode(get_rid(), PhysicsServer3D.BODY_MODE_STATIC)
	PhysicsServer3D.body_set_state(get_rid(), PhysicsServer3D.BODY_STATE_TRANSFORM, transform)
	PhysicsServer3D.body_set_mode(get_rid(), PhysicsServer3D.BODY_MODE_KINEMATIC)

func _tick(_delta: float, tick: int,) -> void:
	#if multiplayer.is_server():
		#print("%d:\t%f" % [tick, position.y])
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir = player_input.input_dir
	
	#curr_speed = 10.0 if not is_zero_approx(input_dir.y) else 0.0
	
	if not is_zero_approx(input_dir.y):
		curr_speed += -input_dir.y
	elif curr_speed >= -0.1 and curr_speed <= 0.1:
		curr_speed = 0
	else:
		curr_speed -= signf(curr_speed) * 0.1
	curr_speed = clamp(curr_speed, -10.0, 10.0)
	
	velocity = transform.basis.z.normalized() * curr_speed
	#velocity *= NetworkTime.physics_factor
	move_and_slide()
	#velocity /= NetworkTime.physics_factor
	
	# Get colliders to catch up
	_force_update_physics_transform()

func update_velocity_in_basis(basis_dir : Vector3, vel : float, curr_vel : Vector3)->Vector3:
	var velocity_along_axis := basis_dir * curr_vel.dot(basis_dir)
	
	if is_zero_approx(vel):
		curr_vel -= velocity_along_axis
	else:
		curr_vel -= velocity_along_axis - (basis_dir * vel)
	
	return curr_vel
