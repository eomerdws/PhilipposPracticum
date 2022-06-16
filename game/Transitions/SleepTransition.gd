extends CanvasLayer


func _ready() -> void:
	Events.connect("transition_to_sleep", self, "start")


func _on_transition_halfway() -> void:
	Events.emit_signal("transition_halfway", "sleep")


func _load_level() -> void:
	get_tree().change_scene("res://Levels/Dream/SquareIsland.tscn")


func start() -> void:
	print("Starting sleep transition")
	$Control/Sleepy.visible = true
	$AnimationPlayer.play("to_sleep")


func _sleep() -> void:
	# TODO: Play sleep sound
	Events.emit_signal("dialog_calls_animation_play", "Philippos", "sleep")
	print("Philippos is asleep")
