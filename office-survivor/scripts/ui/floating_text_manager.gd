extends Node

const FloatingTextScene := preload("res://scenes/ui/floating_text.tscn")
const POOL_SIZE := 20
const MERGE_WINDOW := 0.1
const HEAL_COLOR := Color(0.22, 0.88, 0.38, 1.0)

var _pool: Array[Label] = []
var _damage_buffer: Dictionary = {}


func _ready() -> void:
	add_to_group("floating_text_manager")
	for _i in POOL_SIZE:
		var label := FloatingTextScene.instantiate() as Label
		label.hide()
		add_child(label)
		_pool.append(label)


func show_heal(world_pos: Vector2, amount: int) -> void:
	_spawn("+%d" % amount, world_pos, HEAL_COLOR)


func show_damage(enemy: Node2D, amount: int) -> void:
	if not is_instance_valid(enemy):
		return
	var id := enemy.get_instance_id()
	var now := Time.get_ticks_msec() * 0.001
	var world_pos := enemy.global_position
	if _damage_buffer.has(id):
		var entry: Dictionary = _damage_buffer[id]
		if now - float(entry.last_time) < MERGE_WINDOW:
			entry.amount = int(entry.amount) + amount
			entry.last_time = now
			entry.world_pos = world_pos
			return
		_flush_damage_entry(id)
	_damage_buffer[id] = {
		"amount": amount,
		"last_time": now,
		"world_pos": world_pos,
	}
	call_deferred("_flush_damage_after_delay", id)


func _flush_damage_after_delay(id: int) -> void:
	await get_tree().create_timer(MERGE_WINDOW).timeout
	if not _damage_buffer.has(id):
		return
	var entry: Dictionary = _damage_buffer[id]
	var now := Time.get_ticks_msec() * 0.001
	if now - float(entry.last_time) < MERGE_WINDOW - 0.005:
		call_deferred("_flush_damage_after_delay", id)
		return
	_flush_damage_entry(id)


func _flush_damage_entry(id: int) -> void:
	if not _damage_buffer.has(id):
		return
	var entry: Dictionary = _damage_buffer[id]
	_damage_buffer.erase(id)
	var amount: int = entry.amount
	var world_pos: Vector2 = entry.get("world_pos", Vector2.ZERO)
	_spawn(str(amount), world_pos, _damage_color(amount))


func _spawn(text: String, world_pos: Vector2, color: Color) -> void:
	var label := _acquire_label()
	if label == null:
		return
	var screen_pos := _world_to_canvas(world_pos)
	if label.has_method("play"):
		label.play(text, screen_pos, color, func() -> void:
			label.hide()
		)
	else:
		label.text = text
		label.modulate = color
		label.position = screen_pos
		label.show()


func _acquire_label() -> Label:
	for label in _pool:
		if not label.has_method("is_busy") or not label.is_busy():
			return label
	return null


func _world_to_canvas(world_pos: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform() * world_pos


func _damage_color(amount: int) -> Color:
	if amount >= 40:
		return Color(1.0, 0.45, 0.12, 1.0)
	return Color(0.92, 0.22, 0.24, 1.0)
