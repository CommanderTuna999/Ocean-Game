extends CharacterBody2D
var maxharpoonspeed = 1100
var harpooning = false
var currentharpoon = null
var harpoon_point = Vector2.ZERO
var harpoon_pull_accel = 100
var turnaccel = 35
var drag = 10
var accel = 12
var maxspeed = 500
var momentumboosttime = 0.0
var currentaccel = accel
const JUMP_VELOCITY = -400.0
var harpooonmaxrange = 1000
var wasattachedthisshot = false
@export var harpoonprojectilescene: PackedScene
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D




var timer = 0.0
var timerrunning = true
var spawnposition = Vector2.ZERO

func _ready() -> void:
	$HarpoonLine.visible = false
	$HarpoonLine.width = 1
	

	spawnposition = global_position

func _on_harpoon_attached(hitposition):
	wasattachedthisshot = true
	harpooning = true
	harpoon_point = hitposition
	$HarpoonLine.points = [
	Vector2.ZERO,
	to_local(harpoon_point)
		]
	$HarpoonLine.visible = true
	currentharpoon = null
	
func _physics_process(delta: float) -> void:
	
	if timerrunning:
		timer += delta
	get_parent().get_node("TimerLabel").text = "%.2f" % timer
	
	var mouse_pos = get_global_mouse_position()
	var direction_to_mouse = (mouse_pos - global_position).normalized()
	$HarpoonRaycast.target_position = direction_to_mouse * 500
	

	#if momentumboosttime  > 0:
		#momentumboosttime -= delta
		
	if currentharpoon != null:
		var ropelength = global_position.distance_to(currentharpoon.global_position)
		if ropelength > harpooonmaxrange:
			currentharpoon.queue_free()
			currentharpoon = null
			harpooning = false
			$HarpoonLine.visible = false
		else:
				$HarpoonLine.visible = true
				$HarpoonLine.points = [
				Vector2.ZERO,
				to_local(currentharpoon.global_position)
			]
	elif harpooning:
		$HarpoonLine.visible = true
		$HarpoonLine.points = [
		Vector2.ZERO,
		to_local(harpoon_point)
		]
	else:
		$HarpoonLine.visible = false

	var direction = Input.get_vector("Left", "Right", "Up", "Down")
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	#if Input.is_action_just_pressed("Jump") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	if Input.is_action_just_pressed("Harpoon"):
		wasattachedthisshot = false
		var harpoon = harpoonprojectilescene.instantiate()
		harpoon.global_position = global_position
		harpoon.direction = direction_to_mouse
		harpoon.attached.connect(_on_harpoon_attached)
		get_parent().add_child(harpoon)
		currentharpoon = harpoon
	if Input.is_action_just_released("Harpoon"):
		harpooning = false
		$HarpoonLine.visible = false
		if wasattachedthisshot == true:
			#momentumboosttime = 0.1
			wasattachedthisshot = false

		if currentharpoon != null:
			currentharpoon.queue_free()
			currentharpoon = null
		#if $HarpoonRaycast.is_colliding():
			#harpooning = true
			#harpoon_point = $HarpoonRaycast.get_collision_point()
			#$HarpoonLine.visible = true
#
	#if Input.is_action_just_released("Harpoon"):
		#harpooning = false
		#$HarpoonLine.visible = false

	#workingscript  if harpooning:
		#var direction_to_point = (harpoon_point - global_position).normalized()
		#velocity += direction_to_point * harpoon_pull_accel
		#velocity = velocity.limit_length(maxharpoonspeed)
#
		#$HarpoonLine.points = [
			#Vector2.ZERO,
			#to_local(harpoon_point)
		#]
	#else:
		#if direction:
			#if velocity.length() == 0 or direction.dot(velocity) > 0:
				#velocity += direction * accel
			#else: 
				#velocity += direction * turnaccel
				#
			#velocity = velocity.limit_length(maxspeed)
			
		#else:
			#velocity = velocity.move_toward(Vector2.ZERO, accel)
#
	#move_and_slide()
	var currentaccel = accel
	#sprite flipping stuff below
	if direction.x > 0: 
		animated_sprite_2d.flip_h = false
	elif direction.x < 0:
		animated_sprite_2d.flip_h = true
	#sprite flipping ends here, please depart from the train

	
	if harpooning:
		currentaccel = 75
			
	if direction:
		if velocity.length() == 0 or direction.dot(velocity) > 0:
			velocity += direction * currentaccel
		else: 
			velocity += direction * turnaccel
			
		#if not harpooning and momentumboosttime <= 0:
			#velocity = velocity.limit_length(maxspeed)
	
			
	else:
		velocity = velocity.move_toward(Vector2.ZERO, currentaccel)
		
	if not harpooning:
		var currentspeed = velocity.length()
		if currentspeed > maxspeed:
			var targetvelocity = velocity.normalized() * maxspeed
			velocity = velocity.move_toward(targetvelocity, 20)
		
	if harpooning:
		var direction_to_point = (harpoon_point - global_position).normalized()
		var distancetopoint = global_position.distance_to(harpoon_point)
		
		if distancetopoint > 100:
			velocity += direction_to_point * harpoon_pull_accel
		else:
			velocity += direction_to_point * 20
		velocity = velocity.limit_length(maxharpoonspeed)
		$HarpoonLine.points = [
			Vector2.ZERO,
			to_local(harpoon_point)
		]

	var crashed = false
	
	if Input.is_action_just_pressed("Restart"):
		get_tree().call_deferred("reload_current_scene")
	
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var normal = collision.get_normal()
		
		if velocity.dot(-normal) > 300:
			crashed = true
	if crashed:
		velocity *= 0.7


#actual health stuff below
@onready var health_label: Label = $"../UI/CanvasLayer/health_label"
var current_health = 500
var damage_occuring = false
var iframe_duration = 0.2
var clownfish_damage = 1


func _process(delta):
	health_label.text = str(current_health)
	if current_health <= 0:
		get_tree().call_deferred("reload_current_scene")
		
		
func _on_hurt_area_body_entered(body: Node2D) -> void:
	print(body)
	damage_occuring = true
	if body.is_in_group("clownfish"):
		velocity.x = 0
		while damage_occuring:
			if body.position.x > position.x:
				velocity.x -= 1000
			elif body.position.x < position.x:
				velocity.x += 1000
			current_health -= clownfish_damage 
			print("damaged")
			health_label.text = str(current_health) #healthui stuff
			await get_tree().create_timer(iframe_duration).timeout





func _on_hurt_area_body_exited(body: Node2D) -> void:
	damage_occuring = false
