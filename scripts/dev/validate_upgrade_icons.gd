extends SceneTree

const SpriteFactory = preload("res://scripts/visual/sprite_factory.gd")
const UpgradeManagerScript = preload("res://scripts/systems/upgrade_manager.gd")

## Headless check: every upgrade must produce a crisp 48x48 icon texture.
func _init() -> void:
	var failed := false
	var upgrade_ids: Array[String] = []
	for upgrade in UpgradeManagerScript.UPGRADES:
		upgrade_ids.append(upgrade.id)

	for upgrade_id in upgrade_ids:
		if not SpriteFactory.UPGRADE_ICON_ROWS.has(upgrade_id):
			push_error("validate_upgrade_icons: missing icon rows for '%s'" % upgrade_id)
			failed = true
			continue
		var tex: Texture2D = SpriteFactory.get_upgrade_icon(upgrade_id)
		if tex == null:
			push_error("validate_upgrade_icons: null texture for '%s'" % upgrade_id)
			failed = true
			continue
		var tex_size: Vector2 = tex.get_size()
		var expected := 16 * SpriteFactory.ICON_PIXEL_SCALE
		if int(tex_size.x) != expected or int(tex_size.y) != expected:
			push_error(
				"validate_upgrade_icons: expected %dx%d for '%s', got %s"
				% [expected, expected, upgrade_id, tex_size]
			)
			failed = true

	if failed:
		quit(1)
		return
	print("validate_upgrade_icons: OK — %d upgrade icons at %dx%d" % [
		upgrade_ids.size(),
		16 * SpriteFactory.ICON_PIXEL_SCALE,
		16 * SpriteFactory.ICON_PIXEL_SCALE,
	])
	quit(0)
