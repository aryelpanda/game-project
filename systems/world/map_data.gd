## Arena map metadata: scene, enemy pool, spawn curve, and spawn ring tuning.
class_name MapData
extends Resource

@export var id: StringName = &""
@export var display_name: String = ""
@export var scene: PackedScene
@export var enemy_pool: Array[EnemyData] = []
@export var spawn_curve: SpawnCurveData
@export var spawn_min_distance: float = 32.0 ## Min extra distance beyond the visible viewport edge.
@export var spawn_max_distance: float = 96.0 ## Max extra distance beyond the visible viewport edge.
@export var play_area_rect: Rect2 = Rect2(-1000.0, -1000.0, 2000.0, 2000.0) ## World-space bounds; player hull must stay inside.
@export var run_duration_seconds: float = 0.0 ## Run ends with time_up when elapsed >= this. 0 = no time limit.
