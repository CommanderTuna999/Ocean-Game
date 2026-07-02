extends CanvasLayer

@onready var sprint_bar = $HBoxContainer/VBoxContainer/SprintBar
@onready var sprint_label = $HBoxContainer/VBoxContainer/SprintLabelVBoxContainer/SprintLabel

func _ready():
	# Style the bar
	sprint_bar.min_value = 0
	sprint_bar.max_value = 100
	sprint_bar.value = 100
	sprint_bar.custom_minimum_size = Vector2(200, 20)
	sprint_label.text = "SPRINT"

func update_sprint(value: float, exhausted: bool):
	sprint_bar.value = value

	# Change bar colour based on state
	var style = StyleBoxFlat.new()
	style.bg_color = Color.RED if exhausted else (Color.YELLOW if value < 20 else Color.CYAN)
	sprint_bar.add_theme_stylebox_override("fill", style)
