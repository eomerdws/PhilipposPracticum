extends NPC

var has_grown: bool = false
onready var flee_blend := GSAIBlend.new(agent)
onready var pursue_blend := GSAIBlend.new(agent)
onready var priority := GSAIPriority.new(agent)


func _ready() -> void:
	agent.linear_speed_max = speed_max
	agent.linear_acceleration_max = accel_max
	agent.angular_speed_max = deg2rad(angular_spped_max)
	agent.angular_acceleration_max = deg2rad(angular_accel_max)
	agent.bounding_radius = calculate_radius($Detection/CollisionShape2D.shape)


func _on_Detection_body_entered(body: Node) -> void:
	if body.name == "Philippos":
		grow()


func _on_Detection_body_exited(body: Node) -> void:
	$ChaseTimer.start()


func _on_ChaseTimer_timeout() -> void:
	pass


func _on_GrowTimer_timeout() -> void:
	#NOTE: This is intended to give the grow animation time to complete before moving toward the player
	pass


func _physics_process(delta: float) -> void:
	pass


func die() -> void:
	$AnimatedSprite.play("die")
	$AnimatedSprite.connect("animation_finished", self, "queue_free")


func grow() -> void:
	if !has_grown:
		$AnimatedSprite.play("grow")
		$GrowTimer.start()
		has_grown = true
