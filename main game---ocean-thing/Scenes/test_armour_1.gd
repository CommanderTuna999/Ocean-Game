extends Area2D

@export var target_node: Node

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		target_node.activate()
		queue_free()
