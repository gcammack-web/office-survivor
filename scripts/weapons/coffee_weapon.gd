extends "res://scripts/weapons/weapon_base.gd"

const BASE_RADIUS := 70.0
const BASE_DAMAGE := 6
const TICK_RATE := 0.42
const SHAPE_QUERY_MAX := 20

var tick_timer: float = 0.0
var aura: ColorRect
var _query_circle := CircleShape2D.new()
var _query_params := PhysicsShapeQueryParameters2D.new()

func _ready() -> void:
	super._ready()
	aura = ColorRect.new()
	aura.color = Color(0.55, 0.28, 0.12, 0.25)
	aura.position = Vector2(-BASE_RADIUS, -BASE_RADIUS)
	add_child(aura)
	tick_timer = TICK_RATE
	_query_params.collide_with_areas = true
	_query_params.collide_with_bodies = true
	_query_params.collision_mask = 2

func _physics_process(delta: float) -> void:
	if GameEvents.is_paused_for_upgrade:
		return
	if not is_instance_valid(player):
		return
	global_position = player.global_position
	var radius := _get_radius()
	aura.size = Vector2(radius * 2.0, radius * 2.0)
	aura.position = Vector2(-radius, -radius)

	tick_timer -= delta
	if tick_timer <= 0.0:
		_damage_in_radius(radius)
		_pulse_aura()
		tick_timer = TICK_RATE

func level_up() -> void:
	super.level_up()

func _get_radius() -> float:
	return BASE_RADIUS + (level - 1) * 12.0

func _get_damage() -> int:
	return int(round(BASE_DAMAGE * (1.0 + (level - 1) * 0.3) * get_damage_multiplier()))

func _damage_in_radius(radius: float) -> void:
	var space := get_world_2d().direct_space_state
	if space == null:
		return
	_query_circle.radius = radius
	_query_params.shape = _query_circle
	_query_params.transform = Transform2D(0.0, global_position)
	var damaged: Dictionary = {}
	for result in space.intersect_shape(_query_params, SHAPE_QUERY_MAX):
		var enemy: Node = null
		var collider: Object = result.collider
		if collider is Area2D and collider.is_in_group("enemy_hurtbox"):
			enemy = collider.get_parent()
		elif collider is CharacterBody2D and collider.is_in_group("enemies"):
			enemy = collider
		if enemy == null or not is_instance_valid(enemy):
			continue
		var enemy_id: int = enemy.get_instance_id()
		if damaged.has(enemy_id):
			continue
		damaged[enemy_id] = true
		if enemy.has_method("take_damage"):
			var damage := _get_damage()
			enemy.call_deferred("take_damage", damage)

func _pulse_aura() -> void:
	if aura == null:
		return
	aura.modulate = Color(1.25, 1.05, 0.85, 1.0)
	var tween := create_tween()
	tween.tween_property(aura, "modulate", Color.WHITE, 0.14)
