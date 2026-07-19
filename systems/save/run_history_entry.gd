## Immutable record of one completed or forfeited run, stored per profile.
class_name RunHistoryEntry
extends Resource

@export var started_at: int = 0
@export var ended_at: int = 0
@export var map_id: StringName = &""
@export var character_id: StringName = &""
@export var end_reason: StringName = &""
@export var duration_seconds: float = 0.0
@export var final_level: int = 1
@export var total_kills: int = 0
@export var total_damage_done: float = 0.0
@export var damage_taken: float = 0.0
@export var xp_collected: int = 0
## Entries: { spell_id: String, display_name: String, level: int, damage: float }
@export var spell_powers: Array = []
## Entries: { buff_id: String, display_name: String, stacks: int }
@export var buff_powers: Array = []


func to_dict() -> Dictionary:
	return {
		"version": 1,
		"started_at": started_at,
		"ended_at": ended_at,
		"map_id": String(map_id),
		"character_id": String(character_id),
		"end_reason": String(end_reason),
		"duration_seconds": duration_seconds,
		"final_level": final_level,
		"total_kills": total_kills,
		"total_damage_done": total_damage_done,
		"damage_taken": damage_taken,
		"xp_collected": xp_collected,
		"spell_powers": spell_powers,
		"buff_powers": buff_powers,
	}


func from_dict(data: Dictionary) -> void:
	started_at = int(data.get("started_at", 0))
	ended_at = int(data.get("ended_at", 0))
	map_id = StringName(String(data.get("map_id", "")))
	character_id = StringName(String(data.get("character_id", "")))
	end_reason = StringName(String(data.get("end_reason", "")))
	duration_seconds = float(data.get("duration_seconds", 0.0))
	final_level = int(data.get("final_level", 1))
	total_kills = int(data.get("total_kills", 0))
	total_damage_done = float(data.get("total_damage_done", 0.0))
	damage_taken = float(data.get("damage_taken", 0.0))
	xp_collected = int(data.get("xp_collected", 0))
	spell_powers = data.get("spell_powers", [])
	buff_powers = data.get("buff_powers", [])


func top_spell_name() -> String:
	var best: Dictionary = {}
	var best_damage := -1.0
	for entry in spell_powers:
		if not entry is Dictionary:
			continue
		var dmg := float(entry.get("damage", 0.0))
		if dmg > best_damage:
			best_damage = dmg
			best = entry
	return String(best.get("display_name", "-"))
