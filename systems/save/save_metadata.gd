## Serializable metadata describing a save slot for Save Slot Select UI.
class_name SaveMetadata
extends Resource

@export var slot: int = -1
@export var character_name: String = ""
@export var created_at: int = 0
@export var last_played_at: int = 0
@export var total_play_seconds: float = 0.0
@export var highest_unlocked_map: StringName = &""
@export var unlocked_maps: Array[StringName] = []
@export var has_active_run: bool = false
@export var active_run_map: StringName = &""
@export var active_run_elapsed_seconds: float = 0.0
@export var active_run_level: int = 1
@export var run_count: int = 0


func is_empty() -> bool:
	return character_name.is_empty()


func to_dict() -> Dictionary:
	return {
		"version": 1,
		"slot": slot,
		"character_name": character_name,
		"created_at": created_at,
		"last_played_at": last_played_at,
		"total_play_seconds": total_play_seconds,
		"highest_unlocked_map": String(highest_unlocked_map),
		"unlocked_maps": unlocked_maps.map(func(id: StringName) -> String: return String(id)),
		"run_count": run_count,
	}


func from_dict(data: Dictionary) -> void:
	slot = int(data.get("slot", slot))
	character_name = String(data.get("character_name", ""))
	created_at = int(data.get("created_at", 0))
	last_played_at = int(data.get("last_played_at", 0))
	total_play_seconds = float(data.get("total_play_seconds", 0.0))
	highest_unlocked_map = StringName(String(data.get("highest_unlocked_map", "")))
	unlocked_maps.clear()
	for id in data.get("unlocked_maps", []):
		unlocked_maps.append(StringName(String(id)))
	run_count = int(data.get("run_count", 0))
