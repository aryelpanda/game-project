## Pools and spawns generic projectiles configured with a DamageEvent payload.
## Autoload Node2D — pooled projectiles stay as children; never reparent nodes.
extends Node2D

const PROJECTILE_SCENE := preload("res://systems/projectiles/Projectile.tscn")
const DEFAULT_POOL_SIZE := 32

var _pool: Array[Projectile] = []
var _active: Array[Projectile] = []


func _ready() -> void:
	z_index = 10
	for _i in DEFAULT_POOL_SIZE:
		var projectile: Projectile = PROJECTILE_SCENE.instantiate()
		projectile.monitoring = false
		projectile.hide()
		add_child(projectile)
		_pool.append(projectile)


func spawn(
	data: ProjectileData,
	position: Vector2,
	direction: Vector2,
	payload: DamageEvent
) -> Projectile:
	if not data:
		push_warning("ProjectileManager.spawn called with null ProjectileData")
		return null

	if not payload:
		push_warning("ProjectileManager.spawn called with null DamageEvent payload")
		return null

	var projectile := _acquire_projectile()
	projectile.configure(data, position, direction, payload)
	_active.append(projectile)
	return projectile


func despawn(projectile: Projectile) -> void:
	if not projectile:
		return

	if not projectile.is_active():
		return

	if projectile in _active:
		_active.erase(projectile)

	projectile.set_deferred("monitoring", false)
	projectile.reset_for_pool()

	if projectile not in _pool:
		_pool.append(projectile)


func _acquire_projectile() -> Projectile:
	while not _pool.is_empty():
		var projectile: Projectile = _pool.pop_back()
		if not projectile.is_active() and not projectile.is_pending_despawn():
			return projectile

	var projectile: Projectile = PROJECTILE_SCENE.instantiate()
	add_child(projectile)
	return projectile
