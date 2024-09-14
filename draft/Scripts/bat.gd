extends CharacterBody3D

const BAT_POSITION: Vector3 = Vector3(-1.25, 3.554, -6.827)

var current_quaternion: Quaternion = Quaternion.IDENTITY
var target_quaternion: Quaternion = Quaternion.IDENTITY
const INTERPOLATION_SPEED: float = 50.0


func _ready():
	Socket.quaternion_updated.connect(_on_quaternion_updated)


func _on_quaternion_updated(new_quaternion: Quaternion):
	target_quaternion = new_quaternion


func _physics_process(delta):
	current_quaternion = current_quaternion.slerp(target_quaternion, INTERPOLATION_SPEED * delta)
	global_transform.basis = Basis(current_quaternion).scaled(global_transform.basis.get_scale())

	var collision = move_and_collide(Vector3.ZERO)
	if collision:
		Globals.batShouldReset = true

	if Globals.batShouldReset:
		position = position.move_toward(BAT_POSITION, delta)
		if position == BAT_POSITION:
			Globals.batShouldReset = false
