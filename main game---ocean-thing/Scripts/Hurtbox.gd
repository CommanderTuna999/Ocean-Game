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
	
	
	
	
	
	if owner.has_method("take_damage"): #may need to rename function at some point to match actual name of function 
		owner.take_damage(hitbox.damage)
		await get_tree().create_timer(0.1).timeout
