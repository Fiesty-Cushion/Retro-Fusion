extends Node3D

@onready var left_stump = $LeftStump
@onready var middle_stump = $MiddleStump
@onready var right_stump = $RightStump
@onready var left_bail = $LeftBail
@onready var left_bail_2 = $LeftBail2

var wicket_components : Array

signal wicket_hit()

func _ready():
	form_array()
	for comp in wicket_components:
		comp.max_contacts_reported = 5
	freeze()
	pass
	
func form_array():
	wicket_components.append(left_stump)
	wicket_components.append(middle_stump)
	wicket_components.append(right_stump)
	wicket_components.append(left_bail)
	wicket_components.append(left_bail_2)
	
func freeze():
	for component in wicket_components:
		component.freeze = true
	
func unfreeze():
	for component in wicket_components:
		component.freeze = false

func _on_left_stump_body_entered(body):
	if(body.is_in_group("ball")):
		body.despawn()
		unfreeze()
		emit_signal("wicket_hit")
		
func _on_middle_stump_body_entered(body):
	if(body.is_in_group("ball")):
		body.despawn()
		unfreeze()
		emit_signal("wicket_hit")

func _on_right_stump_body_entered(body):
	if(body.is_in_group("ball")):
		body.despawn()
		unfreeze()
		emit_signal("wicket_hit")
		
func _on_left_bail_body_entered(body):
	if(body.is_in_group("ball")):
		body.despawn()
		unfreeze()
		emit_signal("wicket_hit")
		
func _on_left_bail_2_body_entered(body):
	if(body.is_in_group("ball")):
		body.despawn()
		unfreeze()
		emit_signal("wicket_hit")
