extends Node2D

var _starting: bool = true


func _on_StartTimer_timeout() -> void:
	if _starting:
		_starting = true
		Gamestate.open_dialog("asleep_initial_cyndi.json")


func _on_AttackCooldown_timeout() -> void:
	pass # Replace with function body.
