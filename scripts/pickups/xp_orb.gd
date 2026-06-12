extends Area2D

const SpriteFactory = preload("res://scripts/visual/sprite_factory.gd")
const BASE_MAGNET_RADIUS := 120.0
const BASE_COLLECT_RADIUS := 18.0

@export var xp_value: int = 2
@export var magnet_speed: float = 380.0

var player: Node2D
var collected: bool = false
var _pulse_time: float = 0.0

@onready var _sprite: Node = $Sprite


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	body_entered.connect(_on_body_entered)
	_apply_orb_visual()


func _apply_orb_visual() -> void:
	if _sprite is Sprite2D:
		var tex := SpriteFactory.get_xp_orb_texture()
		_sprite.texture = tex
		_sprite.centered = true
		var tex_size := tex.get_size()
		if tex_size.x > 0.0:
			_sprite.scale = Vector2(12, 12) / tex_size


func _physics_process(delta: float) -> void:
	if collected or GameEvents.is_paused_for_upgrade:
		return
	_pulse_time += delta
	if _sprite is Sprite2D:
		var pulse := 0.85 + 0.15 * sin(_pulse_time * 8.0)
		_sprite.modulate = Color(0.5 * pulse + 0.5, 0.85 * pulse + 0.15, 1.0, 0.9 + 0.1 * pulse)
		var tex_size: Vector2 = _sprite.texture.get_size()
		if tex_size.x > 0.0:
			var base_scale: Vector2 = Vector2(12, 12) / tex_size
			_sprite.scale = base_scale * (0.92 + 0.08 * pulse)
	elif _sprite is ColorRect:
		var pulse := 0.85 + 0.15 * sin(_pulse_time * 8.0)
		_sprite.modulate = Color(0.5 * pulse + 0.5, 0.85 * pulse + 0.15, 1.0, 0.9 + 0.1 * pulse)
		var base_size := Vector2(12, 12)
		_sprite.size = base_size * (0.92 + 0.08 * pulse)
		_sprite.position = -_sprite.size * 0.5
	if not is_instance_valid(player):
		return
	var magnet_radius := _get_magnet_radius()
	var collect_radius := _get_collect_radius()
	var dist := global_position.distance_to(player.global_position)
	if dist <= collect_radius:
		call_deferred("_collect")
		return
	if dist <= magnet_radius:
		var direction := (player.global_position - global_position).normalized()
		position += direction * magnet_speed * delta


func _get_magnet_radius() -> float:
	var mult := 1.0
	var upgrade_manager := get_node_or_null("/root/Main/UpgradeManager")
	if upgrade_manager and upgrade_manager.has_method("get_magnet_radius_multiplier"):
		mult = upgrade_manager.get_magnet_radius_multiplier()
	return BASE_MAGNET_RADIUS * mult


func _get_collect_radius() -> float:
	var bonus := 0.0
	var upgrade_manager := get_node_or_null("/root/Main/UpgradeManager")
	if upgrade_manager and upgrade_manager.has_method("get_collect_radius_bonus"):
		bonus = upgrade_manager.get_collect_radius_bonus()
	return BASE_COLLECT_RADIUS + bonus


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		call_deferred("_collect")


func _collect() -> void:
	if collected:
		return
	collected = true
	GameAudio.play_xp_pickup()
	if player and player.has_method("collect_xp"):
		player.collect_xp(xp_value)
	queue_free()
