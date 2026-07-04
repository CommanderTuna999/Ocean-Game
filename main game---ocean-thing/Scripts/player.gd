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

@onready var sprint_bar: ProgressBar = get_tree().current_scene.find_child("sprintbar", true, false) as ProgressBar

@export var sprint_multiplier: float = 2.0
@export var sprint_max: float = 100.0
@export var sprint_consumption_per_second: float = 25.0
@export var recharge_per_second: float = 20.0
@export var exhausted_recharge_per_second: float = 10.0
@export var recharge_delay: float = 2.5
@export var sprint_threshold: float = 0.0

var sprint_value: float = sprint_max
var recharge_timer: float = 0.0
var is_sprinting: bool = false
var is_exhausted: bool = false

#test save thin


var timer = 0.0
var timerrunning = true
var spawnposition = Vector2.ZERO

func _ready() -> void:
	$HarpoonLine.visible = false
	$HarpoonLine.width = 1
	if sprint_bar:
		sprint_bar.min_value = 0
		sprint_bar.max_value = sprint_max
		sprint_bar.value = sprint_value
		sprint_bar.show_percentage = false

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
	handle_sprint(delta, direction)
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
	var currentmaxspeed = maxspeed
	var sprint_accel_multiplier = sprint_multiplier
	
	if is_sprinting:
		currentmaxspeed *= sprint_multiplier
		currentaccel *= sprint_accel_multiplier
		
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
		if currentspeed > currentmaxspeed:
			var targetvelocity = velocity.normalized() * currentmaxspeed
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
	update_sprint_bar()
	
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

#sprint stuff below
func handle_sprint(delta: float, direction: Vector2) -> void:
	var wants_to_sprint = Input.is_action_pressed("Shift")
	var is_moving = direction.length() > 0.0

	is_sprinting = false

	if wants_to_sprint and is_moving and not harpooning and can_sprint():
		is_sprinting = true
		recharge_timer = recharge_delay

		sprint_value -= sprint_consumption_per_second * delta
		sprint_value = max(sprint_value, 0.0)

		if sprint_value < sprint_threshold:
			is_exhausted = true
			is_sprinting = false
	else:
		if recharge_timer > 0.0:
			recharge_timer -= delta
		else:
			recharge_sprint(delta)


func can_sprint() -> bool:
	if is_exhausted:
		return false

	if sprint_value <= 0.0:
		return false

	return true


func recharge_sprint(delta: float) -> void:
	if sprint_value >= sprint_max:
		sprint_value = sprint_max
		is_exhausted = false
		return

	var recharge_rate = recharge_per_second

	if is_exhausted:
		recharge_rate = exhausted_recharge_per_second

	sprint_value += recharge_rate * delta
	sprint_value = min(sprint_value, sprint_max)

	if sprint_value >= sprint_max:
		is_exhausted = false


func update_sprint_bar() -> void:
	if sprint_bar:
		sprint_bar.value = sprint_value

func _process(delta):
	health_label.text = str(current_health)
	if current_health <= 0:
		get_tree().call_deferred("reload_current_scene")
		
		
func _on_hurt_area_body_entered(body: Node2D) -> void:
	#print(body)
	damage_occuring = true
	if body.is_in_group("clownfish"):
		velocity.x = 0
		while damage_occuring:
			if body.position.x > position.x:
				velocity.x -= 1000
			elif body.position.x < position.x:
				velocity.x += 1000
			current_health -= clownfish_damage 
			#print("damaged")
			health_label.text = str(current_health) #healthui stuff
			await get_tree().create_timer(iframe_duration).timeout





func _on_hurt_area_body_exited(body: Node2D) -> void:
	damage_occuring = false
