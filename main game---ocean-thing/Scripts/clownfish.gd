#everyone will look at this script eventually so important info:
#Layer 1 = Player
#Layer 2 = Walls
#Layer 3 = HarpoonProjectile
#Layer 4 = Enemies

extends CharacterBody2D
var speed = 300
var aggro = false
var chase_subject = null
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var current_health = 2
	
	
func _process(_delta): #x axis flipping for now
	if not chase_subject == null and chase_subject.position.x > position.x:
		animated_sprite_2d.flip_h = false
	elif not chase_subject == null and chase_subject.position.x < position.x:
		animated_sprite_2d.flip_h = true
	
	
	if current_health <= 0:
		queue_free()
		
		
func _on_aggro_area_body_entered(body):
	chase_subject = body
	aggro = true
	print('entered')
	
	
	
func _on_aggro_area_body_exited(_body: Node2D) -> void:
	chase_subject = null
	aggro = false
	print("exited")



func _physics_process(_delta):
	if aggro and chase_subject:
		velocity = (chase_subject.position - position).normalized() * speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()
	
func take_damage(amount: int):
	current_health -= amount
	animation_player.play("damaged")
	
