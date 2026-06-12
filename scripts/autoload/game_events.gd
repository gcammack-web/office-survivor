extends Node

signal enemy_killed(enemy: Node2D)
signal player_leveled_up(level: int)
signal player_died
signal run_started
signal upgrade_chosen(upgrade_id: String)
signal pause_toggle_requested

var run_time: float = 0.0
var is_paused_for_upgrade: bool = false
var movement_slow_player: float = 1.0
var movement_slow_enemy: float = 1.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func start_run() -> void:
	run_time = 0.0
	is_paused_for_upgrade = false
	movement_slow_player = 1.0
	movement_slow_enemy = 1.0
	run_started.emit()


func apply_movement_slow(player_mult: float, enemy_mult: float, duration: float) -> void:
	movement_slow_player = player_mult
	movement_slow_enemy = enemy_mult
	var timer: Timer
	if has_node("MovementSlowTimer"):
		timer = $MovementSlowTimer
		timer.stop()
	else:
		timer = Timer.new()
		timer.name = "MovementSlowTimer"
		timer.one_shot = true
		timer.process_mode = Node.PROCESS_MODE_ALWAYS
		timer.timeout.connect(_reset_movement_slow)
		add_child(timer)
	timer.wait_time = duration
	timer.start()


func _reset_movement_slow() -> void:
	movement_slow_player = 1.0
	movement_slow_enemy = 1.0

func notify_enemy_killed(enemy: Node2D) -> void:
	enemy_killed.emit(enemy)

func notify_player_leveled_up(level: int) -> void:
	player_leveled_up.emit(level)

func notify_player_died() -> void:
	player_died.emit()

func notify_upgrade_chosen(upgrade_id: String) -> void:
	upgrade_chosen.emit(upgrade_id)
	is_paused_for_upgrade = false

func set_upgrade_pause(paused: bool) -> void:
	is_paused_for_upgrade = paused


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		pause_toggle_requested.emit()
