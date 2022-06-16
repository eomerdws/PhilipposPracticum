extends NPC

var _under_attack: bool = false
var found: bool = false
onready var flee_blend := GSAIBlend.new(agent)
onready var pursue_blend := GSAIBlend.new(agent)
onready var priorty := GSAIBlend.new(agent)


func _ready() -> void:
	Events.emit_signal("cyndi_health_changed", hitpoints)
	$IdleTimer.start()
	agent.linear_speed_max = speed_max
	agent.linear_acceleration_max = accel_max
	agent.angular_speed_max = deg2rad(angular_speed_max)
	agent.angular_acceleration_max = deg2rad(angular_accel_max)
	agent.bounding_radius = calculate_radius($Collision.polygon)
	update_agent()


func die() -> void:
	$AnimatedSprite.play("die")
	yield($AnimatedSprite, "animation_finished")
	Events.emit_signal("cyndi_died")
	queue_free()


func idle() -> void:
	print("Stop godot-ai-steering behavior here")
	$AnimatedSprite.play("idle")
	yield($AnimatedSprite, "animation_finished")
	print("Start godot-ai-steering behavior here!")



func being_attacked(damage: int) -> void:
	hitpoints -= damage
	_under_attack = true
	Events.emit_signal("cyndi_health_changed", hitpoints)
	if hitpoints < 0:
		die()


func _on_DetectPhilippos_body_entered(body: Node) -> void:
	pass


func _on_IdleTimer_timeout() -> void:
	if !_under_attack:
		idle()
		$IdleTimer.start()
