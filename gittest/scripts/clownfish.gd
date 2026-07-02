extends CharacterBody2D
var speed = 300
var aggro = false
var chase_subject = null
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


	
func _process(_delta):
	if not chase_subject == null and chase_subject.position.x > position.x:
		animated_sprite_2d.flip_h = false
	elif not chase_subject == null and chase_subject.position.x < position.x:
		animated_sprite_2d.flip_h = true
		
		
		
func _on_aggro_area_body_entered(body):
	chase_subject = body
	aggro = true
	print('entered')
	
	
	
func _on_aggro_area_body_exited(_body: Node2D) -> void:
	chase_subject = null
	aggro = false
	print("exited")



func _physics_process(_delta):
	if aggro:
		position = position.move_toward(chase_subject.position, speed * _delta)
		move_and_slide()
	else:
		velocity = Vector2.ZERO

	
		
		
		
		
		
	
