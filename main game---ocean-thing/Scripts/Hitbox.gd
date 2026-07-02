class_name TemplateHitbox
extends Area2D
@export var damage = 1



func _init() -> void:
	collision_layer = 1024 #11
	collision_mask = 0
