extends Node2D

const DONUT_SCENE := preload("res://scenes/pickups/donut_pickup.tscn")

const CHECK_INTERVAL_MIN := 18.0
const CHECK_INTERVAL_MAX := 32.0
const SPAWN_CHANCE := 0.4
const SPAWN_DISTANCE_MIN := 120.0
const SPAWN_DISTANCE_MAX := 320.0

var _timer: float = 0.0
var _next_check: float = 24.0
var player: Node2D


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	GameEvents.run_started.connect(_on_run_started)


func _on_run_started() -> void:
	_timer = 0.0
	_next_check = randf_range(CHECK_INTERVAL_MIN, CHECK_INTERVAL_MAX)


func _process(delta: float) -> void:
	if GameEvents.is_paused_for_upgrade:
		return
	if not is_instance_valid(player):
		return
	if _has_donut_on_screen():
		return

	_timer += delta
	if _timer < _next_check:
		return

	_timer = 0.0
	_next_check = randf_range(CHECK_INTERVAL_MIN, CHECK_INTERVAL_MAX)
	if randf() > SPAWN_CHANCE:
		return
	_spawn_donut()


func _has_donut_on_screen() -> bool:
	return not get_tree().get_nodes_in_group("donut_pickup").is_empty()


func _spawn_donut() -> void:
	var donut := DONUT_SCENE.instantiate()
	var angle := randf() * TAU
	var distance := randf_range(SPAWN_DISTANCE_MIN, SPAWN_DISTANCE_MAX)
	donut.global_position = player.global_position + Vector2.from_angle(angle) * distance
	get_parent().get_node("Entities").add_child(donut)
