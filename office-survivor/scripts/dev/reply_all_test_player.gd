extends Node2D

var upgrade_manager: Node

func get_damage_multiplier() -> float:
	if upgrade_manager and upgrade_manager.has_method("get_damage_multiplier"):
		return upgrade_manager.get_damage_multiplier()
	return 1.0
