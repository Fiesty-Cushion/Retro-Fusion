extends CharacterBody3D

const BAT_POSITION: Vector3 = Vector3(-2, 3.5, -7.0)

var sensitivity = 5
var damping = 0.5

var acceleration: Vector3 = Vector3.ZERO
var current_quaternion: Quaternion = Quaternion.IDENTITY
var target_quaternion: Quaternion = Quaternion.IDENTITY
const INTERPOLATION_SPEED: float = 50.0

var previous_position: Vector3
var current_velocity: Vector3
const MAX_SWING_SPEED: float = 10.0  # Maximum swing speed in m/s

@export var mass: float = 10.0  # Add mass property for physics calculations

func _ready():
	Socket.quaternion_updated.connect(_on_quaternion_updated)
	Socket.accelerometer_updated.connect(_on_accelerometer_updated)
	#previous_position = global_position

func _on_quaternion_updated(new_quaternion: Quaternion):
	target_quaternion = new_quaternion
	
func _on_accelerometer_updated(new_value):
	acceleration = new_value

func _physics_process(delta):
	current_quaternion = current_quaternion.slerp(target_quaternion, INTERPOLATION_SPEED * delta)
	global_transform.basis = Basis(current_quaternion).scaled(global_transform.basis.get_scale())
	
	# Try to simulate linear motion
	var acc = Vector3(acceleration.x, 0, acceleration.y) * sensitivity
	velocity += acc * delta
	velocity = velocity.lerp(Vector3.ZERO, damping * delta)
	
	var collision = move_and_slide()
	if collision:
		Globals.batShouldReset = true
		velocity = Vector3.ZERO;
#
	if Globals.batShouldReset:
		position = position.move_toward(BAT_POSITION, 50 * delta)
		if position == BAT_POSITION:
			Globals.batShouldReset = false
