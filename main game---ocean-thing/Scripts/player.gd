#everyone will look at this script eventually so important info:
#Layer 1 = Player
#Layer 2 = Walls
#Layer 3 = HarpoonProjectile
#Layer 4 = Enemy collision
#Layer 5 = Weapon
#Layer 11 = Enemies hurtbox

extends CharacterBody2D
var maxharpoonspeed = 1500
var harpooning = false
var currentharpoon = null
var harpoon_point = Vector2.ZERO
var turnaccel = 1450
var accel = 720
var maxspeed = 500

var normaldragaccel = 720
var harpoondragaccel = 600

#spring tether
var harpoonrestlength = 140
var springstrength = 6
var minimumpullaccel = 650
var maximumpullaccel = 6500
var normalharpoonmaxspeed: float =  1200
var slingshotmaxspeed = 50000
var slingshotstretchthreshold = 250
@export var chargedharpoonspeed: float =  5000
@export var chargeduration: float = 2.0
@export var chargedecay: float = 3.0
var chargetimer: float = 0.0
var ropecharged = false
var wasoverstretched = false
var currentharpoonmaxspeed: float = normalharpoonmaxspeed


var momentumboosttime = 0.0
const JUMP_VELOCITY = -400.0
var harpooonmaxrange = 1000
var wasattachedthisshot = false
var facinglocked = false
var kbtime = 0.0
var kbvelocity = Vector2.ZERO
@export var harpoonprojectilescene: PackedScene
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
#sprint
@onready var sprint_bar: ProgressBar = get_tree().current_scene.find_child("sprintbar", true, false) as ProgressBar
@onready var dash_bar: ProgressBar = get_tree().current_scene.find_child("dashbar", true, false) as ProgressBar

@export var sprint_multiplier: float = 1.45
@export var sprint_max: float = 100.0
@export var sprint_consumption_per_second: float = 25.0
@export var recharge_per_second: float = 20.0
@export var exhausted_recharge_per_second: float = 10.0
@export var recharge_delay: float = 1.85
@export var sprint_threshold: float = 0.0
#dash
@export var dash_max: float = 70.0
@export var dash_cost: float = 25.0
@export var dash_recharge_per_second: float = 12.5
@export var dash_recharge_delay: float = 1.0
@export var dash_speed: float = 1100
@export var dash_duration: float = 0.1
@export var dash_bar_display_value: float = dash_max

var dash_value: float = dash_max
var dash_recharge_timer: float = 0.0
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO

var sprint_value: float = sprint_max
var recharge_timer: float = 0.0
var is_sprinting: bool = false
var is_exhausted: bool = false

#test armour
var armour_DoT: bool = false
var DoT_strength: float = 0.2 + (armour_DoT_level * 0.05)
var armour_DoT_level: float = 0
var can_level_up_N: bool = false

#testing armour levels

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
	if dash_bar:
		dash_bar.min_value = 0
		dash_bar.max_value = dash_max
		dash_bar.value = dash_value
		dash_bar.show_percentage = false
	if health_bar:
		health_bar.min_value = 0
		health_bar.max_value = max_health
		health_bar.value = current_health
		#health_bar.show_percentage = false
	spawnposition = global_position


func _on_harpoon_attached(hitposition):
	wasattachedthisshot = true
	harpooning = true
	harpoon_point = hitposition
	harpoonrestlength = global_position.distance_to(harpoon_point)
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
	
	if kbtime > 0:
		kbtime -= delta
		velocity = kbvelocity
		move_and_slide()
		return
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
	handle_dash(delta, direction)
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
		ropecharged = false
		chargetimer = 0
		wasoverstretched = false
		currentharpoonmaxspeed = normalharpoonmaxspeed
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
	#if not is_dashing:
		#if direction:
			#if velocity.length() == 0 or direction.dot(velocity) > 0:
				#velocity += direction * currentaccel
		#else: 
			#velocity += direction * turnaccel
	#else:
		#velocity = velocity.move_toward(Vector2.ZERO, currentaccel)
