## Loads map scenes and exposes MapData for spawners and Run.
extends Node

signal map_loaded(map_id: StringName)
signal map_unloaded(map_id: StringName)

const MAPS_DIR := "res://content/maps/"

var _current_map_id: StringName = &""
var _current_map_data: MapData


func load_map(map_id: StringName, _spawn_point: StringName = &"default") -> void:
	var map_data := _load_map_data(map_id)
	if not map_data:
		push_error("World.load_map: unknown map '%s'" % map_id)
		return

	if not map_data.scene:
		push_error("World.load_map: map '%s' has no scene" % map_id)
		return

	if _current_map_id != &"" and _current_map_id != map_id:
		map_unloaded.emit(_current_map_id)

	_current_map_id = map_id
	_current_map_data = map_data

	var scene_path := map_data.scene.resource_path
	get_tree().call_deferred("change_scene_to_file", scene_path)


func current_map() -> StringName:
	return _current_map_id


func get_current_map_data() -> MapData:
	return _current_map_data


func get_spawn_curve() -> SpawnCurveData:
	if _current_map_data:
		return _current_map_data.spawn_curve
	return null


func get_enemy_pool() -> Array[EnemyData]:
	if _current_map_data:
		return _current_map_data.enemy_pool
	return []


func notify_map_ready() -> void:
	if _current_map_id != &"":
		map_loaded.emit(_current_map_id)


func _load_map_data(map_id: StringName) -> MapData:
	var path := "%s%s.tres" % [MAPS_DIR, map_id]
	if not ResourceLoader.exists(path):
		push_error("World: MapData not found at %s" % path)
		return null

	var resource := load(path)
	if resource is MapData:
		return resource

	push_error("World: resource at %s is not MapData" % path)
	return null
