class_name TemplateHurtbox
extends Area2D



func _init() -> void:
	collision_layer = 0
	collision_mask = 1024 #11


func _ready() -> void:
	connect("area_entered", self._on_area_entered) #some sort of signal script



func _on_area_entered(hitbox: TemplateHitbox) -> void:
	if hitbox == null:
		return #goes back to start if the hitbox is not detected
	
	
	
	
	
	if owner.has_method("take_damage"):
		owner.take_damage(hitbox.damage)

	if owner.has_method("take_kb"):
		owner.take_kb(hitbox.global_position)
