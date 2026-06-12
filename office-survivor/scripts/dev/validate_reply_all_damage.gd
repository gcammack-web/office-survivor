extends Node

const UpgradeManagerScript = preload("res://scripts/systems/upgrade_manager.gd")
const PlayerStubScript = preload("res://scripts/dev/reply_all_test_player.gd")
const WEAPON_SCRIPTS := {
	"stapler": preload("res://scripts/weapons/stapler_weapon.gd"),
	"email": preload("res://scripts/weapons/email_weapon.gd"),
	"printer_jam": preload("res://scripts/weapons/printer_jam_weapon.gd"),
	"coffee": preload("res://scripts/weapons/coffee_weapon.gd"),
}

## Headless check: Reply All multiplier must reach every weapon damage path (incl. coffee aura).
func _ready() -> void:
	var upgrade_manager := Node.new()
	upgrade_manager.name = "UpgradeManager"
	upgrade_manager.set_script(UpgradeManagerScript)
	add_child(upgrade_manager)

	var player := Node2D.new()
	player.name = "Player"
	player.add_to_group("player")
	player.set_script(PlayerStubScript)
	add_child(player)
	player.upgrade_manager = upgrade_manager

	var weapon_manager := Node2D.new()
	weapon_manager.name = "WeaponManager"
	player.add_child(weapon_manager)

	var failed := false
	for weapon_id in WEAPON_SCRIPTS:
		var weapon := Node2D.new()
		weapon.set_script(WEAPON_SCRIPTS[weapon_id])
		weapon_manager.add_child(weapon)

		var base_damage: int = weapon.call("_get_damage")
		upgrade_manager.apply_upgrade("reply_all")
		var boosted_damage: int = weapon.call("_get_damage")
		var expected := int(round(float(base_damage) * upgrade_manager.get_damage_multiplier()))

		if boosted_damage != expected or boosted_damage <= base_damage:
			push_error(
				"validate_reply_all_damage: '%s' base=%d boosted=%d expected=%d"
				% [weapon_id, base_damage, boosted_damage, expected]
			)
			failed = true

		upgrade_manager.reset()
		weapon.free()

	if failed:
		get_tree().quit(1)
		return

	print("validate_reply_all_damage: OK — Reply All applies to all %d weapons" % WEAPON_SCRIPTS.size())
	get_tree().quit(0)
