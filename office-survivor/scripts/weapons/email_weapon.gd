extends "res://scripts/weapons/weapon_base.gd"

const PROJECTILE_SCENE := preload("res://scenes/projectiles/email.tscn")
const BASE_COOLDOWN := 1.6
const BASE_DAMAGE := 18

var cooldown_timer: float = 0.0

func _ready() -> void:
	super._ready()
	cooldown_timer = 0.4

func _process(delta: float) -> void:
	if GameEvents.is_paused_for_upgrade:
		return
	cooldown_timer -= delta
	if cooldown_timer <= 0.0:
		_fire()
		cooldown_timer = _get_cooldown()

func level_up() -> void:
	super.level_up()

func _get_cooldown() -> float:
	return maxf(0.4, BASE_COOLDOWN - (level - 1) * 0.15)

func _get_damage() -> int:
	return int(round(BASE_DAMAGE * (1.0 + (level - 1) * 0.22) * get_damage_multiplier()))

func _fire() -> void:
	var count := 1 + int((level - 1) / 2)
	for i in count:
		if not can_spawn_projectile():
			break
		var target := find_nearest_enemy()
		if target == null:
			break
		var projectile := PROJECTILE_SCENE.instantiate()
		projectile.global_position = player.global_position + Vector2(randf_range(-10, 10), -20)
		projectile.setup(target, _get_damage())
		get_tree().current_scene.get_node("Entities").add_child(projectile)