#
	#move_and_slide()
	var currentaccel = accel

	#sprite flipping stuff below
	if direction.x > 0: 
		faceside("right")
	elif direction.x < 0:
		faceside("left")
	#sprite flipping ends here, please depart from the train. Functions await below

	
	if harpooning:
		currentaccel = 1200
	var currentmaxspeed = maxspeed
	var sprint_accel_multiplier = sprint_multiplier
	
	if is_sprinting:
		currentmaxspeed *= sprint_multiplier
		currentaccel *= sprint_accel_multiplier
		
	if direction:
		if velocity.length() == 0 or direction.dot(velocity) > 0:
			velocity += direction * currentaccel * delta
		else: 
			velocity += direction * turnaccel * delta
			
		#if not harpooning and momentumboosttime <= 0:
			#velocity = velocity.limit_length(maxspeed)
	
			
	else:
		var currentdragaccel = normaldragaccel
		
		if harpooning:
			currentdragaccel = harpoondragaccel
			
		velocity = velocity.move_toward(
			Vector2.ZERO,
			currentdragaccel * delta
		)
		
	if not harpooning and not is_dashing:
		var currentspeed = velocity.length()
		if currentspeed > currentmaxspeed:
			var targetvelocity = velocity.normalized() * currentmaxspeed
			velocity = velocity.move_toward(
				targetvelocity, 
				1980 * delta
			)
		
	if harpooning:
		var direction_to_point = (harpoon_point - global_position).normalized()
		var distancetopoint = global_position.distance_to(harpoon_point)
		var stretch = max(distancetopoint - harpoonrestlength, 0)
		
		var currentpullaccel = clamp(minimumpullaccel + stretch * springstrength, minimumpullaccel, maximumpullaccel)
		
		velocity += (direction_to_point * currentpullaccel * delta)

		
		var overstretched = stretch >= slingshotstretchthreshold
		if overstretched and not wasoverstretched:
			ropecharged = true
			chargetimer = chargeduration
			currentharpoonmaxspeed = chargedharpoonspeed
			wasoverstretched = overstretched
		if ropecharged:
			if chargetimer > 0.0:
				chargetimer -= delta
				currentharpoonmaxspeed = chargedharpoonspeed
			else:
				currentharpoonmaxspeed = lerp(
					currentharpoonmaxspeed,
					normalharpoonmaxspeed,
					min(chargedecay * delta, 1.0)
				)
			
			if abs(currentharpoonmaxspeed - normalharpoonmaxspeed) < 1:
				currentharpoonmaxspeed = normalharpoonmaxspeed
				ropecharged = false
		else:
			currentharpoonmaxspeed = normalharpoonmaxspeed
			
		velocity = velocity.limit_length(currentharpoonmaxspeed)
		
		$HarpoonLine.points = [
			Vector2.ZERO,
			to_local(harpoon_point)
		]
	var crashed = false
	
	if Input.is_action_just_pressed("Restart"):
		get_tree().call_deferred("reload_current_scene")
	
	move_and_slide()
	update_sprint_bar()
	update_dash_bar(delta)
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var normal = collision.get_normal()
		
		if velocity.dot(-normal) > 300:
			crashed = true
	if crashed:
		velocity *= 0.7

func faceside(side):
	if facinglocked:
		return
	if side == "right":
		animated_sprite_2d.flip_h = false
		$Spear.setrestside("right")
	elif side == "left":
		animated_sprite_2d.flip_h = true
		$Spear.setrestside("left")
	
func forcefaceside(side):
	if side == "right":
		animated_sprite_2d.flip_h = false
		$Spear.setrestside("right")
	elif side == "left":
		animated_sprite_2d.flip_h = true
		$Spear.setrestside("left")
		
func handle_dash(delta: float, direction: Vector2) -> void:
	if is_dashing:
		dash_timer -= delta
		velocity = dash_direction * dash_speed

		if dash_timer <= 0.0:
			is_dashing = false

		return

	if Input.is_action_just_pressed("Dash") and dash_value >= dash_cost:
		start_dash(direction)

	if dash_recharge_timer > 0.0:
		dash_recharge_timer -= delta
	else:
		recharge_dash(delta)


func start_dash(direction: Vector2) -> void:
	if direction.length() > 0.0:
		dash_direction = direction.normalized()
	else:
		dash_direction = (get_global_mouse_position() - global_position).normalized()

	if dash_direction == Vector2.ZERO:
		return

	is_dashing = true
	dash_timer = dash_duration

	dash_value -= dash_cost
	dash_value = max(dash_value, 0.0)

	dash_recharge_timer = dash_recharge_delay
	velocity = dash_direction * dash_speed


func recharge_dash(delta: float) -> void:
	if dash_value >= dash_max:
		dash_value = dash_max
		return

	dash_value += dash_recharge_per_second * delta
	dash_value = min(dash_value, dash_max)


func update_dash_bar(delta: float) -> void:
	if dash_bar:
		dash_bar_display_value = move_toward(
			dash_bar_display_value,
			dash_value,
			60.0 * delta
		)

		dash_bar.value = dash_bar_display_value

