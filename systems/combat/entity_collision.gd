## Physics layer bits and contact helpers for CharacterBody2D entities.
class_name EntityCollision
extends RefCounted

const LAYER_PLAYER := 1
const LAYER_ENEMY := 2
const MASK_PLAYER_BLOCKS_ENEMIES := LAYER_ENEMY
const MASK_ENEMY_BLOCKS_PLAYER := LAYER_PLAYER

## Extra center distance before chase resumes after contact ends (prevents glue when backing away).
const CONTACT_EXIT_PADDING := 10.0
const CONTACT_ENTER_PADDING := 0.5
const MELEE_TOUCH_TOLERANCE := 2.0
## Resolves this fraction of hull overlap per frame when the player presses into an enemy.
const PLAYER_PUSH_STRENGTH := 0.34
## Minimum nudge per frame when blocked at touch distance (no hull overlap).
const PLAYER_PUSH_CONTACT_PIXELS := 1.2
## Hard cap on enemy displacement per frame.
const PLAYER_PUSH_MAX_PIXELS := 1.6
## Input must aim at least this much toward the enemy (0–1).
const PLAYER_PUSH_AIM_DOT := 0.25


static func touch_distance(body_a: CollisionObject2D, body_b: CollisionObject2D) -> float:
	return _collision_half_extent(body_a) + _collision_half_extent(body_b)


static func center_distance(body_a: CollisionObject2D, body_b: CollisionObject2D) -> float:
	if not body_a or not body_b:
		return INF
	return body_a.global_position.distance_to(body_b.global_position)


## Hysteresis contact: once touching, stay idle until the player/enemy centers separate further.
static func is_in_contact(
	body_a: CollisionObject2D,
	body_b: CollisionObject2D,
	was_in_contact: bool
) -> bool:
	if not body_a or not body_b:
		return false

	var distance := center_distance(body_a, body_b)
	var min_distance := touch_distance(body_a, body_b)
	if was_in_contact:
		return distance <= min_distance + CONTACT_EXIT_PADDING
	return distance <= min_distance + CONTACT_ENTER_PADDING


static func is_within_touch(
	body_a: CollisionObject2D,
	body_b: CollisionObject2D,
	extra_tolerance: float = MELEE_TOUCH_TOLERANCE
) -> bool:
	if not body_a or not body_b:
		return false

	return center_distance(body_a, body_b) <= touch_distance(body_a, body_b) + extra_tolerance


static func clamp_body_to_play_area(body: CollisionObject2D, area: Rect2) -> void:
	if not body or area.size.x <= 0.0 or area.size.y <= 0.0:
		return

	var radius := _collision_half_extent(body)
	var inset := Rect2(
		area.position.x + radius,
		area.position.y + radius,
		maxf(area.size.x - radius * 2.0, 0.0),
		maxf(area.size.y - radius * 2.0, 0.0)
	)
	body.global_position = body.global_position.clamp(inset.position, inset.position + inset.size)


## Picks a spawn point along aim direction that does not skip over enemies closer than the default offset.
static func compute_projectile_spawn_position(
	player: CharacterBody2D,
	direction: Vector2,
	projectile_radius: float,
	extra_padding: float = 2.0
) -> Vector2:
	if not player:
		return Vector2.ZERO

	if direction.length_squared() < 0.0001:
		direction = Vector2.RIGHT
	direction = direction.normalized()

	var min_dist := _collision_half_extent(player) + projectile_radius + extra_padding
	var spawn_dist := min_dist + 4.0

	var tree := player.get_tree()
	if not tree:
		return player.global_position + direction * spawn_dist

	for node in tree.get_nodes_in_group("enemy"):
		var enemy := node as Node2D
		if not enemy or not enemy.visible:
			continue
		if enemy.has_method("is_dead") and enemy.is_dead():
			continue

		var to_enemy := enemy.global_position - player.global_position
		var along := to_enemy.dot(direction)
		if along <= 0.0:
			continue

		var lateral := to_enemy - direction * along
		var lateral_limit := _collision_half_extent(enemy) + projectile_radius
		if lateral.length() > lateral_limit:
			continue

		var clear_dist := along - _collision_half_extent(enemy) - projectile_radius
		spawn_dist = minf(spawn_dist, maxf(min_dist, clear_dist))

	return player.global_position + direction * spawn_dist


## Nudges enemies along the separation axis when the player presses into them.
static func apply_player_pushback(player: CharacterBody2D, move_direction: Vector2) -> void:
	if not player or move_direction.length_squared() < 0.0001:
		return

	var push_direction := move_direction.normalized()
	var pushed_ids: Array[int] = []

	for i in range(player.get_slide_collision_count()):
		var collider := player.get_slide_collision(i).get_collider()
		if collider is CharacterBody2D:
			_try_push_enemy(player, collider as CharacterBody2D, push_direction, pushed_ids)

	var tree := player.get_tree()
	if not tree:
		return

	for node in tree.get_nodes_in_group("enemy"):
		var enemy := node as CharacterBody2D
		if not enemy:
			continue
		var enemy_id := enemy.get_instance_id()
		if enemy_id in pushed_ids:
			continue
		if not _is_pushable_enemy(enemy):
			continue
		if not is_within_touch(player, enemy):
			continue
		_try_push_enemy(player, enemy, push_direction, pushed_ids)


static func _try_push_enemy(
	player: CharacterBody2D,
	enemy: CharacterBody2D,
	push_direction: Vector2,
	pushed_ids: Array[int]
) -> void:
	if not _is_pushable_enemy(enemy):
		return

	var enemy_id := enemy.get_instance_id()
	if enemy_id in pushed_ids:
		return

	var to_enemy := enemy.global_position - player.global_position
	if to_enemy.length_squared() < 0.0001:
		return

	var toward_enemy := to_enemy.normalized()
	if push_direction.dot(toward_enemy) < PLAYER_PUSH_AIM_DOT:
		return

	var distance := to_enemy.length()
	var min_distance := touch_distance(player, enemy)
	var push_amount := PLAYER_PUSH_CONTACT_PIXELS
	if distance < min_distance:
		var overlap := min_distance - distance
		push_amount = maxf(overlap * PLAYER_PUSH_STRENGTH, PLAYER_PUSH_CONTACT_PIXELS)

	push_amount = minf(push_amount, PLAYER_PUSH_MAX_PIXELS)
	enemy.global_position += toward_enemy * push_amount
	pushed_ids.append(enemy_id)


static func _is_pushable_enemy(enemy: CharacterBody2D) -> bool:
	if not enemy or not enemy.visible:
		return false
	if enemy.has_method("is_dead") and enemy.is_dead():
		return false
	if "data" in enemy and enemy.data == null:
		return false
	return true


static func collision_radius(body: CollisionObject2D) -> float:
	return _collision_half_extent(body)


static func _collision_half_extent(body: CollisionObject2D) -> float:
	var shape_node := body.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if not shape_node or not shape_node.shape:
		return 16.0

	var shape := shape_node.shape
	if shape is CircleShape2D:
		return (shape as CircleShape2D).radius
	if shape is RectangleShape2D:
		var rect := shape as RectangleShape2D
		return maxf(rect.size.x, rect.size.y) * 0.5
	if shape is CapsuleShape2D:
		var capsule := shape as CapsuleShape2D
		return capsule.radius + capsule.height * 0.5

	return 16.0
