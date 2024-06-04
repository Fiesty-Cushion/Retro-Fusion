extends Control

var main_scene = preload("res://Scenes/main.tscn");
@onready var click_audio = $ClickAudio
@onready var hover_audio = $HoverAudio


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_run_button_pressed():
	click_audio.play()
	print("Starting the Game...");
	await  get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_packed(main_scene)


func _on_exit_button_pressed():
	click_audio.play()
	print("Exiting from the Game...")
	get_tree().quit()


func _on_run_button_mouse_entered():
	hover_audio.play()
	pass # Replace with function body.


func _on_exit_button_mouse_entered():
	hover_audio.play()
	pass # Replace with function body.
