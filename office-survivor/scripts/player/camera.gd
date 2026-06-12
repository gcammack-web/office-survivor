extends Camera2D

var _shake_strength: float = 0.0
var _shake_timer: float = 0.0


func _ready() -> void:
	make_current()
	GameEvents.player_leveled_up.connect(_on_player_leveled_up)


func _on_player_leveled_up(_level: int) -> void:
	shake(10.0, 0.35)


func shake(strength: float, duration: float) -> void:
	_shake_strength = strength
	_shake_timer = duration


func _process(delta: float) -> void:
	if _shake_timer > 0.0:
		_shake_timer -= delta
		offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * _shake_strength
	elif offset != Vector2.ZERO:
		offset = Vector2.ZERO
