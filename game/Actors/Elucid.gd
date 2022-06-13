extends StaticBody2D

func _ready() -> void:
	pass # Replace with function body.


func _on_PlayerDetection_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	Gamestate.open_dialog("open_euclid.json")


func _on_PlayerDetection_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	Gamestate.close_dialog()
