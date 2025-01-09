extends Control
class_name Table

@onready var m_NodeTableRows : VBoxContainer = get_node("MarginContainer/MarginContainer3/MarginContainer2/VBoxContainer/Table/MarginContainer/DataRows")


func _ready():
	# Example rows
	CreateNewDataRow("Fiesty_Cushion", "2", "69", "6", "9")
	CreateNewDataRow("bishal_05", "19", "76", "3", "8")
	CreateNewDataRow("dhiru", "13", "83", "3", "1")
	pass
	
# Create a new TableRow object, fill in data and add to the table
func CreateNewDataRow(username : String, balls : String, runs : String, fours: String, sixes : String) -> void:
	var newTableRow : TableRow = preload("res://games/cricket/scenes/table_row.tscn").instantiate() as TableRow
	m_NodeTableRows.add_child(newTableRow)
	newTableRow.Set(username, balls, runs, fours, sixes)
