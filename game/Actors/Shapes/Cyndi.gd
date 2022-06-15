extends NPC

func _ready() -> void:
	idle()


func die() -> void:
	$AnimatedSprite.play("die")
	yield($AnimatedSprite, "animation_finished")
	queue_free()


func idle() -> void:
	# TODO: Kill ai steering. Once the animation plays re-enable it!
	print("Stop godot-ai-steering behavior here")
	$AnimatedSprite.play("idle")
	yield($AnimatedSprite, "animation_finished")
	print("Start godot-ai-steering behavior here!")
