extends Button

const SpriteFactory = preload("res://scripts/visual/sprite_factory.gd")

var upgrade_id: String = ""

@onready var _icon_rect: TextureRect = $Content/HBox/IconRect
@onready var _title_label: Label = $Content/HBox/VBox/TitleLabel
@onready var _desc_label: Label = $Content/HBox/VBox/DescLabel


func setup(choice: Dictionary, display_title: String) -> void:
	upgrade_id = choice.get("id", "")
	_title_label.text = display_title
	_desc_label.text = choice.get("description", "")
	_apply_icon(choice)


func _apply_icon(choice: Dictionary) -> void:
	var icon_id: String = str(choice.get("weapon_id", choice.get("id", "")))
	if icon_id == "":
		icon_id = upgrade_id
	if icon_id != "" and SpriteFactory.UPGRADE_ICON_ROWS.has(icon_id):
		_icon_rect.texture = SpriteFactory.get_upgrade_icon(icon_id)
		_icon_rect.modulate = Color.WHITE
	else:
		_icon_rect.texture = null
		_icon_rect.modulate = Color(0, 0, 0, 0)
