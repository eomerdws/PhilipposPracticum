extends KinematicBody2D

export(int) var _walk_speed: int = 100
export(float) var _run_speed: float = 1.5
export(bool) var awake: bool
export(float) var acceleration: float = 0.1
export(int) var health: int = 100


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
enum possible_directions {left, right, up, down}
var _current_direction = possible_directions.down

onready var agent := GSAISteeringAgent.new()


func _ready() -> void:
	_set_current_status()
	#print(self.get_owner().name)
	$AnimatedSprite.frames = animated_sprites_to_load[current_status]
	Events.emit_signal("philippos_health_changed", health)
	update_agent()


func _get_input() -> Vector2:
	var input = Vector2.ZERO
	if Gamestate.is_dialog_open():
		return input

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


func _walk_animation(input: Vector2, delta: float) -> void:
	var get_animation: String = ""

	if !_attacking:
		get_animation = "walk"
	else:
		get_animation = "attack"

	if input.x < 0:
		_current_direction = possible_directions.left

	if input.x > 0:
		_current_direction = possible_directions.right

	if input.y < 0 and input.x == 0:
		_current_direction = possible_directions.up

	if input.y > 0 and input.x == 0:
		_current_direction = possible_directions.down

	$AnimatedSprite.play(get_animation_by_dir(get_animation))

	if _attacking and !_sleep and input.x == 0 and input.y == 0:
		# TODO: With the new system determine if this condition can be simplified
		$AnimatedSprite.play(get_animation_by_dir("attack"))

	attack_rotation()
	if !_sleep and !_attacking and !_die:
		if !Gamestate.is_dialog_open() and input == Vector2.ZERO:
			clear_animation()


func attack_rotation() -> void:
	var rotate_attack: float = 0.0
	match _current_direction:
		possible_directions.left:
			rotate_attack = 3.141593
		possible_directions.right:
			rotate_attack = 0
		possible_directions.up:
			rotate_attack = -1.570796
		possible_directions.down:
			rotate_attack = 1.570796
		_:
			rotate_attack = 1.570796

	$Attack.rotation = rotate_attack


func get_animation_by_dir(type_animation: String) -> String:
	match _current_direction:
		possible_directions.left:
			return type_animation + "_left"
		possible_directions.right:
			return type_animation + "_right"
		possible_directions.up:
			return type_animation + "_up"
		possible_directions.down:
			return type_animation + "_down"
		_:
			return "idle"


func _physics_process(delta: float) -> void:
	update_agent()
	var dir: Vector2 = Vector2.ZERO

	if !_die and !_sleep:
		dir = _get_input()

	if !animation_called_externally:
		_walk_animation(dir, delta)
		if _attacking:
			dir = Vector2.ZERO  # Stop moving AFTER the direction of attack is animated ;)


	if dir == Vector2.ZERO:
		if $Audio/Footsteps.is_playing():
			$Audio/Footsteps.stop()
	else:
		if !$Audio/Footsteps.is_playing():
			$Audio/Footsteps.play()

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
	if !_die:
		var face_direction: String
		match _current_direction:
			possible_directions.left:
				face_direction = "walk_left"
			possible_directions.right:
				face_direction = "walk_right"
			possible_directions.up:
				face_direction = "walk_up"
			possible_directions.down:
				face_direction = "walk_down"
			_:
				face_direction = "idle"

		$AnimatedSprite.play(face_direction)
		$AnimatedSprite.frame = 0
		$AnimatedSprite.stop()


func play_animation(animation: String) -> void:
	# clear previous animations
	if !_die:
		animation_called_externally = true
		clear_animation()
		print("Philippos is supposed to " + animation)
		if animation in $AnimatedSprite.get_sprite_frames().get_animation_names():
			if animation == "sleep" and awake:
				_sleep = true

			print("Starting animation!")
			if $AnimatedSprite.is_playing():
				$AnimatedSprite.stop()
			$AnimatedSprite.play(animation)
		#else: # NOTE: For debugging only as I don't want the output clogged
		#	print("Animation %s is not in this set" %animation)


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


func being_attacked(damage: int) -> void:
	if !_die:
		health -= damage

		Events.emit_signal("philippos_health_changed", health)

	if health <= 0:
		die()


func die() -> void:
	if !_die:
		$Audio/Death.play()
		play_animation("die")
		_die = true
		Events.emit_signal("philippos_died")
		# TODO: Determine if we restart the level or have a menu or what
		print("Died and now need to start the main menu or the level over")


func _on_IdleTimer_timeout() -> void:
	pass # Replace with function body.
