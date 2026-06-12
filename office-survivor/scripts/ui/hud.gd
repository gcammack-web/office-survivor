extends CanvasLayer

@onready var timer_label: Label = $Margin/VBox/TimerLabel
@onready var level_label: Label = $Margin/VBox/LevelLabel
@onready var hp_label: Label = $Margin/VBox/HpPanel/HpMargin/HpVBox/HpLabel
@onready var hp_bar: ProgressBar = $Margin/VBox/HpPanel/HpMargin/HpVBox/HpBar
@onready var xp_bar: ProgressBar = $Margin/VBox/XpBar
@onready var weapon_label: Label = $Margin/VBox/WeaponLabel
@onready var milestone_label: Label = $Margin/VBox/MilestoneLabel
@onready var announcement_panel: PanelContainer = $AnnouncementPanel
@onready var announcement_title: Label = $AnnouncementPanel/Margin/VBox/Title
@onready var announcement_subtitle: Label = $AnnouncementPanel/Margin/VBox/Subtitle
@onready var flash_overlay: ColorRect = $FlashOverlay

var player: CharacterBody2D
var _hp_fill_style: StyleBoxFlat
var _run_event_manager: Node


func _ready() -> void:
	add_to_group("hud")
	hide()
	announcement_panel.hide()
	flash_overlay.modulate.a = 0.0
	_hp_fill_style = hp_bar.get_theme_stylebox("fill").duplicate() as StyleBoxFlat
	hp_bar.add_theme_stylebox_override("fill", _hp_fill_style)
	call_deferred("_bind_player")


func _bind_player() -> void:
	player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	_run_event_manager = get_tree().get_first_node_in_group("main") as Node2D
	if _run_event_manager:
		_run_event_manager = _run_event_manager.get_node_or_null("RunEventManager")
	if player:
		set_process(true)


func _process(_delta: float) -> void:
	if not is_instance_valid(player):
		return
	_update_hp_display(player.hp, player.max_hp)
	xp_bar.max_value = player.xp_to_next
	xp_bar.value = player.xp
	level_label.text = "Level %d" % player.level
	_update_milestone_label()


func _update_hp_display(current: int, maximum: int) -> void:
	hp_bar.max_value = maximum
	hp_bar.value = current
	hp_label.text = "HP: %d/%d" % [current, maximum]
	var ratio := 0.0 if maximum <= 0 else float(current) / float(maximum)
	_hp_fill_style.bg_color = _health_color(ratio)


func _health_color(ratio: float) -> Color:
	var green := Color(0.22, 0.88, 0.38, 1.0)
	var yellow := Color(0.95, 0.82, 0.12, 1.0)
	var red := Color(0.92, 0.22, 0.24, 1.0)
	ratio = clampf(ratio, 0.0, 1.0)
	if ratio >= 0.5:
		return green.lerp(yellow, (1.0 - ratio) * 2.0)
	return yellow.lerp(red, (0.5 - ratio) * 2.0)


func update_run_time(seconds: float) -> void:
	var mins := int(seconds) / 60
	var secs := int(seconds) % 60
	timer_label.text = "%02d:%02d" % [mins, secs]
	_update_milestone_label()


func _update_milestone_label() -> void:
	if not is_instance_valid(_run_event_manager):
		return
	if not _run_event_manager.has_method("get_next_milestone"):
		return
	if not is_instance_valid(player):
		return
	milestone_label.text = _run_event_manager.get_next_milestone(player.level, GameEvents.run_time)


func set_weapon_text(text: String) -> void:
	weapon_label.text = text


func show_announcement(title: String, subtitle: String, duration: float = 3.5) -> void:
	announcement_title.text = title
	announcement_subtitle.text = subtitle
	announcement_panel.modulate.a = 1.0
	announcement_panel.show()
	var tween := create_tween()
	tween.tween_interval(duration * 0.65)
	tween.tween_property(announcement_panel, "modulate:a", 0.0, duration * 0.35)
	tween.tween_callback(announcement_panel.hide)


func flash_screen(color: Color, duration: float) -> void:
	flash_overlay.color = color
	flash_overlay.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_property(flash_overlay, "modulate:a", 0.0, duration).set_ease(Tween.EASE_OUT)
