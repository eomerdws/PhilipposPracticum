extends NPC

var has_grown: bool = false
var chase_timer_has_started: bool = false
onready var flee_blend := GSAIBlend.new(agent)
onready var pursue_blend := GSAIBlend.new(agent)
onready var priority := GSAIPriority.new(agent)


func _ready() -> void:
	change_type("enemy")
	agent.linear_speed_max = speed_max
	agent.linear_acceleration_max = accel_max
	agent.angular_speed_max = deg2rad(angular_speed_max)
	agent.angular_acceleration_max = deg2rad(angular_accel_max)
	agent.bounding_radius = calculate_radius($Hurtbox.polygon)
	update_agent()

	var pursue := GSAIPursue.new(agent, philippos_agent)
	pursue.predict_time_max = 1.5

	var flee := GSAIFlee.new(agent, philippos_agent)
	var avoid := GSAIAvoidCollisions.new(agent, proximity)
	var face := GSAIFace.new(agent, philippos_agent)

	face.alignment_tolerance = deg2rad(5)
	face.deceleration_radius = deg2rad(60)
	var look := GSAILookWhereYouGo.new(agent)
	look.alignment_tolerance = deg2rad(5)
	look.deceleration_radius = deg2rad(60)
	flee_blend.is_enabled = false
	flee_blend.add(look, 1)
	flee_blend.add(flee, 1)

	pursue_blend.is_enabled = false
	pursue_blend.add(face, 1)
	pursue_blend.add(pursue, 1)

	priority.add(avoid)
	priority.add(flee_blend)
	priority.add(pursue_blend)


func _on_Detection_body_entered(body: Node) -> void:
	if body.name == "Philippos" or body.name == "Cyndi":
		if chase_timer_has_started:
			$ChaseTimer.stop()
			chase_timer_has_started = false
		grow()


func _on_Detection_body_exited(body: Node) -> void:
	$ChaseTimer.start()
	chase_timer_has_started = true


func _on_ChaseTimer_timeout() -> void:
	$AnimatedSprite.play("shrink")
	has_grown = false
	pursue_blend.is_enabled = false

func _on_GrowTimer_timeout() -> void:
	#NOTE: This is intended to give the grow animation time to complete before moving toward the player
	has_grown = true


func _physics_process(delta: float) -> void:
	update_agent()

	if has_grown:
		pursue_blend.is_enabled = true


	priority.calculate_steering(acceleration)

	_velocity = (_velocity + Vector2(acceleration.linear.x, acceleration.linear.y) * delta).clamped(
		agent.linear_speed_max)
	_velocity = _velocity.linear_interpolate(Vector2.ZERO, linear_drag)
	# print(self.name + " velocity: " + str(_velocity))  # NOTE: That this will be n*60 every second; with n being the number of cubes on the map

	#TODO: Based on _velocity x and y values set the animation in that direction OR NOTE that it may be needed on
	# angular_velocity I am not totally sure
	_velocity = move_and_slide(_velocity)


func die() -> void:
	$AnimatedSprite.play("die")
	$AnimatedSprite.connect("animation_finished", self, "queue_free")


func grow() -> void:
	if !has_grown:
		$AnimatedSprite.play("grow")
		$GrowTimer.start()

