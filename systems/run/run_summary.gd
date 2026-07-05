## Snapshot of run results when a session ends.
class_name RunSummary
extends Resource

@export var map_id: StringName = &""
@export var character_id: StringName = &""
@export var end_reason: StringName = &""
@export var duration_seconds: float = 0.0
@export var total_kills: int = 0
@export var total_damage_done: float = 0.0
@export var damage_taken: float = 0.0
@export var xp_collected: int = 0
@export var final_level: int = 1
## Each entry: { spell_id, display_name, level, damage }
@export var spell_powers: Array = []
## Each entry: { buff_id, display_name, stacks }
@export var buff_powers: Array = []
