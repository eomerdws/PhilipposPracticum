extends KinematicBody2D


export(int) var speed: int = 100
onready var animated_sprites_to_load: Dictionary = {
	"awake": preload("res://Actors/Phillppos/Awake.tscn").instance(),
	"asleep": preload("res://Actors/Phillppos/Asleep.tscn").instance()
}

var animated_sprites: Dictionary
var current_status: String = "awake"

var _motion: Vector2 = Vector2.ZERO


func _ready() -> void:
	$Sprite.add_child(animated_sprites_to_load[current_status])
	_reload_animated_sprites()


func _physics_process(delta: float) -> void:
	_motion = Vector2.ZERO

	if Input.is_action_pressed("left"):
		_motion.x -= 1
		animated_sprites[current_status].play("walk_left")
	elif Input.is_action_pressed("right"):
		_motion.x += 1
		animated_sprites[current_status].play("walk_right")
	else:
		_motion.x = 0


	if Input.is_action_pressed("up"):
		_motion.y -= 1
		animated_sprites[current_status].play("walk_up")
	elif Input.is_action_pressed("down"):
		_motion.y += 1
		animated_sprites[current_status].play("walk_down")
	else:
		_motion.y = 0

	if _motion == Vector2.ZERO:
		animated_sprites[current_status].play("idle")

	move_and_slide(_motion.normalized() * speed)
	animated_sprites[current_status].position = position # This is the weirdest thing I have seen ever. I don't know why the animated sprite is not changing position with it's parent


func _reload_animated_sprites() -> void:
	animated_sprites.clear()
	animated_sprites = {
		"awake": $Sprite/Awake,
		"asleep": $Sprite/Asleep
	}

	#Weird crap
	animated_sprites[current_status].position = position
