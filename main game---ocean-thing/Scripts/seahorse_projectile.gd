extends CharacterBody2D

@export var speed = 500
var dir : float
var SpawnPos : Vector2
var SpawnRot : float

func _ready() -> void:
	global_position = SpawnPos
	global_rotation = SpawnRot

	
	
func _physics_process(delta: float) -> void:
	velocity = Vector2(0, -speed).rotated(dir)
	move_and_slide()
	
