## Generic pooled projectile. Damage comes from the DamageEvent payload at spawn time.
class_name Projectile
extends Area2D

var _data: ProjectileData
var _direction: Vector2 = Vector2.RIGHT
var _payload: DamageEvent
var _source: Node
var _time_alive: float = 0.0
var _hits_remaining: int = 0
var _pending_despawn: bool = false
var _hit_instance_ids: Array[int] = []


func is_active() -> bool:
	return _data != null


func is_pending_despawn() -> bool:
	return _pending_despawn


func configure(
	data: ProjectileData,
	position: Vector2,
	direction: Vector2,
	payload: DamageEvent
) -> void:
	_data = data
	_direction = direction.normalized()
	if _direction.length_squared() < 0.0001:
		_direction = Vector2.RIGHT

	_source = payload.source
	_payload = payload.duplicate()
	global_position = position
	_time_alive = 0.0
	_hits_remaining = maxi(data.pierce_count, 0) + 1
	_pending_despawn = false
	_hit_instance_ids.clear()
	collision_mask = data.collision_mask
	monitoring = false
	call_deferred("_finish_spawn_setup")
	show()


func _finish_spawn_setup() -> void:
	if not _data:
		return

	monitoring = true
	_check_overlapping_hits()
	_sweep_for_hits(_direction * _data.speed * (1.0 / 60.0))


func _physics_process(delta: float) -> void:
	if not _data:
		return

	var motion := _direction * _data.speed * delta
	_sweep_for_hits(motion)
	global_position += motion
	_time_alive += delta

	if _time_alive >= _data.lifetime:
		_request_despawn()


func _on_body_entered(body: Node2D) -> void:
	_try_hit_body(body)


func _check_overlapping_hits() -> void:
	for body in get_overlapping_bodies():
		_try_hit_body(body)


func _sweep_for_hits(motion: Vector2) -> void:
	if motion.length_squared() < 0.0001 or not _data:
		return

	var collision_shape := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if not collision_shape or not collision_shape.shape:
		return

	var params := PhysicsShapeQueryParameters2D.new()
	params.shape = collision_shape.shape
	params.transform = global_transform
	params.motion = motion
	params.collision_mask = collision_mask
	params.collide_with_bodies = true
	params.collide_with_areas = false
	if _source is CollisionObject2D:
		params.exclude = [(_source as CollisionObject2D).get_rid()]

	var space := get_world_2d().direct_space_state
	var fractions := space.cast_motion(params)
	if fractions.is_empty():
		return

	var unsafe_fraction: float = fractions[1]
	params.transform = global_transform.translated(motion * unsafe_fraction)
	for result in space.intersect_shape(params):
		var collider = result.get("collider")
		if collider is Node2D:
			_try_hit_body(collider as Node2D)


func _try_hit_body(body: Node2D) -> void:
	if not _data or _pending_despawn or not body:
		return

	if body == _source:
		return

	var body_id := body.get_instance_id()
	if body_id in _hit_instance_ids:
		return

	if not body.has_method("take_damage"):
		return

	if body.has_method("is_dead") and body.is_dead():
		return

	_hit_instance_ids.append(body_id)

	var delivery := _payload.duplicate()
	delivery.source = _source
	delivery.target = body
	DamageManager.apply(delivery)

	_hits_remaining -= 1
	if _hits_remaining <= 0:
		_request_despawn()


func _request_despawn() -> void:
	if _pending_despawn:
		return

	_pending_despawn = true
	set_deferred("monitoring", false)
	ProjectileManager.call_deferred("despawn", self)


func reset_for_pool() -> void:
	_data = null
	_payload = null
	_source = null
	_direction = Vector2.RIGHT
	_time_alive = 0.0
	_hits_remaining = 0
	_pending_despawn = false
	_hit_instance_ids.clear()
	set_deferred("monitoring", false)
	hide()
