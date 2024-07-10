extends CharacterBody3D

@export var hit_force: float = 1000.0
@export var bat_mass: float = 4.0

var is_swinging: bool = false
var swing_direction: Vector3 = Vector3.ZERO

func start_swing(direction: Vector3):
	is_swinging = true
	swing_direction = direction.normalized()

func stop_swing():
	is_swinging = false
	swing_direction = Vector3.ZERO

func _physics_process(delta):
	if is_swinging:
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(global_position, global_position + swing_direction * 3.0)
		query.collide_with_bodies = true
		query.collision_mask = collision_mask
		
		var result = space_state.intersect_ray(query)
		if result:
			var collider = result["collider"]
			if collider is RigidBody3D:
				var impulse = swing_direction * hit_force * bat_mass
				collider.apply_impulse(impulse, result["position"] - collider.global_position)
				
				# Optional: add some haptic feedback or sound effect here
				print("Hit object with force: ", impulse.length())
				
				# Stop the swing after hitting an object
				stop_swing()
