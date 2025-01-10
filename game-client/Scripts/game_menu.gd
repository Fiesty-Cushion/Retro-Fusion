extends Control

var cricket_main_scene = preload("res://games/cricket/scenes/main.tscn")
var home_scene = preload("res://scenes/main_menu.tscn")

var button_scenes = {
	"HomeButton": home_scene,
	"CricketButton": cricket_main_scene,
}

func _ready():
	# Connect signals for all buttons in the "menu_buttons" group
	for button in get_tree().get_nodes_in_group("buttons"):
		button.mouse_entered.connect(_on_button_hover)
		button.pressed.connect(_on_button_click.bind(button.name))

func _on_button_hover():
	SoundManager.play_btn_hover()

func _on_button_click(button_name: String):
	SoundManager.play_btn_click()
	if button_scenes.has(button_name):
		get_tree().change_scene_to_packed(button_scenes[button_name])
	else:
		print(button_name + " clicked")
