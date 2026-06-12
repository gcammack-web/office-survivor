extends Area2D

const MAX_DISTANCE_FROM_PLAYER := 1800.0

var direction: Vector2 = Vector2.RIGHT
var damage: int = 10
var piercing: bool = false
var speed: float = 520.0

var _player: Node2D

func setup(fire_direction: Vector2, amount: int, can_pierce: bool = false) -> void:
	direction = fire_direction.normalized()
	damage = amount
	piercing = can_pierce
	rotation = direction.angle()

func _ready() -> void:
	add_to_group("projectiles")
	_player = get_tree().get_first_node_in_group("player")
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	if GameEvents.is_paused_for_upgrade:
		return
	position += direction * speed * delta
	if _is_too_far_from_player():
		queue_free()

func _is_too_far_from_player() -> bool:
	if is_instance_valid(_player):
		return global_position.distance_to(_player.global_position) > MAX_DISTANCE_FROM_PLAYER
	return global_position.length() > 4000.0

func _on_body_entered(body: Node2D) -> void:
	_try_hit(body)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_hurtbox"):
		var enemy := area.get_parent()
		_hit_enemy(enemy)

func _try_hit(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		_hit_enemy(body)

func _hit_enemy(enemy: Node2D) -> void:
	if enemy and enemy.has_method("take_damage"):
		enemy.take_damage(damage)
	if not piercing:
		call_deferred("queue_free")
