extends Control

@onready var click_audio = $ClickAudio
@onready var hover_audio = $HoverAudio

var game_menu_scene = "res://scenes/game_menu.tscn"

func _on_run_button_pressed():
	click_audio.play()
	await get_tree().create_timer(0.2).timeout

	get_tree().change_scene_to_file(game_menu_scene)


func _on_exit_button_pressed():
	click_audio.play()
	print("Exiting from the Game...")
	get_tree().quit()


func _on_run_button_mouse_entered():
	hover_audio.play()


func _on_exit_button_mouse_entered():
	hover_audio.play()
