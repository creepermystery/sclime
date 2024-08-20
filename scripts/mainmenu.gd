extends Control

signal launch(color1: Color, color2: Color)

@onready var _p1 := get_node("Player1")
@onready var _p2 := get_node("Player2")



func launch_game():
	launch.emit(_p1.colors[_p1.color], _p2.colors[_p2.color])
	var name_p1 = get_node("Player1/name_1").get_text()
	var name_p2 = get_node("Player2/name_2").get_text()
	
func quit():
	get_tree().quit(0)

func help():
	get_node("HelpMenu").visible = not get_node("HelpMenu").visible

func close_help():
	get_node("HelpMenu").visible = false
	
func keyboard_controls():
	get_node("HelpMenu/Control").visible = true
	get_node("HelpMenu/Control2").visible = false
	get_node("HelpMenu/Control3").visible = false
	
func controller_controls():
	get_node("HelpMenu/Control2").visible = true
	get_node("HelpMenu/Control").visible = false
	get_node("HelpMenu/Control3").visible = false
	
func rules():
	get_node("HelpMenu/Control3").visible = true
	get_node("HelpMenu/Control2").visible = false
	get_node("HelpMenu/Control").visible = false
