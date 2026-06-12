extends Node2D
class_name WeaponBase

const MAX_ACTIVE_PROJECTILES := 70
const MAX_ACTIVE_PROJECTILES_LATE := 60
const PROJECTILE_CAP_LATE_LEVEL := 30

@export var weapon_name: String = "Weapon"
var level: int = 1
var player: Node2D

func _ready() -> void:
	player = get_parent().get_parent() as Node2D
	if not is_instance_valid(player) or not player.is_in_group("player"):
		player = get_tree().get_first_node_in_group("player") as Node2D

func level_up() -> void:
	level += 1

func get_damage_multiplier() -> float:
	if player and player.has_method("get_damage_multiplier"):
		return player.get_damage_multiplier()
	return 1.0

func _active_projectile_count() -> int:
	var count := 0
	for node in get_tree().get_nodes_in_group("projectiles"):
		if is_instance_valid(node):
			count += 1
	return count

func _max_active_projectiles() -> int:
	if is_instance_valid(player) and "level" in player:
		if int(player.level) >= PROJECTILE_CAP_LATE_LEVEL:
			return MAX_ACTIVE_PROJECTILES_LATE
	return MAX_ACTIVE_PROJECTILES

func can_spawn_projectile() -> bool:
	return _active_projectile_count() < _max_active_projectiles()

func find_nearest_enemy() -> Node2D:
	var enemies := get_tree().get_nodes_in_group("enemies")
	var nearest: Node2D = null
	var nearest_dist := INF
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var dist := player.global_position.distance_squared_to(enemy.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = enemy
	return nearest
