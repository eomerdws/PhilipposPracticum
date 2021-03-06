extends KinematicBody2D

func _ready() -> void:
	pass # Replace with function body.


func _on_PlayerDetection_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	print(area.name + " entered Euclid's space")
	Gamestate.open_dialog("awake_open_euclid.json")


func _on_PlayerDetection_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	Gamestate.close_dialog()


func play_animation(animation: String) -> void:
	if animation in $AnimatedSprite.get_sprite_frames().get_animation_names():
		if $AnimatedSprite.is_playing():
			$AnimatedSprite.stop()
		$AnimatedSprite.play(animation)


func clear_animation() -> void:
	$AnimatedSprite.play("talking4")
	$AnimatedSprite.stop()
