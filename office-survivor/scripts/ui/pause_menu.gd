extends CanvasLayer

signal resume_requested
signal restart_requested
signal quit_to_title_requested

@onready var resume_button: Button = $Panel/Margin/VBox/ResumeButton
@onready var restart_button: Button = $Panel/Margin/VBox/RestartButton
@onready var quit_button: Button = $Panel/Margin/VBox/QuitButton


func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)


func show_menu() -> void:
	show()
	resume_button.grab_focus()


func hide_menu() -> void:
	hide()


func _on_resume_pressed() -> void:
	resume_requested.emit()


func _on_restart_pressed() -> void:
	restart_requested.emit()


func _on_quit_pressed() -> void:
	quit_to_title_requested.emit()
