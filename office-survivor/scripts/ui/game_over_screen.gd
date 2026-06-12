extends CanvasLayer

@onready var time_label: Label = $Panel/Margin/VBox/TimeLabel
@onready var stats_label: Label = $Panel/Margin/VBox/StatsLabel
@onready var retry_button: Button = $Panel/Margin/VBox/RetryButton

var main: Node2D


func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	retry_button.pressed.connect(_on_retry_pressed)


func show_screen(survived_seconds: float, main_node: Node2D, stats: Dictionary = {}) -> void:
	main = main_node
	var mins := int(survived_seconds) / 60
	var secs := int(survived_seconds) % 60
	time_label.text = "You survived %02d:%02d before burnout." % [mins, secs]
	stats_label.text = _format_stats(stats)
	show()


func _format_stats(stats: Dictionary) -> String:
	var peak_level: int = stats.get("peak_level", 1)
	var enemies_killed: int = stats.get("enemies_killed", 0)
	var bosses_defeated: int = stats.get("bosses_defeated", 0)
	var best_weapon: String = stats.get("best_weapon", "Stapler")
	return "Level %d  |  %d enemies cleared  |  %d bosses defeated\nBest weapon: %s" % [
		peak_level,
		enemies_killed,
		bosses_defeated,
		best_weapon,
	]


func _on_retry_pressed() -> void:
	hide()
	if main and main.has_method("restart_run"):
		main.restart_run()
