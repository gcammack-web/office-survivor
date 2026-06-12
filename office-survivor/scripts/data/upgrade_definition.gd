class_name UpgradeDefinition
extends Resource

@export var id: String
@export var title: String
@export_multiline var description: String
@export var category: String = "weapon"  # weapon | passive
@export var weapon_id: String = ""
@export var max_level: int = 5
@export var weight: float = 1.0
