extends KinematicBody2D


export(int) var _walk_speed: int = 100
export(float) var _run_speed: float = 1.5
var animated_sprites_to_load: Dictionary = {
	"awake": load("res://Actors/Phillppos/Awake.tres"),
	"asleep": load("res://Actors/Phillppos/Asleep.tres")
}

var animated_sprites: Dictionary
export(String) var current_status: String = "awake"

var _motion: Vector2 = Vector2.ZERO


func _ready() -> void:
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

	if _motion == Vector2.ZERO:
		$AnimatedSprite.play("idle")
		$AnimatedSprite.stop()

	var speed = _walk_speed

	if Input.is_action_pressed("run_modifier"):
		speed = _walk_speed * _run_speed

	move_and_slide(_motion.normalized() * speed)
