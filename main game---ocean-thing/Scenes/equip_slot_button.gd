extends TextureButton  # could also be TextureRect now, no click needed

@export var gear_type: Inventory.GearType

func refresh(item_data) -> void:
	if item_data == null:
		pass  # show empty slot placeholder
	else:
		pass  # texture = load(item_data.get("icon", "res://icons/default.png"))
