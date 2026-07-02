extends AnimationPlayer
@onready var animation_player: AnimationPlayer = $"."

func _process(delta):
	if Input.is_action_just_pressed("right_click"):
		animation_player.play("slash")
