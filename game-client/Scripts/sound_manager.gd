extends Node

var _mutex: Mutex
var _audio_players: Dictionary = {}

var _sound_paths : Dictionary = {
	"BTN_CLICK" : "res://assets/sounds/click.ogg",
	"BTN_HOVER" : "res://assets/sounds/hover.ogg"
}

func _ready():
	_mutex = Mutex.new()
	# Pre-initialize audio players
	for sound_name in _sound_paths:
		var player = AudioStreamPlayer.new()
		player.stream = load(_sound_paths[sound_name])
		add_child(player)
		_audio_players[sound_name] = player

func _play_sound(sound_name: String) -> void:
	_mutex.lock()
	if _audio_players.has(sound_name):
		var player = _audio_players[sound_name]
		if not player.playing:
			player.play()
		else:
			# If the sound is already playing, create a temporary player
			var temp_player = AudioStreamPlayer.new()
			temp_player.stream = player.stream
			add_child(temp_player)
			temp_player.play()
			temp_player.connect("finished", Callable(temp_player, "queue_free"))
	_mutex.unlock()


func play_btn_click() : _play_sound("BTN_CLICK")
func play_btn_hover() : _play_sound("BTN_HOVER")
