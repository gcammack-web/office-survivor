extends "res://scripts/enemies/enemy.gd"

const BOSS_DATA := {
	"performance_review": {
		"hp": 420, "speed": 58, "damage": 38, "xp": 80,
		"color": Color("#9b2c2c"), "size": Vector2(56, 60),
		"sprite_type": "performance_review",
	},
	"all_hands_chair": {
		"hp": 720, "speed": 50, "damage": 52, "xp": 140,
		"color": Color("#742a2a"), "size": Vector2(68, 72),
		"sprite_type": "all_hands_chair",
	},
	"quarterly_review": {
		"hp": 380, "speed": 62, "damage": 34, "xp": 70,
		"color": Color("#9b2c2c"), "size": Vector2(56, 60),
		"sprite_type": "quarterly_review",
	},
	"mid_year_review": {
		"hp": 560, "speed": 60, "damage": 46, "xp": 110,
		"color": Color("#9b2c2c"), "size": Vector2(60, 64),
		"sprite_type": "performance_review",
	},
	"annual_review": {
		"hp": 780, "speed": 56, "damage": 58, "xp": 160,
		"color": Color("#742a2a"), "size": Vector2(64, 68),
		"sprite_type": "performance_review",
	},
}

var boss_tier: int = 1


func is_boss() -> bool:
	return true


func setup_boss(boss_id: String, tier: int = 1) -> void:
	enemy_type = boss_id
	boss_tier = maxi(1, tier)
	if is_node_ready():
		_apply_boss(boss_id)


func _ready() -> void:
	add_to_group("enemies")
	player = get_tree().get_first_node_in_group("player")
	if BOSS_DATA.has(enemy_type):
		_apply_boss(enemy_type)
	else:
		_apply_type(enemy_type)


func _apply_boss(boss_id: String) -> void:
	var data: Dictionary = BOSS_DATA.get(boss_id, BOSS_DATA.performance_review)
	var tier_mult := 1.0 + (boss_tier - 1) * 0.42
	hp = int(round(data.hp * tier_mult))
	contact_damage = int(round(data.damage * tier_mult))
	xp_value = int(round(data.xp * (1.0 + (boss_tier - 1) * 0.35)))
	var size: Vector2 = data.size * (1.0 + (boss_tier - 1) * 0.06)
	var sprite_key: String = data.sprite_type
	if sprite is Sprite2D:
		var tex := SpriteFactory.get_boss_texture(sprite_key)
		sprite.texture = tex
		var tex_size := tex.get_size()
		if tex_size.x > 0.0:
			_base_scale = size / tex_size
			sprite.scale = _base_scale
		sprite.position = -size * 0.5
	elif sprite is ColorRect:
		sprite.size = size
		sprite.position = -size * 0.5
		sprite.color = data.color
		_base_scale = Vector2.ONE
	_fit_collision_shapes(size)


func take_damage(amount: int) -> void:
	if _dying:
		return
	hp -= amount
	_notify_floating_damage(amount)
	GameAudio.play_enemy_hit()
	sprite.modulate = Color(2.5, 1.8, 1.8)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)
	tween.tween_property(sprite, "scale", _base_scale * 1.12, 0.05).set_trans(Tween.TRANS_BACK)
	tween.chain().tween_property(sprite, "scale", _base_scale, 0.08)
	if hp <= 0:
		_dying = true
		call_deferred("die")


func _physics_process(_delta: float) -> void:
	if GameEvents.is_paused_for_upgrade:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	if not is_instance_valid(player):
		return
	var direction := (player.global_position - global_position).normalized()
	var data: Dictionary = BOSS_DATA.get(enemy_type, BOSS_DATA.performance_review)
	var speed: float = data.speed * GameEvents.movement_slow_enemy
	velocity = direction * speed
	move_and_slide()
