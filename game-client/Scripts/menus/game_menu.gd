extends Control

@onready var button_container: HFlowContainer = $MarginContainer3/Panel/MarginContainer2/ButtonContainer
@onready var home_button: TextureButton = $MarginContainer4/HBoxContainer/HomeButton

func _ready():
	GameManager.register_game("cricket", "res://games/cricket/scenes/main.tscn", 1)
	GameManager.register_game("tt", "",2)
	GameManager.register_game("tennis", "",1)
	GameManager.register_game("baseball", "",1)
	GameManager.register_game("golf", "", 10)
	
	for name in GameManager.games.keys():
		var b := _create_button(name)
		b.mouse_entered.connect(_on_button_hover)
		b.pressed.connect(_on_button_click.bind(name))
		button_container.add_child(b)
	
	home_button.mouse_entered.connect(_on_button_hover)
	home_button.pressed.connect(_on_button_click.bind("goto_home"))
	
	GameManager.game_started.connect(_on_game_started)

func _on_button_hover():
	SoundManager.play_btn_hover()

func _on_button_click(btn_name: String):
	SoundManager.play_btn_click()
	match btn_name:
		"goto_home":
			GameManager.goto_home()
		_ :
			GameManager.start_game(btn_name)

func _create_button(name: String) -> TextureButton:
	var button = TextureButton.new()
	button.texture_normal = load("res://assets/images/buttons/" + name + "_normal.png")
	button.texture_pressed = load("res://assets/images/buttons/" + name + "_pressed.png")
	button.texture_hover = load("res://assets/images/buttons/" + name + "_hover.png")
	button.texture_disabled = load("res://assets/images/buttons/" + name + "_disabled.png")
	return button
	
func _on_game_started(_game_name: String):
	hide()
