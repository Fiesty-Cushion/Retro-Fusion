@tool

extends HBoxContainer
class_name TableRow

@export var UserName : String = ""
@export var Balls : String = ""
@export var Runs : String = ""
@export var Fours : String = ""
@export var Sixes : String = ""

@onready var m_NodeColumnUserName : Label = get_node("ColumnUserName")
@onready var m_NodeColumnBalls : Label = get_node("ColumnBalls")
@onready var m_NodeColumnRuns : Label = get_node("ColumnRuns")
@onready var m_NodeColumnFours : Label = get_node("Column4s")
@onready var m_NodeColumnSixes : Label = get_node("Column6s")


func _ready():
	Set(UserName, Balls, Runs, Fours, Sixes)
	
# Set the table row fields with the given data
func Set(username : String, balls : String, runs : String, fours: String, sixes : String) -> void:
	m_NodeColumnUserName.set_text(username)
	m_NodeColumnBalls.set_text(balls)
	m_NodeColumnRuns.set_text(runs)
	m_NodeColumnFours.set_text(fours)
	m_NodeColumnSixes.set_text(sixes)