#actual health stuff below
@onready var health_label: Label = $"../UI/CanvasLayer/health_label"
@onready var health_bar: TextureProgressBar = get_tree().current_scene.find_child("HealthBeams", true, false) as TextureProgressBar
@onready var healthanim = get_tree().current_scene.find_child("HealthAnimationPlayer", true, false)
@onready var hitparticlesA: GPUParticles2D = get_tree().current_scene.find_child("HitParticlesA", true, false)
@onready var hitparticlesB: GPUParticles2D = get_tree().current_scene.find_child("HitParticlesB", true, false)
@onready var emptybeams = get_tree().current_scene.find_child("EmptyBeams", true, false)
var invincible = false
var regen_delay = 1
var regen_per_second = 0
var time_since_damage = 0.0
var displayed_health = 100
var max_health = 100
var current_health = 100
var damage_occuring = false
var iframe_duration = 0.9
var starsaveused = false
var clownfish_damage = 5
var shark_damage = 25

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
	handle_health_regen(delta)
	update_health_ui(delta)
	
	#armour testing level thing
	if Input.is_action_just_pressed("armour_level_test"):
		can_level_up_N = false
		armour_DoT_level += 1
		DoT_strength += (armour_DoT_level * 0.05)
		get_tree().current_scene.get_node("UI/CanvasLayer/LevelUpLabel").show_level_up(armour_DoT_level)
		
		await get_tree().create_timer(0.5).timeout
		can_level_up_N = true
		
	if current_health <= 0:
		get_tree().call_deferred("reload_current_scene")
		
func handle_health_regen(delta: float) -> void:
	if current_health >= max_health:
		current_health = max_health
		return

	time_since_damage += delta

	if time_since_damage >= regen_delay:
		current_health += regen_per_second * delta
		current_health = min(current_health, max_health)

func update_health_ui(delta: float) -> void:
	displayed_health = current_health
	var healthpercent = float(displayed_health) / float(max_health)
	var visual = 100
	#if displayed_health > current_health:
	if current_health <= 0:
		visual = 0
	elif starsaveused and current_health == 1:
		visual = 21
	else:
		visual = 25 + healthpercent * 75
	#else:
		##displayed_health = move_toward(
			##displayed_health,
			##current_health,
			##regen_per_second * delta
		##)
	if health_label:
		health_label.text = str(roundi(displayed_health))

	if health_bar:
		health_bar.value = visual


func take_player_damage(amount: float) -> void:
	if invincible:
		return
	if current_health - amount <= 0 and not starsaveused and current_health > 1:
		current_health = 1
		starsaveused = true
		emptybeams.visible = false
	else:
		current_health -= amount
		current_health = max(current_health, 0)
	if healthanim:
		healthanim.stop()
		healthanim.play("damageflash")
	var healthpercent = float(current_health) / float(max_health)
	var startpos = health_bar.global_position
	var visualwidth = health_bar.size.x * health_bar.scale.x
	var visualheight = health_bar.size.y * health_bar.scale.y

	var beamstartx = startpos.x + visualwidth * 0.21
	var beamwidth = visualwidth * 0.79

	var beampercent = float(current_health) / float(max_health)

	var endx = beamstartx + beamwidth * beampercent
	var midy = startpos.y + visualheight / 2
	var distance_from_end = 1.0 - healthpercent
	var straight_part = 0.1
	var edgefade = clamp((distance_from_end - straight_part) * 100, 0.0, 1.0)
	var wave = sin(healthpercent * TAU * 3.5) * 18 * edgefade
	hitparticlesA.global_position = Vector2(endx, midy + wave)
	hitparticlesB.global_position = Vector2(endx, midy - wave)
	hitparticlesA.restart()
	hitparticlesB.restart()
	time_since_damage = 0.0
	invincible = true
	set_collision_mask_value(4, false)
	await get_tree().create_timer(iframe_duration).timeout
	set_collision_mask_value(4, true)
	invincible = false
	for body in $hurt_area.get_overlapping_bodies():
		if is_instance_valid(body):
			handleenemycontact(body)
			break
func _on_hurt_area_body_entered(body: Node2D) -> void:
	handleenemycontact(body)
		
	#if armour_DoT == false:
		#take_player_damage(damage)
		#await get_tree().create_timer(iframe_duration).timeout
	#else:
		#var maxdamage = damage
		#while damage >= maxdamage * DoT_strength:
			#take_player_damage(damage * DoT_strength)
			#damage -= damage * DoT_strength 
			#await get_tree().create_timer(DoT_strength * 4.0).timeout
func _on_hurt_area_body_exited(body: Node2D) -> void:
	damage_occuring = false
func activate():
	armour_DoT = true

func handleenemycontact(body: Node2D):
	if not is_instance_valid(body):
		return
	if invincible:
		return
		
	var damage = 0
	var kbstrength = 0

	
	#clownfish
	if body.is_in_group("clownfish"):
		damage = clownfish_damage
		kbstrength = 500
	elif body.is_in_group("shark"):
		damage = shark_damage
		kbstrength = 2000
	
	else:
		return
	
	damage_occuring = true
	
	var kbdirection = (global_position - body.global_position)

	if kbdirection.length() < 1:
		kbdirection = -velocity.normalized()

	if kbdirection == Vector2.ZERO:
		kbdirection = Vector2(1, 0)

	kbdirection = kbdirection.normalized()
	kbvelocity = kbdirection * kbstrength
	kbtime = 0.12
	take_player_damage(damage)
