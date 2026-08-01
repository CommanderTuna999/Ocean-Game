extends TextureButton

signal item_selected(index: int)

var item_index: int
var item_data: Dictionary

func setup(index: int, data: Dictionary) -> void:
	item_index = index
	item_data = data
	# texture = load(data.get("icon", "res://icons/default.png"))

func _on_pressed() -> void:
	item_selected.emit(item_index)

func _on_mouse_entered() -> void:
	Tooltip.show_for_item(item_data, global_position)

func _on_mouse_exited() -> void:
	Tooltip.hide_tooltip()
