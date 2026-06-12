extends CanvasLayer

@onready var start_button: Button = $Panel/Margin/VBox/StartButton
@onready var subtitle: Label = $Panel/Margin/VBox/Subtitle

var main: Node2D

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	start_button.pressed.connect(_on_start_pressed)

func show_screen(main_node: Node2D) -> void:
	main = main_node
	subtitle.text = "Survive the workday. Upgrade with staplers, coffee, and passive-aggressive emails."
	GameAudio.stop_music()
	show()

func hide_screen() -> void:
	hide()

func _on_start_pressed() -> void:
	hide()
	if main and main.has_method("start_run"):
		main.start_run()
