extends Control



func _ready() -> void:
	Events.connect("philippos_health_changed", self, "change_health")


func change_health(health: int) -> void:
	print("health changed... " + str(health))
	$CanvasLayer/Health.text = str(health)
