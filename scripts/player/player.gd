extends CharacterBody2D
class_name Player

const SpriteFactory = preload("res://scripts/visual/sprite_factory.gd")

const BASE_SPEED := 220.0
const BASE_MAX_HP := 100
const INVINCIBILITY_TIME := 0.8
const XP_TO_LEVEL_BASE := 8
const XP_LEVEL_SCALE := 1.25

@onready var weapon_manager: Node2D = $WeaponManager
@onready var hurt_area: Area2D = $HurtArea
@onready var sprite: Sprite2D = $Sprite
@onready var collision: CollisionShape2D = $CollisionShape2D

var max_hp: int = BASE_MAX_HP
var hp: int = BASE_MAX_HP
var level: int = 1
var xp: int = 0
var xp_to_next: int = XP_TO_LEVEL_BASE
var invincible_timer: float = 0.0
var dead: bool = false

func _ready() -> void:
	add_to_group("player")
	_apply_sprite()
	reset_stats()
	hurt_area.area_entered.connect(_on_hurt_area_entered)


func _apply_sprite() -> void:
	var tex := SpriteFactory.get_player_texture()
	sprite.texture = tex
	sprite.centered = false
	var size := Vector2(32, 32)
	var tex_size := tex.get_size()
	if tex_size.x > 0.0:
		sprite.scale = size / tex_size
	sprite.position = -size * 0.5

func reset_stats() -> void:
	dead = false
	level = 1
	xp = 0
	xp_to_next = XP_TO_LEVEL_BASE
	invincible_timer = 0.0
	_recalc_max_hp()
	hp = max_hp
	modulate = Color.WHITE

func _recalc_max_hp() -> void:
	var upgrade_manager := get_node_or_null("/root/Main/UpgradeManager")
	var bonus := 0
	if upgrade_manager:
		bonus = upgrade_manager.get_bonus_max_hp()
	max_hp = BASE_MAX_HP + bonus
	hp = mini(hp, max_hp)

func _physics_process(delta: float) -> void:
	if dead or GameEvents.is_paused_for_upgrade:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	invincible_timer = maxf(0.0, invincible_timer - delta)
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var speed_mult := 1.0
	var upgrade_manager := get_node_or_null("/root/Main/UpgradeManager")
	if upgrade_manager:
		speed_mult = upgrade_manager.get_speed_multiplier()
	velocity = input_dir * BASE_SPEED * speed_mult * GameEvents.movement_slow_player
	move_and_slide()

	if invincible_timer > 0.0:
		sprite.modulate = Color(1, 1, 1, 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.02))
	else:
		sprite.modulate = Color.WHITE

func take_damage(amount: int) -> void:
	if dead or invincible_timer > 0.0:
		return
	hp -= amount
	invincible_timer = INVINCIBILITY_TIME
	if hp <= 0:
		die()

func die() -> void:
	if dead:
		return
	dead = true
	GameEvents.notify_player_died()

func collect_xp(amount: int) -> void:
	if dead:
		return
	xp += amount
	while xp >= xp_to_next:
		xp -= xp_to_next
		level += 1
		xp_to_next = int(round(XP_TO_LEVEL_BASE * pow(XP_LEVEL_SCALE, level - 1)))
		GameEvents.notify_player_leveled_up(level)

func heal(amount: int) -> void:
	hp = mini(hp + amount, max_hp)

func get_damage_multiplier() -> float:
	var upgrade_manager := get_node_or_null("/root/Main/UpgradeManager")
	if upgrade_manager:
		return upgrade_manager.get_damage_multiplier()
	return 1.0

func apply_passive_upgrades() -> void:
	_recalc_max_hp()

func _on_hurt_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_hurtbox"):
		var enemy := area.get_parent()
		if enemy and enemy.has_method("get_contact_damage"):
			var damage: int = enemy.get_contact_damage()
			call_deferred("_apply_contact_damage", damage)


func _apply_contact_damage(amount: int) -> void:
	take_damage(amount)
