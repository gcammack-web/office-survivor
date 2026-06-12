extends Node2D
class_name WeaponManager

const WEAPON_SCENES := {
	"stapler": preload("res://scenes/weapons/stapler_weapon.tscn"),
	"coffee": preload("res://scenes/weapons/coffee_weapon.tscn"),
	"email": preload("res://scenes/weapons/email_weapon.tscn"),
	"printer_jam": preload("res://scenes/weapons/printer_jam_weapon.tscn"),
}

const WEAPON_DISPLAY_NAMES := {
	"stapler": "Stapler",
	"coffee": "Coffee Mug",
	"email": "Passive-Aggressive Email",
	"printer_jam": "Printer Jam",
}

var weapons: Dictionary = {}

func _ready() -> void:
	GameEvents.upgrade_chosen.connect(_on_upgrade_chosen)

func reset() -> void:
	for weapon in weapons.values():
		if is_instance_valid(weapon):
			weapon.queue_free()
	weapons.clear()

func grant_weapon(weapon_id: String) -> void:
	if weapons.has(weapon_id):
		var weapon: Node = weapons[weapon_id]
		if weapon.has_method("level_up"):
			weapon.level_up()
		return
	if not WEAPON_SCENES.has(weapon_id):
		return
	var weapon_scene: PackedScene = WEAPON_SCENES[weapon_id]
	var weapon_instance := weapon_scene.instantiate()
	add_child(weapon_instance)
	weapons[weapon_id] = weapon_instance

func get_best_weapon_summary() -> String:
	var best_id := "stapler"
	var best_level := 0
	for weapon_id in weapons:
		var weapon: Node = weapons[weapon_id]
		if not is_instance_valid(weapon):
			continue
		var weapon_level := int(weapon.level) if "level" in weapon else 1
		if weapon_level > best_level:
			best_level = weapon_level
			best_id = str(weapon_id)
	var best_name: String = WEAPON_DISPLAY_NAMES.get(best_id, best_id.capitalize())
	if best_level <= 0:
		return best_name
	return "%s Lv %d" % [best_name, best_level]


func _on_upgrade_chosen(upgrade_id: String) -> void:
	var upgrade_manager := get_node_or_null("/root/Main/UpgradeManager")
	if not upgrade_manager:
		return
	var def: Dictionary = upgrade_manager.apply_upgrade(upgrade_id)
	if def.is_empty():
		return
	if def.category == "weapon":
		grant_weapon(def.weapon_id)
	elif def.category == "passive":
		var player := get_parent()
		if player and player.has_method("apply_passive_upgrades"):
			player.apply_passive_upgrades()
