extends CanvasLayer

@onready var panel: PanelContainer = $Panel
@onready var title: Label = $Panel/Margin/VBox/Title
@onready var choice_container: VBoxContainer = $Panel/Margin/VBox/Choices
@onready var choice_button_scene: PackedScene = preload("res://scenes/ui/upgrade_choice_button.tscn")

var main: Node2D
var upgrade_manager: Node

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS

func show_choices(choices: Array, manager: Node) -> void:
	upgrade_manager = manager
	main = get_tree().get_first_node_in_group("main")
	title.text = "Promotion Meeting — Pick Your Upgrade"
	for child in choice_container.get_children():
		child.queue_free()
	for choice in choices:
		var button: Button = choice_button_scene.instantiate()
		choice_container.add_child(button)
		button.setup(choice, upgrade_manager.get_display_title(choice))
		button.pressed.connect(_on_choice_pressed.bind(button.upgrade_id))
	show()

func _on_choice_pressed(upgrade_id: String) -> void:
	hide()
	if main and main.has_method("on_upgrade_picked"):
		main.on_upgrade_picked(upgrade_id)
