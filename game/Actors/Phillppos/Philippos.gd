extends KinematicBody2D

export(int) var _walk_speed: int = 100
export(float) var _run_speed: float = 1.5
export(bool) var awake: bool
export(float) var acceleration: float = 0.1

var animated_sprites_to_load: Dictionary = {
	"awake": load("res://Actors/Phillppos/Awake.tres"),
	"asleep": load("res://Actors/Phillppos/Asleep.tres")
}

var _attacking: bool = false

var animated_sprites: Dictionary
var animation_called_externally: bool = false
var _sleep: bool = false
var _die: bool = false
var _velocity: Vector2 = Vector2.ZERO
var _accel: Vector2 = Vector2.ZERO
var _angular_velocity: float = 0.0
var current_status: String

onready var agent := GSAISteeringAgent.new()


func _ready() -> void:
	_set_current_status()
	#print(self.get_owner().name)
	$AnimatedSprite.frames = animated_sprites_to_load[current_status]
	update_agent()


func _get_input() -> Vector2:
	var input = Vector2.ZERO
	if Input.is_action_pressed("left"):
		input.x -= 1
	if Input.is_action_pressed("right"):
		input.x += 1
	if Input.is_action_pressed("up"):
		input.y -=1
	if Input.is_action_pressed("down"):
		input.y += 1

	if Input.is_action_pressed("attack"):
		_attacking = true
	else:
		_attacking = false
	return input


func _walk_animation(input: Vector2) -> void:
	if input.x < 0:
		if !_attacking:
			$AnimatedSprite.play("walk_left")
		else:
			$AnimatedSprite.play("attack_left")
	if input.x > 0:
		if !_attacking:
			$AnimatedSprite.play("walk_right")
		else:
			$AnimatedSprite.play("attack_right")

	if input.y < 0 and input.x == 0:
		if !_attacking:
			$AnimatedSprite.play("walk_up")
		else:
			$AnimatedSprite.play("attack_up")
	if input.y > 0 and input.x == 0:
		if !_attacking:
			$AnimatedSprite.play("walk_down")
		else:
			$AnimatedSprite.play("attack_down")

	if _attacking and !_sleep and input.x == 0 and input.y == 0:
		$AnimatedSprite.play("attack_down")

	if !_sleep and !_attacking:
		if !Gamestate.is_dialog_open() and input == Vector2.ZERO:
			clear_animation()



func _physics_process(delta: float) -> void:
	update_agent()

	var dir: Vector2 =_get_input()
	if !animation_called_externally:
		_walk_animation(dir)
		if _attacking:
			dir = Vector2.ZERO  # Stop moving AFTER the direction of attack is animated ;)


	if dir == Vector2.ZERO:
		if $Footsteps.is_playing():
			$Footsteps.stop()
	else:
		if !$Footsteps.is_playing():
			$Footsteps.play()

	var speed = _walk_speed

	if Input.is_action_pressed("run_modifier") and Gamestate.run_enabled:
		speed = _walk_speed * _run_speed

	if dir.length() > 0:
		_velocity = lerp(_velocity, dir.normalized() * speed, acceleration)
	else:
		_velocity = lerp(_velocity, Vector2.ZERO, 0.9)
	_velocity = move_and_slide(_velocity)


func _set_current_status() -> void:
	Gamestate.set_awake(awake)
	if awake:
		current_status = "awake"
		$Attack.monitoring = false
	else:
		current_status = "asleep"
		$Attack.monitoring = true


func clear_animation() -> void:
	# Play idle (first frame faces the user) THEN stop
	$AnimatedSprite.play("idle")
	$AnimatedSprite.stop()


func play_animation(animation: String) -> void:
	# clear previous animations
	animation_called_externally = true
	clear_animation()
	print("Philippos is supposed to " + animation)
	if animation in $AnimatedSprite.animation:
		if animation == "die" and awake:
			_sleep = true
		else:
			_die = true
			
		print("Starting animation!")
		if $AnimatedSprite.is_playing():
			$AnimatedSprite.stop()
		$AnimatedSprite.play(animation)


func update_agent() -> void:
	# A function used from the godot-steering-ai-framework
	agent.position.x = global_position.x
	agent.position.y = global_position.y
	agent.linear_velocity.x = _velocity.x
	agent.linear_velocity.y = _velocity.y
	agent.angular_velocity = _angular_velocity
	agent.orientation = rotation


func _on_Hurtbox_body_entered(body: Node) -> void:
	pass # Replace with function body.


func _on_Hurtbox_body_exited(body: Node) -> void:
	pass # Replace with function body.
