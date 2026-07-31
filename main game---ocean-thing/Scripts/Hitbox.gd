class_name TemplateHitbox
extends Area2D
@export var base_damage = 100

var damage:
	get:
		var player = get_tree().current_scene.find_child("Player", true, false)
		if player == null:
			return base_damage
		return base_damage * player.total_attack_increase

func _init() -> void:
	collision_layer = 1024 #11
	collision_mask = 2
