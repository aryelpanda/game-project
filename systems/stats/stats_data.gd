## Base stat values for an entity, loaded from content/stats/*.tres.
class_name StatsData
extends Resource

@export var id: StringName
@export var values: Dictionary = {}


func get_value(stat: StringName, default_value: float = 0.0) -> float:
	return float(values.get(stat, default_value))
