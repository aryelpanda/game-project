## Spawns enemies from MapData on a ramping SpawnCurveData schedule.
class_name HordeSpawner
extends Node

@export var map_data: MapData

var _spawn_timer: float = 0.0
var _enabled: bool = false
var _elapsed_provider: Callable


func set_elapsed_provider(provider: Callable) -> void:
	_elapsed_provider = provider


func start_spawning() -> void:
	_enabled = true
	_spawn_timer = 0.0


func stop_spawning() -> void:
	_enabled = false


func _process(delta: float) -> void:
	if not _enabled or not map_data or map_data.enemy_pool.is_empty():
		return

	if not map_data.spawn_curve:
		return

	var elapsed := _get_elapsed_seconds()
	var phase := map_data.spawn_curve.get_phase_at(elapsed)
	if not phase:
		return

	if EnemyManager.active_count() >= phase.max_concurrent:
		return

	_spawn_timer += delta
	if _spawn_timer < phase.spawn_interval_seconds:
		return

	_spawn_timer = 0.0
	var enemy_data := _pick_enemy_data()
	if not enemy_data:
		return

	var spawn_position := _pick_spawn_position()
	EnemyManager.spawn(enemy_data, spawn_position)


func _get_elapsed_seconds() -> float:
	if _elapsed_provider.is_valid():
		return float(_elapsed_provider.call())
	return 0.0


func _pick_enemy_data() -> EnemyData:
	var pool := map_data.enemy_pool
	if pool.is_empty():
		return null
	return pool[randi() % pool.size()]


func _pick_spawn_position() -> Vector2:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	var center := player.global_position if player else Vector2.ZERO
	var half_extents := _get_visible_half_extents()
	var angle := randf() * TAU
	var edge_distance := _ray_distance_to_rect_edge(half_extents, angle)
	var margin := randf_range(map_data.spawn_min_distance, map_data.spawn_max_distance)
	var distance := edge_distance + margin
	return center + Vector2.from_angle(angle) * distance


func _get_visible_half_extents() -> Vector2:
	var viewport := get_viewport()
	if not viewport:
		return Vector2(640.0, 360.0)

	var viewport_size := viewport.get_visible_rect().size
	var camera := viewport.get_camera_2d()
	var zoom := camera.zoom if camera else Vector2.ONE
	return (viewport_size / zoom) * 0.5


func _ray_distance_to_rect_edge(half_extents: Vector2, angle: float) -> float:
	var direction := Vector2.from_angle(angle)
	var distance := INF

	if absf(direction.x) > 0.0001:
		distance = minf(distance, half_extents.x / absf(direction.x))
	if absf(direction.y) > 0.0001:
		distance = minf(distance, half_extents.y / absf(direction.y))

	if distance == INF:
		return 0.0
	return distance
