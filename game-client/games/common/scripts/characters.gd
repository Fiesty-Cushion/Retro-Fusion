extends Node3D

@onready var knight_anim = $Knight/AnimationPlayer
@onready var rogue_anim = $Rogue_Hooded/AnimationPlayer
@onready var barbarian_anim = $Barbarian/AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	knight_anim.set_speed_scale(0.8)
	knight_anim.play("Idle")
	await get_tree().create_timer(0.3).timeout
	rogue_anim.set_speed_scale(0.8)
	rogue_anim.play("Idle")
	await get_tree().create_timer(0.3).timeout
	barbarian_anim.set_speed_scale(0.8)
	barbarian_anim.play("Idle")
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
