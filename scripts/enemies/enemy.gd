extends CharacterBody2D
class_name EnemyBase

const SpriteFactory = preload("res://scripts/visual/sprite_factory.gd")

const ENEMY_DATA := {
	"slack_message": {"hp": 12, "speed": 130, "damage": 5, "xp": 1, "color": Color("#38b2ac"), "size": Vector2(22, 22), "unlock_level": 1},
	"deadline": {"hp": 20, "speed": 95, "damage": 8, "xp": 3, "color": Color("#e53e3e"), "size": Vector2(28, 32), "unlock_level": 1},
	"meeting": {"hp": 35, "speed": 70, "damage": 12, "xp": 6, "color": Color("#805ad5"), "size": Vector2(32, 32), "unlock_level": 3},
	"overdue_report": {"hp": 28, "speed": 120, "damage": 10, "xp": 5, "color": Color("#dd6b20"), "size": Vector2(30, 32), "unlock_level": 5},
	"micromanager": {"hp": 55, "speed": 82, "damage": 16, "xp": 10, "color": Color("#9f7aea"), "size": Vector2(32, 32), "unlock_level": 10},
	"crunch_time": {"hp": 90, "speed": 58, "damage": 22, "xp": 14, "color": Color("#fc8181"), "size": Vector2(36, 36), "unlock_level": 15},
	"executive": {"hp": 70, "speed": 105, "damage": 18, "xp": 20, "color": Color("#1a365d"), "size": Vector2(32, 32), "unlock_level": 20},
}

@export var enemy_type: String = "deadline"

@onready var sprite = $Sprite
@onready var hurtbox: Area2D = $Hurtbox
@onready var body_shape: CircleShape2D = $CollisionShape2D.shape
@onready var hurt_shape: CircleShape2D = $Hurtbox/CollisionShape2D.shape

var hp: int = 20
var contact_damage: int = 8
var xp_value: int = 2
var player: Node2D
var _dying: bool = false
var _base_scale: Vector2 = Vector2.ONE


func _ready() -> void:
	add_to_group("enemies")
	player = get_tree().get_first_node_in_group("player")
	_apply_type(enemy_type)


func setup(type: String, player_level: int = 1) -> void:
	enemy_type = type
	if is_node_ready():
		_apply_type(type, player_level)


func _apply_type(type: String, player_level: int = 1) -> void:
	var data: Dictionary = ENEMY_DATA.get(type, ENEMY_DATA.deadline)
	var hp_scale := 1.0 + maxf(0, player_level - 1) * 0.018 + pow(maxf(0, float(player_level - 10)), 1.15) * 0.025
	var dmg_scale := 1.0 + maxf(0, player_level - 8) * 0.012
	hp = int(round(data.hp * hp_scale))
	contact_damage = int(round(data.damage * dmg_scale))
	xp_value = data.xp + int(maxf(0, player_level - data.unlock_level) * 0.15)
	var size: Vector2 = data.size
	if sprite is Sprite2D:
		var tex := SpriteFactory.get_enemy_texture(type)
		if tex == null:
			push_warning("EnemyBase: no texture for '%s', using deadline fallback" % type)
			tex = SpriteFactory.get_enemy_texture("deadline")
		if tex == null:
			tex = SpriteFactory.build_solid_texture(data.color)
		sprite.texture = tex
		var tex_size := tex.get_size()
		if tex_size.x > 0.0:
			_base_scale = size / tex_size
			sprite.scale = _base_scale
		sprite.position = -size * 0.5
	elif sprite is ColorRect:
		sprite.size = size
		sprite.position = -size * 0.5
		sprite.color = data.color
		_base_scale = Vector2.ONE
	_fit_collision_shapes(size)


func get_contact_damage() -> int:
	return contact_damage


func is_boss() -> bool:
	return false


func _fit_collision_shapes(size: Vector2) -> void:
	var min_dim := minf(size.x, size.y)
	var body_radius := min_dim * 0.38
	var hurt_radius := min_dim * 0.42
	call_deferred("_apply_shape_radii", body_radius, hurt_radius)


func _apply_shape_radii(body_radius: float, hurt_radius: float) -> void:
	if body_shape:
		body_shape.radius = body_radius
	if hurt_shape:
		hurt_shape.radius = hurt_radius


func _notify_floating_damage(amount: int) -> void:
	var manager := get_tree().get_first_node_in_group("floating_text_manager")
	if manager and manager.has_method("show_damage"):
		manager.call_deferred("show_damage", self, amount)


func take_damage(amount: int) -> void:
	if _dying:
		return
	hp -= amount
	_notify_floating_damage(amount)
	GameAudio.play_enemy_hit()
	sprite.modulate = Color(2.2, 2.2, 2.2)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.12)
	tween.tween_property(sprite, "scale", _base_scale * 1.18, 0.06).set_trans(Tween.TRANS_BACK)
	tween.chain().tween_property(sprite, "scale", _base_scale, 0.1)
	if hp <= 0:
		_dying = true
		call_deferred("die")


func die() -> void:
	if not is_in_group("enemies"):
		return
	remove_from_group("enemies")
	hurtbox.set_deferred("monitoring", false)
	hurtbox.set_deferred("monitorable", false)
	GameEvents.notify_enemy_killed(self)
	_spawn_death_burst()
	var xp_scene := preload("res://scenes/pickups/xp_orb.tscn")
	var orb := xp_scene.instantiate()
	orb.global_position = global_position
	orb.xp_value = xp_value
	get_tree().current_scene.get_node("Entities").add_child(orb)
	set_physics_process(false)
	var fade_tween := create_tween()
	fade_tween.set_parallel(true)
	fade_tween.tween_property(sprite, "modulate:a", 0.0, 0.18)
	fade_tween.tween_property(sprite, "scale", _base_scale * 0.4, 0.18)
	fade_tween.chain().tween_callback(queue_free)


func _spawn_death_burst() -> void:
	var burst_color: Color = Color.WHITE
	if enemy_type in ENEMY_DATA:
		burst_color = ENEMY_DATA[enemy_type].color
	var parent := get_parent()
	if parent == null:
		return
	var living := get_tree().get_nodes_in_group("enemies").size()
	if living >= 40:
		return
	var particle_count := 3
	if living >= 30:
		particle_count = 1
	elif living >= 20:
		particle_count = 2
	for i in particle_count:
		var particle := ColorRect.new()
		particle.size = Vector2(4, 4)
		particle.color = burst_color.lightened(0.2)
		particle.position = global_position - particle.size * 0.5
		parent.add_child(particle)
		var angle := randf() * TAU
		var dist := randf_range(18.0, 36.0)
		var target := particle.position + Vector2.from_angle(angle) * dist
		var tween := particle.create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "position", target, 0.22).set_ease(Tween.EASE_OUT)
		tween.tween_property(particle, "modulate:a", 0.0, 0.22)
		tween.chain().tween_callback(particle.queue_free)


func _physics_process(_delta: float) -> void:
	if GameEvents.is_paused_for_upgrade:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	if not is_instance_valid(player):
		return
	var direction := (player.global_position - global_position).normalized()
	var speed: float = ENEMY_DATA.get(enemy_type, ENEMY_DATA.deadline).speed
	speed *= GameEvents.movement_slow_enemy
	velocity = direction * speed
	move_and_slide()
