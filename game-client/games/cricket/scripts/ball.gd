extends RigidBody3D

const BALL_VEL_MIN: int = 40
const BALL_VEL_MAX: int = 45

var can_collide := true

var camera: Camera3D
var bat_hit = false

enum BowlType {STRAIGHT, LEG_SPIN, OFF_SPIN, SEAM, SWING}
var bowl_type: BowlType
var wickets_position: Vector3
const SPIN_FORCE := [2.0, 4.0, 6.0]
const SWING_FORCE: float = 10.0
const SEAM_VARIATION: float = 10.0

func _ready():
	contact_monitor = true
	max_contacts_reported = 1
	
	camera = get_parent().get_node("Camera3D")
	
	bowl_type = BowlType.values()[randi() % BowlType.size()]
	wickets_position = get_tree().get_first_node_in_group("wickets_marker").global_position
	setup_bowl()

func setup_bowl():
	var ball_pos = Vector3(randf_range(-2, 2), randf_range(8.0, 9.0), -50)
	position = ball_pos
	
	var direction = (wickets_position - position).normalized()
	var speed = randf_range(BALL_VEL_MIN, BALL_VEL_MAX)
	linear_velocity = direction * speed

	match bowl_type:
		BowlType.LEG_SPIN:
			apply_torque(Vector3(0, 0, SPIN_FORCE[randi() % SPIN_FORCE.size()]))
		BowlType.OFF_SPIN:
			apply_torque(Vector3(0, 0, -SPIN_FORCE[randi() % SPIN_FORCE.size()]))
		BowlType.SWING:
			apply_central_force(Vector3(randf_range(-SWING_FORCE, SWING_FORCE), 0, randf_range(-SWING_FORCE, SWING_FORCE)))
		BowlType.SEAM:
			# Apply spin after a delay
			get_tree().create_timer(0.5).connect("timeout", Callable(self, "apply_seam"))
			
func apply_seam():
	linear_velocity = linear_velocity * 1.3
	apply_torque(Vector3(0, 0, randf_range(-SEAM_VARIATION, SEAM_VARIATION)))


func _process(_delta):
	if (not bat_hit) && linear_velocity.length() < 30.0:
		linear_velocity = linear_velocity.normalized() * 30.0

func _integrate_forces(state):
	if state.get_contact_count() > 0 and can_collide:
		var collision_object = state.get_contact_collider_object(0)
		if collision_object.is_in_group("bat"):
			Globals.striked_ball.emit()
			bat_hit = true

func _on_body_entered(body):
	if body.is_in_group("bat"):
		camera.set_follow_target(self)
		
		# Create a timer for the camera to follow the ball trajectory		
		get_tree().create_timer(3.0).timeout.connect(func() -> void:
			camera.reset()
		)

func is_hit():
	return bat_hit
