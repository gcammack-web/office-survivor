extends "res://scripts/weapons/weapon_base.gd"

const PROJECTILE_SCENE := preload("res://scenes/projectiles/staple.tscn")
const BASE_COOLDOWN := 1.1
const BASE_DAMAGE := 12

var cooldown_timer: float = 0.0

func _ready() -> void:
	super._ready()
	cooldown_timer = 0.2

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
	return maxf(0.25, BASE_COOLDOWN - (level - 1) * 0.12)

func _get_damage() -> int:
	return int(round(BASE_DAMAGE * (1.0 + (level - 1) * 0.25) * get_damage_multiplier()))

func _fire() -> void:
	var target := find_nearest_enemy()
	if target == null:
		return
	var direction := (target.global_position - player.global_position).normalized()
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT

	var projectile_count := 1 + int((level - 1) / 2)
	var spread := 0.15
	var mid := (projectile_count - 1) * 0.5

	GameAudio.play_weapon_fire()
	for i in projectile_count:
		if not can_spawn_projectile():
			break
		var angle_offset := (float(i) - mid) * spread
		var dir := direction.rotated(angle_offset)
		var projectile := PROJECTILE_SCENE.instantiate()
		projectile.global_position = player.global_position + dir * 20.0
		projectile.setup(dir, _get_damage(), level >= 4)
		get_tree().current_scene.get_node("Entities").add_child(projectile)
