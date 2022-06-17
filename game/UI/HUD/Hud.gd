extends Control



func _ready() -> void:
	Events.connect("philippos_health_changed", self, "_on_philippos_health_changed")
	Events.connect("found_cyndi", self, "_on_found_cyndi")
	Events.connect("cyndi_health_changed", self, "_on_cyndi_health_changed")
	get_viewport().connect("size_changed", self, "_on_resize_window")
	_on_resize_window()  # Setting it up by default


func _on_philippos_health_changed(health: int) -> void:
	print("health changed... " + str(health))
	$CanvasLayer/TopHBoxContainer/PhilipposHealth/ProgressBar.value = health


func _on_cyndi_health_changed(health: int) -> void:
	print("Cyndi's health has changed" + str(health))
	$CanvasLayer/TopHBoxContainer/CyndiHealth/ProgressBar.value = health


func _on_found_cyndi() -> void:
	$CanvasLayer/TopHBoxContainer/CyndiHealth.show()


func _on_resize_window() -> void:
	$CanvasLayer/TopHBoxContainer/CenterContainer.rect_min_size.x = get_viewport_rect().size.x - 240*2
	$CanvasLayer/TopHBoxContainer/CyndiHealth.margin_right = 145
