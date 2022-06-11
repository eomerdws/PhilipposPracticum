extends KinematicBody2D


export(int) var speed: int = 100
var animated_sprites_to_load: Dictionary = {
	"awake": load("res://Actors/Phillppos/Awake.tres"),
	"asleep": load("res://Actors/Phillppos/Asleep.tres")
}

var animated_sprites: Dictionary
var current_status: String = "awake"

var _motion: Vector2 = Vector2.ZERO


func _ready() -> void:
	$AnimatedSprite.frames = animated_sprites_to_load[current_status]

func _physics_process(delta: float) -> void:
	_motion = Vector2.ZERO

	if Input.is_action_pressed("left"):
		_motion.x -= 1
		$AnimatedSprite.play("walk_left")
	elif Input.is_action_pressed("right"):
		_motion.x += 1
		$AnimatedSprite.play("walk_right")
	else:
		_motion.x = 0


	if Input.is_action_pressed("up"):
		_motion.y -= 1
		$AnimatedSprite.play("walk_up")
	elif Input.is_action_pressed("down"):
		_motion.y += 1
		$AnimatedSprite.play("walk_down")
	else:
		_motion.y = 0

	if _motion == Vector2.ZERO:
		$AnimatedSprite.play("idle")
		$AnimatedSprite.stop()

	move_and_slide(_motion.normalized() * speed)
