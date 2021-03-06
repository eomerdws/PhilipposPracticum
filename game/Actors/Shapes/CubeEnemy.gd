extends NPC

var has_grown: bool = false
var chase_timer_has_started: bool = false
onready var flee_blend := GSAIBlend.new(agent)
onready var pursue_blend := GSAIBlend.new(agent)
onready var priority := GSAIPriority.new(agent)
onready var cyndi: Node = get_tree().get_nodes_in_group("Cyndi")[0]
onready var cyndi_agent: GSAISteeringAgent = cyndi.agent


func _ready() -> void:
	change_type("enemy")
	Events.connect("philippos_died", self, "_on_philippos_dead")
	# TODO: Determine if the below signal and it's method belong in the upper NPC class
	Events.connect("philippos_attacked_enemy", self, "_on_being_attacked")

	agent.linear_speed_max = speed_max
	agent.linear_acceleration_max = accel_max
	agent.angular_speed_max = deg2rad(angular_speed_max)
	agent.angular_acceleration_max = deg2rad(angular_accel_max)
	agent.bounding_radius = calculate_radius($Collision.polygon)
	update_agent()

	var pursue := GSAIPursue.new(agent, philippos_agent)
	pursue.predict_time_max = 1.5

	var pursue_cyndi := GSAIPursue.new(agent, cyndi_agent)
	pursue_cyndi.predict_time_max = 1.5

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
	pursue_blend.add(pursue_cyndi, 1)

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
	# FIXME: This is breaking some implementation because it is shutting down the cube even if it is
	# actively being attacked
	if !being_attacked and !dead:
		shrink()


func _on_GrowTimer_timeout() -> void:
	#NOTE: This is intended to give the grow animation time to complete before moving toward the player
	has_grown = true


func _on_HurtPhilipposTimer_timeout() -> void:
	philippos.being_attacked(damage_dealt)


func _physics_process(delta: float) -> void:
	if !dead:
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

		_animate(_velocity)
		_velocity = move_and_slide(_velocity)


func die() -> void:
	if !dead:  # NOTE: I don't want to do this twice for some reason
		print(name + " is dead!")
		Events.emit_signal("enemy_killed", name)
		dead = true

		$AnimatedSprite.play("die")
		yield($AnimatedSprite, "animation_finished")
		queue_free()


func _animate(dir: Vector2) -> void:
	if !dead:
		if has_grown and !being_attacked:  # NOTE: If it is being attacked we want the hurt animation to play
			if dir.x < 0:
				$AnimatedSprite.flip_h = false
				$AnimatedSprite.play("jump")
			if dir.x > 0:
				$AnimatedSprite.flip_h = true
				$AnimatedSprite.play("jump")
			if dir.y < 0 and dir.x == 0:
				$AnimatedSprite.play("jump_up")
			if dir.y > 0 and dir.x == 0:
				$AnimatedSprite.play("jump_down")
		elif has_grown and being_attacked:
			$AnimatedSprite.play("hurt")


func grow() -> void:
	if !has_grown and !dead:
		$AnimatedSprite.play("grow")
		$GrowTimer.start()


func shrink() -> void:
	if has_grown and !dead and !being_attacked:
		$AnimatedSprite.play("shrink")
		has_grown = false
		pursue_blend.is_enabled = false


func _on_being_attacked(_name: String, damage: int) -> void:
	if _name == name:
		being_attacked = true
		hitpoints -= damage
		print(name + ": " + str(hitpoints))

		if hitpoints < 1:
			being_attacked = false
			die()


func _on_Hitbox_body_entered(body: Node) -> void:
	if body.name == "Philippos" and has_grown and !dead:
		body.being_attacked(damage_dealt)
		$HurtPhilipposTimer.start()


func _on_Hitbox_body_exited(body: Node) -> void:
	if !$HurtPhilipposTimer.is_stopped() and !dead:
		being_attacked = false
		$HurtPhilipposTimer.stop()


func _on_philippos_dead() -> void:
	$Hitbox.disconnect("body_entered", self, "_on_Hitbox_body_entered")
	$Hitbox.disconnect("body_exited", self, "_on_Hitbox_body_exited")
	$Detection.disconnect("body_entered", self, "_on_Detection_body_entered")
	$Detection.disconnect("body_exited", self, "_on_Detection_body_exited")
	shrink()
