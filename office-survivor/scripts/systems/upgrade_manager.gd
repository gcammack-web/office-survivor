extends Node

const UPGRADES: Array[Dictionary] = [
	{
		"id": "stapler",
		"title": "Stapler",
		"description": "Fires staples at the nearest coworker... I mean, threat.",
		"category": "weapon",
		"weapon_id": "stapler",
		"max_level": 5,
		"weight": 1.0,
	},
	{
		"id": "coffee",
		"title": "Coffee Mug",
		"description": "Hot coffee aura burns nearby deadlines. Caffeinated damage.",
		"category": "weapon",
		"weapon_id": "coffee",
		"max_level": 5,
		"weight": 1.0,
	},
	{
		"id": "email",
		"title": "Passive-Aggressive Email",
		"description": "Homing emails that say 'Per my last message...' on impact.",
		"category": "weapon",
		"weapon_id": "email",
		"max_level": 5,
		"weight": 1.0,
	},
	{
		"id": "printer_jam",
		"title": "Printer Jam",
		"description": "Office-wide freeze + paper explosion. Everything on screen takes damage.",
		"category": "weapon",
		"weapon_id": "printer_jam",
		"max_level": 3,
		"weight": 0.75,
	},
	{
		"id": "extra_coffee",
		"title": "Another Cup of Coffee",
		"description": "+10% move speed. Sleep is for the unemployed.",
		"category": "passive",
		"weapon_id": "",
		"max_level": 5,
		"weight": 1.2,
	},
	{
		"id": "ergonomic_chair",
		"title": "Ergonomic Chair",
		"description": "+15 max HP. HR finally approved your request.",
		"category": "passive",
		"weapon_id": "",
		"max_level": 5,
		"weight": 1.0,
	},
	{
		"id": "reply_all",
		"title": "Reply All",
		"description": "+15% damage on all weapons. Everyone suffers now.",
		"category": "passive",
		"weapon_id": "",
		"max_level": 5,
		"weight": 0.9,
	},
	{
		"id": "office_magnet",
		"title": "Office Magnet",
		"description": "+20% XP magnet radius per level. Paperclips find you.",
		"category": "passive",
		"weapon_id": "office_magnet",
		"max_level": 5,
		"weight": 1.35,
	},
]

var upgrade_levels: Dictionary = {}

func _ready() -> void:
	reset()

func reset() -> void:
	upgrade_levels.clear()
	for upgrade in UPGRADES:
		upgrade_levels[upgrade.id] = 0

func get_level(upgrade_id: String) -> int:
	return upgrade_levels.get(upgrade_id, 0)

func can_offer(upgrade_id: String) -> bool:
	var def := _find(upgrade_id)
	if def.is_empty():
		return false
	return get_level(upgrade_id) < int(def.max_level)

func apply_upgrade(upgrade_id: String) -> Dictionary:
	var def := _find(upgrade_id)
	if def.is_empty() or not can_offer(upgrade_id):
		return {}
	upgrade_levels[upgrade_id] = get_level(upgrade_id) + 1
	return def

func roll_choices(count: int = 3) -> Array[Dictionary]:
	var pool: Array[Dictionary] = []
	for upgrade in UPGRADES:
		if can_offer(upgrade.id):
			pool.append(upgrade.duplicate())

	pool.shuffle()
	var choices: Array[Dictionary] = []
	for upgrade in pool:
		if choices.size() >= count:
			break
		choices.append(upgrade)
	return choices

func get_display_title(upgrade: Dictionary) -> String:
	var level := get_level(upgrade.id)
	if level == 0:
		return upgrade.title
	return "%s (Lv %d → %d)" % [upgrade.title, level, level + 1]

func _find(upgrade_id: String) -> Dictionary:
	for upgrade in UPGRADES:
		if upgrade.id == upgrade_id:
			return upgrade
	return {}

func get_damage_multiplier() -> float:
	return 1.0 + get_level("reply_all") * 0.15

func get_speed_multiplier() -> float:
	return 1.0 + get_level("extra_coffee") * 0.10

func get_bonus_max_hp() -> int:
	return get_level("ergonomic_chair") * 15

func get_magnet_radius_multiplier() -> float:
	return 1.0 + get_level("office_magnet") * 0.20

func get_collect_radius_bonus() -> float:
	return get_level("office_magnet") * 4.0
