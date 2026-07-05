## Pools enemy instances for spawn and despawn during a run.
## Autoload Node2D — pooled enemies stay as children; never reparent nodes.
extends Node2D

signal enemy_killed(enemy_data: EnemyData)

const ENEMY_SCENE := preload("res://systems/enemies/Enemy.tscn")
const DEFAULT_POOL_SIZE := 16

var _pool: Array[Enemy] = []
var _active: Array[Enemy] = []

func _ready() -> void:
	z_index = 10
	for _i in DEFAULT_POOL_SIZE:
		var enemy: Enemy = ENEMY_SCENE.instantiate()
		enemy.enemy_died.connect(_on_enemy_died)
		add_child(enemy)
		enemy.reset_for_pool()
		_pool.append(enemy)


func spawn(data: EnemyData, position: Vector2) -> Enemy:
	if not data:
		push_warning("EnemyManager.spawn called with null EnemyData")
		return null

	if not data.validate():
		return null

	var enemy := _acquire_enemy()
	enemy.initialize(data, position)
	_active.append(enemy)
	return enemy


func despawn(enemy: Enemy) -> void:
	if not enemy or enemy.data == null:
		return

	if enemy in _active:
		_active.erase(enemy)

	enemy.reset_for_pool()

	if enemy not in _pool:
		_pool.append(enemy)


func active_count() -> int:
	return _active.size()


func despawn_all_active() -> void:
	var snapshot := _active.duplicate()
	for enemy in snapshot:
		if enemy.data != null:
			enemy.reset_for_pool()
		if enemy in _active:
			_active.erase(enemy)
		if enemy not in _pool:
			_pool.append(enemy)


func _acquire_enemy() -> Enemy:
	while not _pool.is_empty():
		var enemy: Enemy = _pool.pop_back()
		if enemy.data == null:
			return enemy

	var enemy: Enemy = ENEMY_SCENE.instantiate()
	enemy.enemy_died.connect(_on_enemy_died)
	add_child(enemy)
	enemy.reset_for_pool()
	return enemy


func _on_enemy_died(enemy: Enemy) -> void:
	if enemy and enemy.data:
		enemy_killed.emit(enemy.data)
