extends CharacterBody3D

var camera : Camera3D
const BAT_POSITION: Vector3 = Vector3(-2, 3.5, -7.0)

var current_quaternion: Quaternion = Quaternion.IDENTITY
var target_quaternion: Quaternion = Quaternion.IDENTITY
const INTERPOLATION_SPEED: float = 50.0

var previous_position: Vector3
var current_velocity: Vector3
const MAX_SWING_SPEED: float = 10.0  # Maximum swing speed in m/s

@export var mass: float = 10.0  # Add mass property for physics calculations

func _ready():
	Socket.quaternion_updated.connect(_on_quaternion_updated)
	previous_position = global_position
	camera = get_parent().get_node("Camera3D")

func _on_quaternion_updated(new_quaternion: Quaternion):
	target_quaternion = new_quaternion


 #To make the camera follow the bat movement
#func _process(delta):
	#if camera:
		#var bat_rotation_quat: Quaternion = self.global_transform.basis.get_rotation_quaternion()
		#var direction: Vector3 = Vector3.BACK * 12.0  # The camera is 'radius' units behind the bat
		#var rotated_direction: Vector3 = bat_rotation_quat * direction
		#rotated_direction.y = max(rotated_direction.y, 0.0)
		#camera.global_transform.origin = self.global_transform.origin + rotated_direction
		#camera.look_at(self.global_transform.origin, Vector3.UP)
		#pass


func _physics_process(delta):
	current_quaternion = current_quaternion.slerp(target_quaternion, INTERPOLATION_SPEED * delta)
	global_transform.basis = Basis(current_quaternion).scaled(global_transform.basis.get_scale())

	 # Calculate velocity
	current_velocity = (global_position - previous_position) / delta
	current_velocity = current_velocity.limit_length(MAX_SWING_SPEED)
	previous_position = global_position

	var collision = move_and_collide(Vector3.ZERO)
	if collision:
		Globals.batShouldReset = true

	if Globals.batShouldReset:
		position = position.move_toward(BAT_POSITION, 10 * delta)
		if position == BAT_POSITION:
			Globals.batShouldReset = false



func get_impact_velocity(collision_point: Vector3) -> Vector3:
	# Calculate the velocity at the point of impact
	var center_to_collision = collision_point - global_position
	var angular_velocity = Quaternion(global_transform.basis.get_rotation_quaternion()).get_euler()
	var tangential_velocity = angular_velocity.cross(center_to_collision)
	return current_velocity + tangential_velocity
