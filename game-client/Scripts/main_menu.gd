extends Control

var game_menu_scene = "res://scenes/game_menu.tscn"

# For character animations
@onready var characters: Node3D = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/MarginContainer/SubViewportContainer/SubViewport/Characters
@onready var knight_anim = characters.get_node("Knight/AnimationPlayer")
@onready var rogue_anim = characters.get_node("Rogue_Hooded/AnimationPlayer")
@onready var barbarian_anim = characters.get_node("Barbarian/AnimationPlayer")

func _ready() -> void:
	_initialize_animation(knight_anim, 0.8, "Idle", 0.3)
	_initialize_animation(rogue_anim, 0.8, "Idle", 0.3)
	_initialize_animation(barbarian_anim, 0.8, "Idle", 0.3)

func _on_run_button_pressed():
	SoundManager.play_btn_click()
	await get_tree().create_timer(0.2).timeout

	get_tree().change_scene_to_file(game_menu_scene)


func _on_exit_button_pressed():
	SoundManager.play_btn_click()
	get_tree().quit()

func _on_run_button_mouse_entered(): SoundManager.play_btn_hover()

func _on_exit_button_mouse_entered(): SoundManager.play_btn_hover()

func _initialize_animation(player: AnimationPlayer, speed_scale: float, animation_name: String, delay: float):
	player.set_speed_scale(speed_scale)
	player.play(animation_name)
	await get_tree().create_timer(delay).timeout
