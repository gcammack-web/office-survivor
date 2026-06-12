extends Area2D

const SpriteFactory = preload("res://scripts/visual/sprite_factory.gd")
const HEAL_AMOUNT := 30
const COLLECT_RADIUS := 20.0

var player: Node2D
var collected: bool = false
var _pulse_time: float = 0.0

@onready var _sprite: Sprite2D = $Sprite


func _ready() -> void:
	add_to_group("donut_pickup")
	player = get_tree().get_first_node_in_group("player")
	body_entered.connect(_on_body_entered)
	_apply_visual()


func _apply_visual() -> void:
	var tex := SpriteFactory.get_donut_texture()
	_sprite.texture = tex
	_sprite.centered = true
	var tex_size := tex.get_size()
	if tex_size.x > 0.0:
		# Scale to the visible 10×10 ring, not the full padded texture.
		const CONTENT_GRID := Vector2(10.0, 10.0)
		const PIXEL_SCALE := 3.0
		const TARGET_DIAMETER := 20.0
		var content_px := CONTENT_GRID * PIXEL_SCALE
		var uniform := TARGET_DIAMETER / maxf(content_px.x, content_px.y)
		_sprite.scale = Vector2(uniform, uniform * 1.06)


func _physics_process(delta: float) -> void:
	if collected or GameEvents.is_paused_for_upgrade:
		return
	_pulse_time += delta
	var pulse := 0.9 + 0.1 * sin(_pulse_time * 5.0)
	_sprite.modulate = Color(1.0, pulse, pulse * 0.85)
	if not is_instance_valid(player):
		return
	var dist := global_position.distance_to(player.global_position)
	if dist <= COLLECT_RADIUS:
		call_deferred("_collect")


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		call_deferred("_collect")


func _collect() -> void:
	if collected:
		return
	collected = true
	GameAudio.play_donut_pickup()
	if player and player.has_method("heal"):
		player.heal(HEAL_AMOUNT)
		var manager := get_tree().get_first_node_in_group("floating_text_manager")
		if manager and manager.has_method("show_heal"):
			manager.call_deferred("show_heal", player.global_position, HEAL_AMOUNT)
	queue_free()
