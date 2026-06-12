extends SceneTree

const SpriteFactory = preload("res://scripts/visual/sprite_factory.gd")

## Headless check: every ENEMY_ROWS key must produce a non-null texture with valid size.
func _init() -> void:
	var failed := false
	for enemy_type in SpriteFactory.ENEMY_ROWS:
		var tex: Texture2D = SpriteFactory.get_enemy_texture(enemy_type)
		if tex == null:
			push_error("validate_enemy_textures: null texture for '%s'" % enemy_type)
			failed = true
			continue
		var tex_size: Vector2 = tex.get_size()
		if tex_size.x <= 0.0 or tex_size.y <= 0.0:
			push_error(
				"validate_enemy_textures: invalid size %s for '%s'" % [tex_size, enemy_type]
			)
			failed = true
	if failed:
		quit(1)
		return
	print("validate_enemy_textures: OK — %d enemy types" % SpriteFactory.ENEMY_ROWS.size())
	quit(0)
