extends CharacterBody2D
var speed = 500
var current_health = 5
@onready var clownfish: Node = $"../clownfish"




var iframe_duration = 0.01
var clownfish_damage = 1

func _process(delta):
	velocity.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	velocity.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	move_and_slide() #no clue what this is but after some research it fixed collisions somehow
	if current_health <= 0:
		get_tree().call_deferred("reload_current_scene")
	velocity = velocity.normalized()

	global_position += speed * velocity * delta
	

func _on_hurt_area_body_entered(body):
	print(body)
	if body.is_in_group("clownfish"):
		if body.position.x > position.x: 
			position.x -= 100
		elif body.position.x < position.x:
			position.x += 100
		current_health -= clownfish_damage 
		print("damaged")
	await get_tree().create_timer(iframe_duration).timeout


	
