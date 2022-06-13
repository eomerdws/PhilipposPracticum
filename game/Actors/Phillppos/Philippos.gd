extends KinematicBody2D


export(int) var _walk_speed: int = 100
export(float) var _run_speed: float = 1.5
var animated_sprites_to_load: Dictionary = {
	"awake": load("res://Actors/Phillppos/Awake.tres"),
	"asleep": load("res://Actors/Phillppos/Asleep.tres")
}

var animated_sprites: Dictionary
var die_sleep: bool = false
export(String) var current_status: String

var _motion: Vector2 = Vector2.ZERO


func _ready() -> void:
	_set_current_status()
	$AnimatedSprite.frames = animated_sprites_to_load[current_status]


func _physics_process(delta: float) -> void:
	_motion = Vector2.ZERO

	if Input.is_action_pressed("left"):
		_motion.x -= 1
		$AnimatedSprite.play("walk_left")
	if Input.is_action_pressed("right"):
		_motion.x += 1
		$AnimatedSprite.play("walk_right")
	if Input.is_action_pressed("up"):
		_motion.y -= 1
		if not (Input.is_action_pressed("left") or Input.is_action_pressed("right")):
			$AnimatedSprite.play("walk_up")
	if Input.is_action_pressed("down"):
		_motion.y += 1
		if not (Input.is_action_pressed("left") or Input.is_action_pressed("right")):
			$AnimatedSprite.play("walk_down")

	# TODO: Figure out how to setup the attack system. Remember he can move in 4 different directions to attack
	# So you have to figure out the direction of the character && the spear + the attack button pressed
	# + not mess up the normal movement

	if Input.is_action_pressed("attack"):
		$AnimatedSprite.play("attack_left")
		_motion.x += 1

	if !die_sleep:
		if !Gamestate.is_dialog_open() and _motion == Vector2.ZERO:
			clear_animation()

	if _motion == Vector2.ZERO:
		if $Footsteps.is_playing():
			$Footsteps.stop()
	else:
		if !$Footsteps.is_playing():
			$Footsteps.play()

	var speed = _walk_speed

	if Input.is_action_pressed("run_modifier") and Gamestate.run_enabled:
		speed = _walk_speed * _run_speed

	move_and_slide(_motion.normalized() * speed)


func _set_current_status() -> void:
	if Gamestate.awake:
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
	clear_animation()
	print("Philippos is supposed to " + animation)
	if animation in $AnimatedSprite.animation:
		if animation == "die":
			die_sleep = true
		print("Starting animation!")
		if $AnimatedSprite.is_playing():
			$AnimatedSprite.stop()
		$AnimatedSprite.play(animation)
