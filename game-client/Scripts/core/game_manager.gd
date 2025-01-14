extends Node

class GameInfo:
	var Name : String = ""
	var ScenePath : String = ""
	var NoOfPlayers : int = 1

var games : Dictionary = {}
var current_game :Node = null
var current_game_name : String = ""

signal game_started(game_name: String)
signal game_ended(game_name: String)

func register_game(name: String, scene_path: String, no_of_players: int) -> void :
	var g := GameInfo.new()
	g.Name = name
	g.ScenePath = scene_path
	g.NoOfPlayers = no_of_players
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
	
	# start websocket and broadcasting
	var ws_port = Socket.start_web_socket(game.NoOfPlayers)
	if ws_port == -1:
		printerr("Failed to start WebSocket server")
		return
	Udp.start_broadcasting(ws_port)
		
	# load the game scene
	var scene = load(game.ScenePath) as PackedScene
	if scene:
		current_game = scene.instantiate()
		get_tree().root.add_child(current_game)
		current_game_name = name
		emit_signal("game_started", name)
	else:
		printerr("Failed to load scene: ", game.ScenePath)

func _end_game():
	if current_game:
		save_state()
		current_game.queue_free()
		emit_signal("game_ended", current_game_name)
		current_game = null
		current_game_name = ""
	
	Socket.stop_web_socket()
	Udp.stop_broadcasting()
		
func save_state():
	if current_game.has_method("serialize"):
		print("State of ", current_game_name)
		print(current_game.serialize())
	else:
		printerr(current_game_name, "doesn't implement save_state()")
		
func load_state():
	pass
