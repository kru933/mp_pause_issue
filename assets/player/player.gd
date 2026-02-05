class_name Player extends CharacterBody3D

const SPEED = 5.0
const RUN_SPEED = 7.5
const JUMP_VELOCITY = 4.5

@onready var camera_3d = %Camera3D
@onready var player_input: Node = $PlayerInput
@onready var boat = get_tree().get_first_node_in_group("FakeBoat")

var is_on_boat := false
var boat_vel := Vector3()

func _ready()->void:
	if is_multiplayer_authority():
		NetworkTime.before_tick_loop.connect(_gather)

func _gather()->void:
	boat_vel = boat.velocity
	is_on_boat = true

func _force_update_is_on_floor():
	var old_velocity = velocity
	velocity = Vector3.ZERO
	move_and_slide()
	velocity = old_velocity

func _force_update_physics_transform():
	PhysicsServer3D.body_set_mode(get_rid(), PhysicsServer3D.BODY_MODE_STATIC)
	PhysicsServer3D.body_set_state(get_rid(), PhysicsServer3D.BODY_STATE_TRANSFORM, transform)
	PhysicsServer3D.body_set_mode(get_rid(), PhysicsServer3D.BODY_MODE_KINEMATIC)

func _rollback_tick(delta: float, _tick: int, _is_fresh: bool) -> void:
	if multiplayer.is_server():
		print(name)
	
	_force_update_is_on_floor()
	
	
	var updated_velocity := velocity
	
	# Gravity
	#if not is_on_floor():
		#updated_velocity += global_transform.basis.y * -9.8 * delta
	
	# Camera rotation
	rotate_object_local(Vector3.UP, player_input.look_angle.x)
	camera_3d.rotate_x(player_input.look_angle.y)
	camera_3d.rotation.x = clampf(camera_3d.rotation.x, -deg_to_rad(90), deg_to_rad(90))
	
	# Handle jump.
	if player_input.jump_pressed and is_on_floor():
		updated_velocity += Vector3.UP * JUMP_VELOCITY
	
	# Handle running.
	var curr_speed : float = SPEED
	if player_input.run_pressed:
		curr_speed = RUN_SPEED
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir : Vector2 = player_input.input_dir
	updated_velocity = update_velocity_in_basis(transform.basis.x.normalized(), input_dir.x * curr_speed, updated_velocity)
	updated_velocity = update_velocity_in_basis(transform.basis.z.normalized(), input_dir.y * curr_speed, updated_velocity)
	
	# Update velocity for move_and_slide()
	velocity = updated_velocity
	
	# Add boat velocity
	if is_on_boat:
		velocity += boat_vel
	
	velocity *= NetworkTime.physics_factor
	move_and_slide()
	
	# Remove boat/rollback from velocity
	velocity /= NetworkTime.physics_factor
	if is_on_boat:
		velocity -= boat_vel
	
	#if multiplayer.is_server() and player_input.get_multiplayer_authority() != 1:
		#prints(is_on_boat, velocity, boat_vel, global_position)
	
	# Force the colliders to catch up
	_force_update_physics_transform()

# This exists because the main project has weird gravity
func update_velocity_in_basis(basis_dir : Vector3, vel : float, curr_vel : Vector3)->Vector3:
	var velocity_along_axis := basis_dir * curr_vel.dot(basis_dir)
	
	if is_zero_approx(vel):
		curr_vel -= velocity_along_axis
	else:
		curr_vel -= velocity_along_axis - (basis_dir * vel)
	
	return curr_vel
