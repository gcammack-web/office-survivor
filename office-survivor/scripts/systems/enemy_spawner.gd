extends Node2D

const ENEMY_SCENE := preload("res://scenes/enemies/enemy.tscn")
const BOSS_SCENE := preload("res://scenes/enemies/boss_enemy.tscn")
const EnemyBaseScript = preload("res://scripts/enemies/enemy.gd")

# --- Base spawn cadence ---
const BASE_SPAWN_INTERVAL := 1.35

# --- Late-game performance tuning (player level 25+) ---
const LATE_GAME_LEVEL_START := 25
const LATE_GAME_RAMP_LEVELS := 10.0
const LATE_GAME_PRESSURE_DAMPEN := 0.50  # up to ~50% slower spawns at full ramp
const LATE_GAME_BURST_DAMPEN := 0.72     # up to 72% fewer bonus burst procs
const LATE_GAME_LEVEL_TERM_SCALE := 0.55 # soften the level-20+ pressure curve
# Extra dampening during L28–L35 when enemy counts spike hardest.
const HIGH_LEVEL_START := 28
const HIGH_LEVEL_RAMP_LEVELS := 7.0
const HIGH_LEVEL_PRESSURE_DAMPEN := 0.24
const HIGH_LEVEL_BURST_DAMPEN := 0.35
const MAX_CONCURRENT_ENEMIES_BASE := 100
const MAX_CONCURRENT_ENEMIES_LATE := 60  # cap at level 30+
const ENEMY_CAP_LEVEL_START := 26
const ENEMY_CAP_RAMP_LEVELS := 4.0

var spawn_radius_min: float = 520.0
var spawn_radius_max: float = 680.0
var elapsed: float = 0.0
var spawn_timer: float = 0.0
var spawn_interval: float = 1.4
var player: Node2D
var _last_pressure: float = 0.0

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	GameEvents.run_started.connect(_on_run_started)

func _on_run_started() -> void:
	elapsed = 0.0
	spawn_timer = 0.0
	spawn_interval = 1.4
	spawn_radius_min = 520.0
	spawn_radius_max = 680.0
	_last_pressure = 0.0

func _process(delta: float) -> void:
	if GameEvents.is_paused_for_upgrade:
		return
	if not is_instance_valid(player):
		return
	elapsed += delta
	spawn_timer -= delta
	var player_level := _get_player_level()
	var pressure := _spawn_pressure(player_level)
	_last_pressure = maxf(_last_pressure, pressure)
	spawn_interval = BASE_SPAWN_INTERVAL / _last_pressure

	while spawn_timer <= 0.0:
		var burst := _spawn_burst_count(player_level)
		for _i in burst:
			_spawn_enemy()
		spawn_timer += spawn_interval

func _get_player_level() -> int:
	if player and "level" in player:
		return int(player.level)
	return 1

func _late_game_blend(level: int) -> float:
	return clampf(
		(float(level) - LATE_GAME_LEVEL_START) / LATE_GAME_RAMP_LEVELS,
		0.0,
		1.0
	)

func _high_level_blend(level: int) -> float:
	return clampf(
		(float(level) - HIGH_LEVEL_START) / HIGH_LEVEL_RAMP_LEVELS,
		0.0,
		1.0
	)

func _spawn_pressure(level: int) -> float:
	var level_factor := 1.0 + maxf(0.0, float(level - 1)) * 0.048
	level_factor += pow(maxf(0.0, float(level - 5)), 1.22) * 0.034
	level_factor += pow(maxf(0.0, float(level - 20)), 1.18) * 0.022 * LATE_GAME_LEVEL_TERM_SCALE
	var time_factor := 1.0 + elapsed * 0.014
	time_factor += pow(elapsed / 90.0, 1.12) * 0.55
	var pressure := level_factor * time_factor
	var blend := _late_game_blend(level)
	pressure *= 1.0 - blend * LATE_GAME_PRESSURE_DAMPEN
	var high_blend := _high_level_blend(level)
	pressure *= 1.0 - high_blend * HIGH_LEVEL_PRESSURE_DAMPEN
	return pressure

