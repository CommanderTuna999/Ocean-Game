extends Control

@export var inventory: Node
@export var item_button_scene: PackedScene
@onready var item_grid := $ItemGrid
@onready var equipment_panel := $EquipmentPanel

func _ready() -> void:
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		toggle_inventory()

func toggle_inventory() -> void:
	visible = !visible
	if visible:
		refresh_all()

func refresh_all() -> void:
	refresh_item_grid()
	refresh_equipment_panel()

func refresh_item_grid() -> void:
	for child in item_grid.get_children():
		child.queue_free()

	for i in inventory.items.size():
		var btn = item_button_scene.instantiate()
		item_grid.add_child(btn)
		btn.setup(i, inventory.items[i])
		# no item_selected connection needed — view only, no equip action

func refresh_equipment_panel() -> void:
	for slot_button in equipment_panel.get_children():
		var current_item = inventory.equipped[slot_button.gear_type]
		slot_button.refresh(current_item)
