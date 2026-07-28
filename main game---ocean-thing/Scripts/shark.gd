#everyone will look at this script eventually so important info:
#Layer 1 = Player
#Layer 2 = Walls
#Layer 3 = HarpoonProjectile
#Layer 11 = Enemies hurtbox
#add a sound effect before dash
extends CharacterBody2D
@export var chasespeed = 180
@export var chargespeed = 900
@export var warningtime = 1
@export var chargetime = 0.7
@export var cooldowntime = 1
var damage_occuring = false
var chase_subject = null
var aggro = false
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


@onready var dash_indicator: Sprite2D = $dash_indicator

var charging = false
var preparingcharge = false
var chargedirection = Vector2.ZERO
var kbtime = 0.0
var kbvelocity = Vector2.ZERO
var current_health = 10
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	dash_indicator.self_modulate.a = 0

func _physics_process(_delta): #x axis flipping for now
	if current_health <= 0:
		queue_free()
		return
		
	if kbtime > 0:
		kbtime 	-= _delta
		velocity = kbvelocity
		move_and_slide()
		return
		
	if charging:
		velocity = chargedirection * chargespeed
		dash_indicator.self_modulate.a = 0
	elif aggro and chase_subject != null and not preparingcharge:
		var direction = (chase_subject.global_position - global_position).normalized()
		velocity = direction * chasespeed
		
		if direction.x > 0:
			animated_sprite_2d.flip_h = false
		elif direction.x < 0:
			animated_sprite_2d.flip_h = true
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()

		
func _on_aggro_area_body_entered(body):
	chase_subject = body
	aggro = true
	startchargecycle()
	

		
func _on_aggro_area_body_exited(body):
	if body == chase_subject:
		chase_subject = null
		aggro = false
	
func startchargecycle():
	if preparingcharge or charging:
		return
	while aggro and chase_subject != null:
		preparingcharge = true
		dash_indicator.self_modulate.a = 0.3
		dash_indicator.look_at(chase_subject.position)
		velocity = Vector2.ZERO
		await get_tree().create_timer(0.5).timeout
		
		if chase_subject == null:
			preparingcharge = false
			return
		
		chargedirection = (chase_subject.global_position - global_position).normalized()
		preparingcharge = false
		charging = true
		
		await get_tree().create_timer(1).timeout
		
		charging = false
		velocity = Vector2.ZERO
		
		await get_tree().create_timer(1).timeout
	
	
#damage script below
func take_damage(amount: int):
	current_health -= amount
	animation_player.play("damaged")
	await get_tree().create_timer(0.1).timeout

	

# knockback script below
func _on_template_hurtbox_area_entered(area: Area2D) -> void:
	var kbdirection = (global_position - area.global_position).normalized()
	kbvelocity = kbdirection * 700
	kbtime = 0.12



func _process(delta: float) -> void:
	dash_indicator.position = animated_sprite_2d.position
