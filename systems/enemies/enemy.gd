## Hostile entity with data-driven stats and at least one SpellData skill.
class_name Enemy
extends CharacterBody2D

signal enemy_died(enemy: Enemy)

@export var data: EnemyData

var stats: StatsBlock

var _current_health: float = 0.0
var _max_health: float = 0.0
var _is_dead: bool = false
var _pending_despawn: bool = false
var _skill_cooldowns: Dictionary = {}
var _health_bar: Control
var _in_contact: bool = false


func _ready() -> void:
	add_to_group("enemy")
	_health_bar = get_node_or_null("HealthBar")

	if data:
		initialize(data, global_position)


func initialize(enemy_data: EnemyData, spawn_position: Vector2) -> void:
	data = enemy_data

	if not data.validate():
		return

	stats = StatsBlock.new()
	stats.setup_from_data(data.stats)

	_max_health = stats.get_stat(&"max_health")
	_current_health = _max_health
	global_position = spawn_position
	_is_dead = false
	_pending_despawn = false
	_skill_cooldowns.clear()
	_in_contact = false
	motion_mode = MOTION_MODE_FLOATING
	collision_layer = EntityCollision.LAYER_ENEMY
	collision_mask = EntityCollision.MASK_ENEMY_BLOCKS_PLAYER
	show()
	_update_health_bar()

	print(
		"[Enemy] %s spawned. Health: %.0f / %.0f" % [data.display_name, _current_health, _max_health]
	)


func _physics_process(_delta: float) -> void:
	if _is_dead or not data:
		return

	var player := _find_player()
	if not player:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var to_player := player.global_position - global_position
	var distance := to_player.length()
	var min_distance := EntityCollision.touch_distance(self, player)

	_in_contact = EntityCollision.is_in_contact(self, player, _in_contact)

	if _in_contact:
		velocity = Vector2.ZERO
	elif distance > min_distance + EntityCollision.CONTACT_ENTER_PADDING:
		velocity = to_player.normalized() * stats.get_stat(&"move_speed")
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	if EntityCollision.is_within_touch(self, player):
		for skill in data.skills:
			if skill and not skill.projectile_data:
				try_use_skill(skill.id)
				break


func take_damage(damage_event: DamageEvent) -> void:
	if _is_dead or not data:
		return

	var amount := damage_event.base_damage
	_current_health -= amount
	_update_health_bar()

	print(
		"[Enemy] %s took %.0f damage. Health: %.0f / %.0f"
		% [data.display_name, amount, _current_health, _max_health]
	)

	if _current_health <= 0.0:
		kill()


func kill() -> void:
	if _is_dead or not data or _pending_despawn:
		return

	_is_dead = true
	_pending_despawn = true
	print("[Enemy] %s died" % data.display_name)
	enemy_died.emit(self)
	EnemyManager.call_deferred("despawn", self)


func try_use_skill(skill_id: StringName) -> bool:
	if not data:
		return false

	var skill := _find_skill(skill_id)
	if not skill:
		push_warning("Enemy '%s' has no skill '%s'" % [data.id, skill_id])
		return false

	var now := Time.get_ticks_msec() / 1000.0
	if _skill_cooldowns.get(skill_id, 0.0) > now:
		return false

	_skill_cooldowns[skill_id] = now + skill.cooldown
	_execute_skill(skill)
	return true


func get_stats() -> StatsBlock:
	return stats


func is_dead() -> bool:
	return _is_dead


func reset_for_pool() -> void:
	_is_dead = true
	_pending_despawn = false
	velocity = Vector2.ZERO
	_skill_cooldowns.clear()
	_in_contact = false
	data = null
	stats = null
	collision_layer = 0
	collision_mask = 0
	hide()


func _execute_skill(skill: SpellData) -> void:
	var player := _find_player()
	if not player:
		return

	if skill.projectile_data:
		var payload := DamageEvent.new()
		payload.source = self
		payload.base_damage = skill.base_damage
		payload.damage_type = skill.damage_type
		payload.spell_id = skill.id
		var direction: Vector2 = (player.global_position - global_position).normalized()
		ProjectileManager.spawn(skill.projectile_data, global_position, direction, payload)
		return

	var payload := DamageEvent.new()
	payload.source = self
	payload.target = player
	payload.base_damage = skill.base_damage
	payload.damage_type = skill.damage_type
	payload.spell_id = skill.id
	DamageManager.apply(payload)


func _find_skill(skill_id: StringName) -> SpellData:
	if not data:
		return null

	for skill in data.skills:
		if skill and skill.id == skill_id:
			return skill
	return null


func _find_player() -> Node2D:
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return null
	return players[0] as Node2D


func _update_health_bar() -> void:
	if _health_bar and _health_bar.has_method("update_values"):
		_health_bar.update_values(_current_health, _max_health)
