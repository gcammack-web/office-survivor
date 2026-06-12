extends Node

const STANDUP_TIME := 300.0
const PERFORMANCE_REVIEW_TIME := 600.0
const ALL_HANDS_TIME := 900.0
const BOSS_COOLDOWN := 30.0
const SECONDS_PER_LEVEL_ESTIMATE := 55.0

const TIMED_EVENTS := [
	{"key": "standup", "time": STANDUP_TIME, "label": "Stand-up Meeting (5:00)"},
	{"key": "performance_review", "time": PERFORMANCE_REVIEW_TIME, "label": "Performance Review (10:00)"},
	{"key": "all_hands", "time": ALL_HANDS_TIME, "label": "All-Hands (15:00)"},
]

const LEVEL_BOSS_DATA := {
	10: {
		"boss_id": "quarterly_review",
		"title": "Level 10 Boss: Quarterly Review!",
		"subtitle": "Time to justify your existence on a slide deck.",
	},
	20: {
		"boss_id": "mid_year_review",
		"title": "Level 20 Boss: Mid-Year Review!",
		"subtitle": "Your KPIs are being audited in real time.",
	},
	30: {
		"boss_id": "annual_review",
		"title": "Level 30 Boss: Annual Review!",
		"subtitle": "Executive leadership has questions. Many questions.",
	},
}

var _fired: Dictionary = {}
var _last_boss_time: float = -999.0
var _main: Node2D
var _spawner: Node2D
var _hud: CanvasLayer


func _ready() -> void:
	GameEvents.run_started.connect(_on_run_started)
	GameEvents.player_leveled_up.connect(_on_player_leveled_up)


func setup(main: Node2D, spawner: Node2D, hud: CanvasLayer) -> void:
	_main = main
	_spawner = spawner
	_hud = hud


func get_next_milestone(player_level: int, run_time: float) -> String:
	var candidates: Array[Dictionary] = []
	for event in TIMED_EVENTS:
		if _fired.get(event.key, false):
			continue
		var seconds_until := float(event.time) - run_time
		if seconds_until <= 0.0:
			continue
		candidates.append({
			"label": "Next: %s" % event.label,
			"sort_time": seconds_until,
		})
	var next_boss_level := _next_boss_level(player_level)
	if next_boss_level > player_level:
		var boss_name := _boss_display_name(next_boss_level)
		var levels_until := next_boss_level - player_level
		candidates.append({
			"label": "Next: %s (Lv %d)" % [boss_name, next_boss_level],
			"sort_time": float(levels_until) * SECONDS_PER_LEVEL_ESTIMATE,
		})
	if candidates.is_empty():
		return "Next: Survive!"
	candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.sort_time) < float(b.sort_time)
	)
	return candidates[0].label


func _next_boss_level(player_level: int) -> int:
	return ceili(float(player_level + 1) / 10.0) * 10


func _boss_display_name(level: int) -> String:
	if LEVEL_BOSS_DATA.has(level):
		var title: String = LEVEL_BOSS_DATA[level].title
		var parts := title.split(": ", false, 1)
		if parts.size() > 1:
			return parts[1].trim_suffix("!")
		return title
	return "Executive Review"


func _on_run_started() -> void:
	_fired.clear()
	_last_boss_time = -999.0


func _process(_delta: float) -> void:
	if _main == null or not _main.running:
		return
	if GameEvents.is_paused_for_upgrade:
		return
	var t := GameEvents.run_time
	if t >= STANDUP_TIME and not _fired.get("standup", false):
		_fired["standup"] = true
		_trigger_standup()
	if t >= PERFORMANCE_REVIEW_TIME and not _fired.get("performance_review", false):
		_fired["performance_review"] = true
		_trigger_performance_review()
	if t >= ALL_HANDS_TIME and not _fired.get("all_hands", false):
		_fired["all_hands"] = true
		_trigger_all_hands()


func _on_player_leveled_up(level: int) -> void:
	if _main == null or not _main.running:
		return
	if level == 5 and not _fired.get("donut_tip", false):
		_fired["donut_tip"] = true
		_announce("Office Tip", "Donuts sometimes appear around the office and restore 30 HP!")
		return
	if level % 10 != 0:
		return
	var key := "level_boss_%d" % level
	if _fired.get(key, false):
		return
	_fired[key] = true
	var tier := level / 10
	var data: Dictionary
	if LEVEL_BOSS_DATA.has(level):
		data = LEVEL_BOSS_DATA[level]
	else:
		data = {
			"boss_id": "annual_review",
			"title": "Level %d Boss: Executive Review!" % level,
			"subtitle": "Another quarter, another existential threat.",
		}
	_trigger_boss(data.boss_id, data.title, data.subtitle, tier)


func _announce(title: String, subtitle: String) -> void:
	GameAudio.play_event_sting()
	if _hud and _hud.has_method("show_announcement"):
		_hud.show_announcement(title, subtitle)


func _trigger_boss(boss_id: String, title: String, subtitle: String, tier: int = 1, announce: bool = true) -> void:
	if announce:
		_announce(title, subtitle)
	_last_boss_time = GameEvents.run_time
	if _spawner and _spawner.has_method("spawn_boss"):
		_spawner.spawn_boss(boss_id, tier)


func _trigger_standup() -> void:
	_announce("Stand-up Meeting", "Enemies spawn closer — no escaping the calendar.")
	if _spawner and _spawner.has_method("tighten_spawn_ring"):
		_spawner.tighten_spawn_ring(340.0, 460.0)


func _trigger_performance_review() -> void:
	if GameEvents.run_time - _last_boss_time < BOSS_COOLDOWN:
		return
	_trigger_boss(
		"performance_review",
		"Performance Review",
		"Your manager has entered the chat.",
		1,
	)


func _trigger_all_hands() -> void:
	_announce("All-Hands", "Mandatory attendance. Everyone is here.")
	if _spawner:
		if _spawner.has_method("spawn_swarm"):
			_spawner.spawn_swarm(18)
		if GameEvents.run_time - _last_boss_time >= BOSS_COOLDOWN:
			_trigger_boss(
				"all_hands_chair",
				"All-Hands Chair",
				"The executive escalation has arrived.",
				2,
				false,
			)
