## Static enemy definition loaded from content/enemies/*.tres.
class_name EnemyData
extends Resource

@export var id: StringName
@export var display_name: String = ""
@export var stats: StatsData
@export var skills: Array[SpellData] = []
@export var xp_reward: int = 0


func validate() -> bool:
	if skills.is_empty():
		push_error("EnemyData '%s' must define at least one skill" % id)
		return false

	if not stats:
		push_error("EnemyData '%s' must define stats" % id)
		return false

	return true
