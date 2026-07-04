extends AnimationPlayer

@onready var animation_player: AnimationPlayer = $"."
@onready var weapon: Node2D = $".."

var direction = "right"


func _ready() -> void:
	update_direction_from_mouse(true)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("left_click"):
		update_direction_from_mouse(false)

		if direction == "right":
			animation_player.play("slash_right")
		else:
			animation_player.play("slash_left")

		return

	if not is_attacking():
		update_direction_from_mouse(true)


func update_direction_from_mouse(play_reset_animation: bool) -> void:
	var mouse_position = weapon.get_global_mouse_position()

	if mouse_position.x >= weapon.global_position.x:
		direction = "right"
		weapon.scale.x = abs(weapon.scale.x)

		if play_reset_animation:
			animation_player.play("RESET_right")
	else:
		direction = "left"
		weapon.scale.x = -abs(weapon.scale.x)

		if play_reset_animation:
			animation_player.play("RESET_left")


func is_attacking() -> bool:
	return animation_player.is_playing() and (
		animation_player.current_animation == "slash_right"
		or animation_player.current_animation == "slash_left"
	)


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "slash_right" or anim_name == "slash_left":
		update_direction_from_mouse(true)
