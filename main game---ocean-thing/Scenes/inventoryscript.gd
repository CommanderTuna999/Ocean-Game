extends Node

const INVENTORY_SIZE = 50
const SET_BONUSES := {
	"attack": {2: [{"stat": "attack_pct", "value": 0.20}]},
	"life": {2: [{"stat": "hp_pct", "value": 0.20}]},
	"defence": {2: [{"stat": "defence_pct", "value": 0.30}]},
	"speed": {2: [{"stat": "speed_pct", "value": 0.125}]},
	"critical rate": {2: [{"stat": "criticalrate_pct", "value": 0.20}]},
	"critical damage": {2: [{"stat": "criticaldamage_pct", "value": 0.25}]},

	"divine speed": {
		4: [
			{"stat": "speed_pct", "value": 0.15},
			{"stat": "shield_pct", "value": 0.15},
		]
	},
	"divine life": {
		2: [
			{"stat": "hp_pct", "value": 0.10},
			{"stat": "shield_pct", "value": 0.10},
		]
	},
	"divine attack": {
		2: [
			{"stat": "attack_pct", "value": 0.10},
			{"stat": "shield_pct", "value": 0.10},
		]
	},
	"bolster": {
		6: [
			{"stat": "hp_pct", "value": 0.20},
			{"stat": "shield_pct", "value": 0.25},
			# heal per second handled separately, see below
		]
	},
}

enum GearType {
	CHESTPLATE,
	WEAPON,
	HELMET,
	BOOTS,
	LEGGINGS,
	SHIELD,
	GAUNTLETS,
	RING,
	BANNER,
	AMULET
}

# Per-slot stat bonus: every item in this slot always grants this,
# regardless of which set it belongs to.
const SLOT_STAT_BONUS := {
	GearType.WEAPON:     {"stat": "attack_pct",        "value": 0.15},
	GearType.HELMET:     {"stat": "hp_pct",             "value": 0.15},
	GearType.SHIELD:     {"stat": "shield_pct",         "value": 0.15},
	GearType.GAUNTLETS:  {"stat": "criticalrate_pct",   "value": 0.20},
	GearType.CHESTPLATE: {"stat": "hp_pct",             "value": 0.20},
	GearType.LEGGINGS:   {"stat": "speed_pct",          "value": 0.10},
	GearType.BOOTS:      {"stat": "speed_pct",          "value": 0.15},
	GearType.RING:       {"stat": "criticaldamage_pct", "value": 0.30},
	GearType.AMULET:     {"stat": "attack_pct",         "value": 0.15},
	GearType.BANNER:     {"stat": "criticaldamage_pct", "value": 0.20},
}

var items: Array = []

var equipped := {
	GearType.CHESTPLATE: null,
	GearType.WEAPON: null,
	GearType.HELMET: null,
	GearType.BOOTS: null,
	GearType.GAUNTLETS: null,
	GearType.RING: null,
	GearType.BANNER: null,
	GearType.AMULET: null,
	GearType.SHIELD: null,
	GearType.LEGGINGS: null, 
}

func add_item(item) -> bool:
	if items.size() >= INVENTORY_SIZE:
		return false

	items.append(item)
	return true

func equip_item(index: int) -> void:
	if index < 0 or index >= items.size():
		return

	var item = items[index]
	var gear_type = item["gear_type"]

	var old_item = equipped[gear_type]
	equipped[gear_type] = item
	items.remove_at(index)

	if old_item != null:
		items.append(old_item)

	recalculate_stats()

func recalculate_stats() -> void:
	var player = get_parent()

	var stat_pct := {
		"attack_pct": 0.0,
		"hp_pct": 0.0,
		"defence_pct": 0.0,
		"speed_pct": 0.0,
		"criticalrate_pct": 0.0,
		"criticaldamage_pct": 0.0,
		"shield_pct": 0.0,
	}

	var set_counts := {}

	for item in equipped.values():
		if item == null:
			continue

		# per-slot stat bonus (fixed by gear_type, same for every set)
		var slot_bonus = SLOT_STAT_BONUS.get(item["gear_type"], null)
		if slot_bonus != null:
			stat_pct[slot_bonus["stat"]] += slot_bonus["value"]

		@warning_ignore("shadowed_variable_base_class")
		var set_name = item.get("set_type", "")
		if set_name != "":
			set_counts[set_name] = set_counts.get(set_name, 0) + 1

	@warning_ignore("shadowed_variable_base_class")
	for set_name in set_counts:
		var pieces = set_counts[set_name]
		var tier_table = SET_BONUSES.get(set_name, {})

		for threshold in tier_table.keys():
			if pieces >= threshold:
				var effects = tier_table[threshold]
				for effect in effects:
					stat_pct[effect["stat"]] += effect["value"]

	player.total_attack_increase = 1.0 + stat_pct["attack_pct"]
	player.total_HP_increase = 1.0 + stat_pct["hp_pct"]
	player.total_defence_increase = 1.0 + stat_pct["defence_pct"]
	player.total_speed_increase = 1.0 + stat_pct["speed_pct"]
	player.total_criticalrate_increase = 1.0 + stat_pct["criticalrate_pct"]
	player.total_criticaldamage_increase = 1.0 + stat_pct["criticaldamage_pct"]
	player.total_shield_increase = 1.0 + stat_pct["shield_pct"]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_E:
		var weapon = {"gear_type": GearType.WEAPON, "set_type": "attack"}
		add_item(weapon)
		equip_item(items.size() - 1)
		print("Attack: ", get_parent().total_attack_increase)
		print("Equipped: ", equipped)
