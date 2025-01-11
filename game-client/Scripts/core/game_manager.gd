extends Node

class GameInfo:
	var Name : String = ""
	var ScenePath : String = ""
	
var games : Dictionary = {}
var current_game :Node = null
var current_game_state : Dictionary = {}

signal game_started(game_name: String)
signal game_ended(game_name: String)

func register_game(name: String, scene_path: String) -> void :
	var g := GameInfo.new()
	g.Name = name
	g.ScenePath = scene_path
	games[name] = g

func goto_home():
	if current_game:
		_end_game()
	get_tree().change_scene_to_packed(preload("res://scenes/main_menu.tscn"))
	
func goto_game_menu():
	if current_game:
		_end_game()
	get_tree().change_scene_to_packed(preload("res://scenes/game_menu.tscn")) 
	
func start_game(name: String) :
	if not games.has(name):
		printerr("unknown game ",name)
		
	var game : GameInfo = games[name]
	if game.ScenePath == "":
		printerr("no scene provided for ", name)
		return
		
	if current_game:
		_end_game()
	
	var scene = load(game.ScenePath) as PackedScene
	if scene:
		current_game = scene.instantiate()
		get_tree().root.add_child(current_game)
		emit_signal("game_started", name)
	else:
		printerr("Failed to load scene: ", game.ScenePath)

func _end_game():
	if current_game:
		current_game.queue_free()
		emit_signal("game_ended", current_game.name)
		current_game = null
		
func save_state():
	pass
func load_state():
	pass
