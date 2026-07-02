extends AnimationPlayer
@onready var animation_player: AnimationPlayer = $"."
@onready var sprite_2d: Sprite2D = $"../Sprite2D"
@onready var weapon: Node2D = $".."

func _process(delta):
	if Input.is_action_just_pressed("right_click"):
		animation_player.play("slash")
