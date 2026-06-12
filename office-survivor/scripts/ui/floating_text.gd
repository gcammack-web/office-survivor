extends Label

const DURATION := 0.8
const FLOAT_DISTANCE := 42.0

var _busy: bool = false


func is_busy() -> bool:
	return _busy


func play(text: String, screen_pos: Vector2, color: Color, on_finished: Callable) -> void:
	_busy = true
	self.text = text
	modulate = color
	modulate.a = 1.0
	position = screen_pos + Vector2(randf_range(-8.0, 8.0), randf_range(-4.0, 4.0))
	show()
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y - FLOAT_DISTANCE, DURATION).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, DURATION).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(func() -> void:
		hide()
		_busy = false
		if on_finished.is_valid():
			on_finished.call()
	)
