extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var upgrade_manager: Node = $UpgradeManager
@onready var weapon_manager: Node2D = $Player/WeaponManager
@onready var spawner: Node2D = $EnemySpawner
@onready var entities: Node2D = $Entities
@onready var hud: CanvasLayer = $HUD
@onready var upgrade_menu: CanvasLayer = $UpgradeMenu
@onready var game_over_screen: CanvasLayer = $GameOverScreen
@onready var title_screen: CanvasLayer = $TitleScreen
@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var run_event_manager: Node = $RunEventManager

var run_time: float = 0.0
var running: bool = false
var _pause_menu_open: bool = false


func _ready() -> void:
	GameEvents.player_leveled_up.connect(_on_player_leveled_up)
	GameEvents.player_died.connect(_on_player_died)
	GameEvents.run_started.connect(_on_run_started)
	GameEvents.pause_toggle_requested.connect(_on_pause_toggle_requested)
	pause_menu.resume_requested.connect(_on_pause_resume)
	pause_menu.restart_requested.connect(_on_pause_restart)
	pause_menu.quit_to_title_requested.connect(_on_pause_quit_to_title)
	run_event_manager.setup(self, spawner, hud)
	title_screen.show_screen(self)


func _on_pause_toggle_requested() -> void:
	if not _can_toggle_pause_menu() and not _pause_menu_open:
		return
	if _pause_menu_open:
		_close_pause_menu()
	elif _can_toggle_pause_menu():
		_open_pause_menu()


func _can_toggle_pause_menu() -> bool:
	if not running:
		return false
	if GameEvents.is_paused_for_upgrade:
		return false
	if title_screen.visible or game_over_screen.visible:
		return false
	return true


func _process(delta: float) -> void:
	if not running or GameEvents.is_paused_for_upgrade or _pause_menu_open:
		return
	run_time += delta
	GameEvents.run_time = run_time
	if hud:
		hud.update_run_time(run_time)


func start_run() -> void:
	_close_pause_menu()
	_clear_entities()
	run_time = 0.0
	running = true
	upgrade_manager.reset()
	weapon_manager.reset()
	player.reset_stats()
	player.global_position = Vector2.ZERO
	GameEvents.start_run()
	title_screen.hide()
	game_over_screen.hide()
	pause_menu.hide_menu()
	hud.show()
	GameAudio.start_music()
	# Stapler is the starter weapon — classic survivor feel.
	weapon_manager.grant_weapon("stapler")
	upgrade_manager.apply_upgrade("stapler")


func _clear_entities() -> void:
	for child in entities.get_children():
		child.queue_free()


func _on_run_started() -> void:
	pass


func _on_player_leveled_up(_level: int) -> void:
	if not running:
		return
	GameAudio.play_level_up()
	call_deferred("_open_upgrade_menu_with_slowmo")


func _open_upgrade_menu_with_slowmo() -> void:
	if not running:
		return
	Engine.time_scale = 0.2
	await get_tree().create_timer(0.3, true, false, true).timeout
	Engine.time_scale = 1.0
	_open_upgrade_menu()


func _open_upgrade_menu() -> void:
	if not running:
		return
	GameEvents.set_upgrade_pause(true)
	get_tree().paused = true
	var choices: Array[Dictionary] = upgrade_manager.roll_choices(3)
	upgrade_menu.show_choices(choices, upgrade_manager)


func _on_player_died() -> void:
	running = false
	_pause_menu_open = false
	Engine.time_scale = 1.0
	get_tree().paused = false
	GameEvents.set_upgrade_pause(false)
	GameAudio.stop_music()
	hud.hide()
	pause_menu.hide_menu()
	var stats := RunStats.snapshot(player.level)
	stats["best_weapon"] = weapon_manager.get_best_weapon_summary()
	game_over_screen.show_screen(run_time, self, stats)


func on_upgrade_picked(upgrade_id: String) -> void:
	GameEvents.notify_upgrade_chosen(upgrade_id)
	get_tree().paused = false


func restart_run() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false
	GameEvents.set_upgrade_pause(false)
	_pause_menu_open = false
	pause_menu.hide_menu()
	start_run()


func quit_to_title() -> void:
	running = false
	_pause_menu_open = false
	Engine.time_scale = 1.0
	get_tree().paused = false
	GameEvents.set_upgrade_pause(false)
	upgrade_menu.hide()
	_clear_entities()
	GameAudio.stop_music()
	hud.hide()
	pause_menu.hide_menu()
	game_over_screen.hide()
	title_screen.show_screen(self)


func _open_pause_menu() -> void:
	_pause_menu_open = true
	get_tree().paused = true
	pause_menu.show_menu()


func _close_pause_menu() -> void:
	_pause_menu_open = false
	pause_menu.hide_menu()
	get_tree().paused = false


func _on_pause_resume() -> void:
	_close_pause_menu()


func _on_pause_restart() -> void:
	restart_run()


func _on_pause_quit_to_title() -> void:
	quit_to_title()
