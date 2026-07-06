extends Node2D

var direction = "right"
var attacking:= false
var mouse_pos := Vector2.ZERO
var direction_to_mouse := Vector2.ZERO
const winduptime = 0.1
const attacktime := 0.1
const attackcooldown := 0.25
const spearoffset := 15
func _ready() -> void:
	$TemplateHitbox/CollisionShape2D.disabled = true
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("left_click") and not attacking:
		mouse_pos = get_global_mouse_position()
		direction_to_mouse = (mouse_pos - global_position).normalized()
		if abs(direction_to_mouse.x) > abs(direction_to_mouse.y):
			if direction_to_mouse.x >= 0:
				direction = "right"
			else:
				direction = "left"
		else:
			if direction_to_mouse.y >= 0:
				direction = "down"
			else:
				direction = "up"
		attack()
		

func attack():
	attacking = true
	match direction:
		"right":
			$TemplateHitbox/CollisionShape2D.position = Vector2(spearoffset, 0)
			$TemplateHitbox/CollisionShape2D.rotation = deg_to_rad(0)
		"left":
			$TemplateHitbox/CollisionShape2D.position = Vector2(-spearoffset, 0)
			$TemplateHitbox/CollisionShape2D.rotation = deg_to_rad(0)
		"up":
			$TemplateHitbox/CollisionShape2D.position = Vector2(0,-spearoffset)
			$TemplateHitbox/CollisionShape2D.rotation = deg_to_rad(90)
		"down":
			$TemplateHitbox/CollisionShape2D.position = Vector2(0, spearoffset)
			$TemplateHitbox/CollisionShape2D.rotation = deg_to_rad(-90)
	await get_tree().create_timer(winduptime).timeout
	$TemplateHitbox/CollisionShape2D.disabled = false
	await get_tree().create_timer(attacktime).timeout
	$TemplateHitbox/CollisionShape2D.disabled = true
	await get_tree().create_timer(attackcooldown).timeout
	attacking = false
	
