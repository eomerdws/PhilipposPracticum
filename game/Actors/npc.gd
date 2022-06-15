extends KinematicBody2D
class_name NPC

export(int) var hitpoints: int = 100
export(int) var hitpoints_flee_treshold: int = 10
export(int) var proximity_radius: int = 100

export(float) var speed_max: float = 450.0
export(float) var accel_max: float = 50.0
export (float) var angular_speed_max: float = 240
export(float) var angular_accel_max: float = 40

var _velocity: Vector2 = Vector2.ZERO
var angular_velocity: float = 0.0
var linear_drag: float = 0.1
var angular_drag: float = 0.1

# Godot Steering Variables
var acceleration := GSAITargetAcceleration.new()
onready var agent := GSAISteeringAgent.new()
onready var philippos: Node = get_tree().get_nodes_in_group("Philippos")[0]
onready var philippos_agent: GSAISteeringAgent = philippos.agent
onready var proximity := GSAIRadiusProximity.new(agent, [philippos_agent], proximity_radius)


func update_agent() -> void:
	# From godot-steering-ai-framework getting started
	agent.position.x = global_position.x
	agent.position.y = global_position.y
	agent.orientation = rotation
	agent.linear_velocity.x = _velocity.x
	agent.linear_velocity.y = _velocity.y
	agent.angular_velocity = angular_velocity


func calculate_radius(polygon: PoolVector2Array) -> float:
	# From godot-steering-ai-framework getting started
	var furthest_point: Vector2 = Vector2(-INF, -INF)
	for p in polygon:
		if abs(p.x) > furthest_point.x:
			furthest_point.x = p.x
		if abs(p.y) > furthest_point.y:
			furthest_point.y = p.y
	return furthest_point.length()
