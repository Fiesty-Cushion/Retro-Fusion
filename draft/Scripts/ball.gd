extends RigidBody3D


const BALL_VEL_MIN: int = 40
const BALL_VEL_MAX: int = 45
const MIN_VELOCITY: float = 30.0  # Minimum velocity to maintain after collision
const MAX_VELOCITY: float = 70.0  # Maximum velocity to cap after collision
const COLLISION_COOLDOWN: float = 10.0  # Cooldown time in seconds

var can_collide := true
var last_collision_time := 0.0

var camera : Camera3D
var follow_ball = false

func _ready():
	var ball_pos: Vector3 = Vector3(0, 8.7, -50)
	ball_pos.y = randf_range(8.0, 9.0)
	position = ball_pos

	linear_velocity.z = randi_range(BALL_VEL_MIN, BALL_VEL_MAX)

	contact_monitor = true
	max_contacts_reported = 1
	
	camera = get_parent().get_node("Camera3D")


func _process(delta):
	if follow_ball:
		# Define a direction vector (camera is behind the ball)
		var direction: Vector3 = Vector3.BACK * 12.0

		# Set the camera position relative to the ball's position
		camera.global_transform.origin = self.global_transform.origin + direction
		
		# Optionally, make the camera look at the bat
		camera.look_at(get_parent().get_node("bat").global_transform.origin, Vector3.UP)
		

func _physics_process(delta):
	if not can_collide:
		if Time.get_ticks_msec() / 1000.0 - last_collision_time > COLLISION_COOLDOWN:
			can_collide = true

	# Ensure the ball always maintains a minimum velocity
	if linear_velocity.length() < MIN_VELOCITY:
		linear_velocity = linear_velocity.normalized() * MIN_VELOCITY

func _integrate_forces(state):
	if state.get_contact_count() > 0 and can_collide:

		var collision_object = state.get_contact_collider_object(0)
		if collision_object.is_in_group("bat"):
			handle_bat_collision(state, collision_object)
			Globals.striked_ball.emit()

func handle_bat_collision(state, bat):
	can_collide = false
	last_collision_time = Time.get_ticks_msec() / 1000.0
	
	var collision_point = state.get_contact_collider_position(0)
	var collision_normal = state.get_contact_local_normal(0).normalized()
	
	var bat_velocity = bat.get_impact_velocity(collision_point) if bat.has_method("get_impact_velocity") else Vector3.ZERO
	
	# Calculate the relative velocity
	var relative_velocity = linear_velocity - bat_velocity
	
	# Calculate the impulse
	var impulse = -(1.0 + 0.8) * relative_velocity.dot(collision_normal) / (1.0 / mass + 1.0 / bat.mass)
	impulse = max(impulse, 0)  # Ensure positive impulse
	
	# Apply the impulse
	var impulse_vector = collision_normal * impulse
	apply_central_impulse(impulse_vector)
	
	# Add some randomness to prevent predictable bounces
	apply_central_impulse(Vector3(randf_range(-1, 1), randf_range(0, 1), randf_range(-1, 1)).normalized() * impulse * 0.2)
	
	# Ensure the ball doesn't exceed maximum velocity
	linear_velocity = linear_velocity.limit_length(MAX_VELOCITY)
	
	# Add a slight upward force to prevent horizontal sliding
	apply_central_force(Vector3.UP * 9.8 * mass * 0.5)


func _on_timer_timeout():
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("bat"):
		follow_ball = true
		
		# Create a timer for the camera to follow the ball trajectory
		await get_tree().create_timer(3.0).timeout.connect(func() -> void:
			follow_ball = false
			camera.position = Vector3(-1, 10, 7)
			camera.rotation_degrees = Vector3(-16, 0, 0)
		)
