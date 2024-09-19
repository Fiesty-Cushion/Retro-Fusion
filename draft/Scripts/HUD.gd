extends Control

@onready var player_name = $MarginContainer/MarginContainer/PlayerStats/PlayerName
@onready var rich_text_label :RichTextLabel= $MarginContainer/MarginContainer/TotalScore/RichTextLabel
@onready var player_score = $MarginContainer/MarginContainer/PlayerStats/MarginContainer/PlayerScore
@onready var player_balls = $MarginContainer/MarginContainer/PlayerStats/MarginContainer/MarginContainer/PlayerBalls

var score := 0
var wicket := 0 
var ball_count :=0

func _ready():
	_on_user_connected(Globals.current_user)
	Globals.score_changed.connect(Callable(_on_score_changed))
	Globals.user_connected.connect(Callable(_on_user_connected))

func _on_score_changed(amount: int):
	ball_count+=1
	amount = 0 if amount < 0 else amount
	score = score + amount
	
	# bich ko main score
	rich_text_label.clear()
	var new_score_label = "[center]" + str(score) + " - " + str(wicket) + "[/center]"
	rich_text_label.append_text(new_score_label)
	
	# player wala score
	player_score.clear()
	player_score.append_text(str(score))
	
	# player wala balls
	player_balls.clear()
	player_balls.append_text("("+str(ball_count)+")")

func _on_user_connected(username):
	Globals.current_user = username
	player_name.clear()
	player_name.append_text(username)
