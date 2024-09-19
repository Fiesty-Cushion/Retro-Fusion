extends Control

@onready var rich_text_label = $MarginContainer/MarginContainer/TotalScore/RichTextLabel
var score := 0
var wicket := 0 

func _ready():
	_on_score_changed(0)
	Globals.score_changed.connect(Callable(_on_score_changed))

func _on_score_changed(amount: int):
	amount = 0 if amount < 0 else amount
	rich_text_label.clear()
	score = score + amount
	var new_score = "[center]" + str(score) + " - " + str(wicket) + "[/center]"
	rich_text_label.append_text(new_score)
