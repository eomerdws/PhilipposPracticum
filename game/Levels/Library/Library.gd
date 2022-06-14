extends Node2D


func _ready() -> void:
	if Gamestate.starting:
		Gamestate.open_dialog("awake_initial_dialog.json")
