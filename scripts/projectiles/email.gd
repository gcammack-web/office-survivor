extends Area2D

const MAX_DISTANCE_FROM_PLAYER := 1800.0
const MAX_LIFETIME := 10.0
const HIT_RADIUS := 22.0

var target: Node2D
var damage: int = 15
var speed: float = 360.0
var turn_rate: float = 7.0
var direction: Vector2 = Vector2.RIGHT
var lifetime: float = MAX_LIFETIME

var _player: Node2D

func setup(new_target: Node2D, amount: int) -> void:
	target = new_target
	damage = amount
	direction = Vector2.RIGHT.rotated(randf() * TAU)
	lifetime = MAX_LIFETIME

func _ready() -> void:
	add_to_group("projectiles")
	_player = get_tree().get_first_node_in_group("player")
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	if GameEvents.is_paused_for_upgrade:
		return

	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
		return

	if not _ensure_target():
		return

	var to_target := target.global_position - global_position
	var distance := to_target.length()
	if distance <= HIT_RADIUS:
		_hit_target(target)
		return

	direction = direction.lerp(to_target / distance, turn_rate * delta).normalized()
	position += direction * speed * delta
	rotation = direction.angle()

	if _is_too_far_from_player():
		queue_free()

func _ensure_target() -> bool:
	if is_instance_valid(target):
		return true
	return _acquire_nearest_enemy()

func _acquire_nearest_enemy() -> bool:
	var nearest: Node2D = null
	var nearest_dist := INF
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue
		var dist := global_position.distance_squared_to(enemy.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = enemy
	target = nearest
	return target != null

func _is_too_far_from_player() -> bool:
	if is_instance_valid(_player):
		return global_position.distance_to(_player.global_position) > MAX_DISTANCE_FROM_PLAYER
	return false

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_hurtbox"):
		var enemy := area.get_parent()
		_hit_target(enemy)

func _hit_target(enemy: Node2D) -> void:
	if enemy and is_instance_valid(enemy) and enemy.has_method("take_damage"):
		enemy.take_damage(damage)
	call_deferred("queue_free")
