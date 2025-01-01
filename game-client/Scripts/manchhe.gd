extends RigidBody3D

var BALL_VELOCITY = 5


# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	linear_velocity.z = BALL_VELOCITY
	print("wow")
	pass
