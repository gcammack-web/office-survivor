extends "res://scripts/weapons/weapon_base.gd"

const BASE_COOLDOWN := 28.0
const BASE_DAMAGE := 40
const SLOW_DURATION := 1.5
const ENEMY_SLOW := 0.22
const PLAYER_SLOW := 0.72

var cooldown_timer: float = 0.0


func _ready() -> void:
	super._ready()
	cooldown_timer = 5.0


func _process(delta: float) -> void:
	if GameEvents.is_paused_for_upgrade:
		return
	cooldown_timer -= delta
	if cooldown_timer <= 0.0:
		_trigger_jam()
		cooldown_timer = _get_cooldown()


func level_up() -> void:
	super.level_up()


func _get_cooldown() -> float:
	return maxf(18.0, BASE_COOLDOWN - (level - 1) * 2.5)


func _get_damage() -> int:
	return int(round(BASE_DAMAGE * (1.0 + (level - 1) * 0.2) * get_damage_multiplier()))


func _trigger_jam() -> void:
	GameAudio.play_printer_jam()
	_apply_screen_effects()
	GameEvents.apply_movement_slow(PLAYER_SLOW, ENEMY_SLOW, SLOW_DURATION)
	_damage_on_screen_enemies()
	_spawn_paper_burst()


func _apply_screen_effects() -> void:
	var hud := get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("flash_screen"):
		hud.flash_screen(Color(0.85, 0.9, 1.0, 0.55), SLOW_DURATION * 0.6)


func _damage_on_screen_enemies() -> void:
	var camera := get_viewport().get_camera_2d()
	if camera == null:
		return
	var view_size := get_viewport().get_visible_rect().size / camera.zoom
	var center := camera.get_screen_center_position()
	var half := view_size * 0.55
	var rect := Rect2(center - half, view_size * 1.1)
	var damage := _get_damage()
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue
		if rect.has_point(enemy.global_position) and enemy.has_method("take_damage"):
			enemy.take_damage(damage)


func _spawn_paper_burst() -> void:
	var entities := get_tree().current_scene.get_node("Entities")
	for i in 12:
		var scrap := ColorRect.new()
		scrap.size = Vector2(6, 8)
		scrap.color = Color(0.92, 0.92, 0.88, 0.9)
		scrap.position = player.global_position + Vector2(randf_range(-40, 40), randf_range(-30, 30))
		scrap.rotation = randf() * TAU
		entities.add_child(scrap)
		var tween := scrap.create_tween()
		var end := scrap.position + Vector2(randf_range(-120, 120), randf_range(-140, -40))
		tween.set_parallel(true)
		tween.tween_property(scrap, "position", end, 0.55).set_ease(Tween.EASE_OUT)
		tween.tween_property(scrap, "modulate:a", 0.0, 0.55)
		tween.tween_property(scrap, "rotation", scrap.rotation + randf_range(-2.0, 2.0), 0.55)
		tween.chain().tween_callback(scrap.queue_free)
