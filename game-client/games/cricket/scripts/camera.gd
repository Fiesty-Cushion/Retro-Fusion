extends Camera3D

enum CameraState {DEFAULT, FOLLOW_BALL, FOLLOW_BAT}
var state: CameraState = CameraState.DEFAULT

var follow_target: RigidBody3D = null
const FOLLOW_OFFSET = Vector3.BACK * 12.0


func _ready():
	Globals.striked_ball.connect(_on_ball_hit)


func _process(delta):
	match state:
		CameraState.DEFAULT:
			global_transform.origin = Vector3(-1, 10, 7)
			rotation_degrees = Vector3(-16, 0, 0)
			
		CameraState.FOLLOW_BALL:
			if follow_target:
				global_transform.origin = follow_target.global_transform.origin + FOLLOW_OFFSET
				look_at(follow_target.global_transform.origin, Vector3.UP)
	


func set_follow_target(target: Node):
	state = CameraState.FOLLOW_BALL
	follow_target = target


func reset():
	state = CameraState.DEFAULT
	follow_target = null


func _on_ball_hit():
	var ball = find_current_ball()
	if not ball:
		return
	
	set_follow_target(ball)


func find_current_ball():
	var item = get_tree().get_first_node_in_group("ball")
	item if item else null
