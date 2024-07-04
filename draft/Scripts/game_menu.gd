extends Control

@onready var click_audio = $ClickAudio
@onready var hover_audio = $HoverAudio

var main_scene = preload("res://Scenes/main.tscn");
var home_scene = preload("res://Scenes/main_menu.tscn");

var button_scenes = {
	"HomeButton": home_scene,
	"CricketButton": main_scene,
}

func _ready():
	# Connect signals for all buttons in the "menu_buttons" group
	for button in get_tree().get_nodes_in_group("buttons"):
		button.mouse_entered.connect(_on_button_hover)
		button.pressed.connect(_on_button_click.bind(button.name))

func _on_button_hover():
	hover_audio.play();

func _on_button_click(button_name: String):
	click_audio.play();
	await click_audio.finished

	if button_scenes.has(button_name):
		get_tree().change_scene_to_packed(button_scenes[button_name])
	else:
		print(button_name + " clicked")
