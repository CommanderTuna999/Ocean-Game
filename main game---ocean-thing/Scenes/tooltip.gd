extends CanvasLayer

@onready var panel := $TooltipPanel
@onready var label := $TooltipPanel/TooltipLabel

func show_for_item(item_data: Dictionary, pos: Vector2) -> void:
	var inv = get_node("/root/Game/Player/Inventory")  # adjust path
	var slot_bonus = inv.SLOT_STAT_BONUS.get(item_data["gear_type"], null)

	var text := ""
	if slot_bonus != null:
		text += "%s: +%d%%\n" % [slot_bonus["stat"], slot_bonus["value"] * 100]

	var set_name = item_data.get("set_type", "")
	if set_name != "":
		text += "\nSet: %s" % set_name.capitalize()

	label.text = text
	panel.global_position = pos
	panel.visible = true

func hide_tooltip() -> void:
	panel.visible = false
