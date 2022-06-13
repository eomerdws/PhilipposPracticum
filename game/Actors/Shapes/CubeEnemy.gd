extends KinematicBody2D

var has_grown: bool = false
var move_toward_player: bool = false
var _velocity: Vector2 = Vector2.ZERO
const SPEED: int = 100


func _on_Detection_body_entered(body: Node) -> void:
	if body.name == "Philippos":
		if !has_grown:
			$AnimatedSprite.play("grow")
			has_grown = true
		else:
			move_toward_player = true


func _on_Detection_body_exited(body: Node) -> void:
	$ChaseTimer.start()


func _on_ChaseTimer_timeout() -> void:
	move_toward_player = false


func _on_GrowTimer_timeout() -> void:
	#NOTE: This is intended to give the grow animation time to complete before moving toward the player
	move_toward_player = true


func _physics_process(delta: float) -> void:
	if move_toward_player:
		print("Moving toward Philippos!")
		_velocity = Vector2.ZERO
		var _target: Vector2 = get_tree().get_nodes_in_group("Philippos")[0].position
		_velocity.move_toward(_target, delta)
		_velocity.angle_to(_target)

		move_and_collide(_velocity * SPEED)


func die() -> void:
	$AnimatedSprite.play("die")
	$AnimatedSprite.connect("animation_finished", self, "queue_free")


