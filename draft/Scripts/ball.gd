extends RigidBody3D

const BALL_VEL_MIN: int = 45
const BALL_VEL_MAX: int = 55

var can_collide = true


func _ready():
	# Set initial position
	var ball_pos: Vector3 = Vector3(0, 8.7, -50)
	ball_pos.y = randf_range(8.0, 9.0)
	self.position = ball_pos

	# Set random velocity for movement
	self.linear_velocity.z = randi_range(BALL_VEL_MIN, BALL_VEL_MAX)

	contact_monitor = true
	max_contacts_reported = 1


func _on_body_entered(body):
	if body.is_in_group("bat") and can_collide:
		set_collision_layer_value(1, false)
		can_collide = false

		get_tree().create_timer(0.9).timeout.connect(
			func(): set_collision_layer_value(1, true) ; can_collide = true
		)


func _on_timer_timeout():
	queue_free()
	pass  # Replace with function body.