func _spawn_burst_count(level: int) -> int:
	var blend := _late_game_blend(level)
	var high_blend := _high_level_blend(level)
	var burst_scale := 1.0 - blend * LATE_GAME_BURST_DAMPEN
	burst_scale *= 1.0 - high_blend * HIGH_LEVEL_BURST_DAMPEN
	var count := 1
	if level >= 8:
		count += 1 if randf() < (0.12 + float(level - 8) * 0.018) * burst_scale else 0
	if level >= 15:
		count += 1 if randf() < (0.08 + float(level - 15) * 0.022) * burst_scale else 0
	if level >= 25:
		count += 1 if randf() < (0.08 + float(level - 25) * 0.012) * burst_scale else 0
	if level >= 35:
		count += 1 if randf() < (0.08 + float(level - 35) * 0.012) * burst_scale else 0
	var max_burst := 4
	if level >= 30:
		max_burst = 2
	elif level >= 25:
		max_burst = 3
	return mini(count, max_burst)

func _living_enemy_count() -> int:
	var count := 0
	for node in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(node):
			count += 1
	return count

func _max_concurrent_enemies(level: int) -> int:
	var blend := clampf(
		(float(level) - ENEMY_CAP_LEVEL_START) / ENEMY_CAP_RAMP_LEVELS,
		0.0,
		1.0
	)
	return int(round(lerpf(
		float(MAX_CONCURRENT_ENEMIES_BASE),
		float(MAX_CONCURRENT_ENEMIES_LATE),
		blend
	)))

func _spawn_enemy(type: String = "") -> void:
	var level := _get_player_level()
	if _living_enemy_count() >= _max_concurrent_enemies(level):
		return
	var enemy := ENEMY_SCENE.instantiate()
	var angle := randf() * TAU
	var distance := randf_range(spawn_radius_min, spawn_radius_max)
	var offset := Vector2.from_angle(angle) * distance
	enemy.global_position = player.global_position + offset
	enemy.setup(type if type != "" else _pick_enemy_type(), _get_player_level())
	get_parent().get_node("Entities").add_child(enemy)


func tighten_spawn_ring(min_radius: float, max_radius: float) -> void:
	spawn_radius_min = min_radius
	spawn_radius_max = max_radius


func spawn_boss(boss_id: String, tier: int = 1) -> void:
	if not is_instance_valid(player):
		return
	GameAudio.play_boss_spawn()
	var boss := BOSS_SCENE.instantiate()
	var angle := randf() * TAU
	var distance := randf_range(spawn_radius_min * 0.85, spawn_radius_max * 0.95)
	boss.global_position = player.global_position + Vector2.from_angle(angle) * distance
	if boss.has_method("setup_boss"):
		boss.setup_boss(boss_id, tier)
	get_parent().get_node("Entities").add_child(boss)


func spawn_swarm(count: int) -> void:
	for i in count:
		_spawn_enemy("slack_message")

func _pick_enemy_type() -> String:
	var level := _get_player_level()
	var pool: Array[String] = []
	var weights: PackedFloat32Array = PackedFloat32Array()
	for type in EnemyBaseScript.ENEMY_DATA:
		var data: Dictionary = EnemyBaseScript.ENEMY_DATA[type]
		if level >= int(data.unlock_level):
			pool.append(type)
			weights.append(_type_weight(type, level, data))
	if pool.is_empty():
		return "deadline"
	var total := 0.0
	for w in weights:
		total += w
	var roll := randf() * total
	var cumulative := 0.0
	for i in pool.size():
		cumulative += weights[i]
		if roll <= cumulative:
			return pool[i]
	return pool.back()

func _type_weight(type: String, level: int, data: Dictionary) -> float:
	var tier := int(data.unlock_level)
	var base := 1.0 + float(tier) * 0.08
	if level >= tier + 5:
		base += float(level - tier) * 0.06
	if type == "slack_message":
		base = maxf(0.35, 1.4 - float(level) * 0.035)
	elif type == "deadline":
		base = maxf(0.5, 1.2 - float(level) * 0.015)
	elif type == "executive" and level >= 25:
		base += float(level - 25) * 0.12
	elif type == "crunch_time" and level >= 20:
		base += float(level - 20) * 0.08
	return base
