extends Node

var enemies_killed: int = 0
var bosses_defeated: int = 0
var peak_level: int = 1


func _ready() -> void:
	GameEvents.enemy_killed.connect(_on_enemy_killed)
	GameEvents.player_leveled_up.connect(_on_player_leveled_up)
	GameEvents.run_started.connect(reset)


func reset() -> void:
	enemies_killed = 0
	bosses_defeated = 0
	peak_level = 1


func _on_enemy_killed(enemy: Node2D) -> void:
	enemies_killed += 1
	if enemy.has_method("is_boss") and enemy.is_boss():
		bosses_defeated += 1


func _on_player_leveled_up(level: int) -> void:
	peak_level = maxi(peak_level, level)


func snapshot(final_level: int) -> Dictionary:
	return {
		"enemies_killed": enemies_killed,
		"bosses_defeated": bosses_defeated,
		"peak_level": maxi(peak_level, final_level),
	}
