## Top-down player character. M2: movement, StatsBlock, and left-click basic fireball cast.
extends CharacterBody2D

signal player_damaged(amount: float)
signal player_died()
signal player_leveled_up(new_level: int)
signal mana_changed(current_mana: float, max_mana: float)
signal health_changed(current_health: float, max_health: float)

@export var stats_data: StatsData
@export var basic_spell: SpellData

var stats: StatsBlock
var buff_container: BuffContainer
var run_spells: RunSpellController

var max_health: float
var current_health: float
var max_mana: float
var current_mana: float

var _cast_cooldown_until: float = 0.0
var _health_bar: Control


func _ready() -> void:
	add_to_group("player")
	motion_mode = MOTION_MODE_FLOATING

	stats = StatsBlock.new()
	if stats_data:
		stats.setup_from_data(stats_data)

	buff_container = BuffContainer.new()
	buff_container.setup(stats)

	run_spells = get_node_or_null("RunSpellController") as RunSpellController
	if run_spells:
		run_spells.setup(self)

	max_health = stats.get_stat(&"max_health")
	current_health = max_health
	max_mana = stats.get_stat(&"max_mana")
	current_mana = max_mana

	_health_bar = get_node_or_null("HealthBar")
	_update_health_bar()

	health_changed.emit(current_health, max_health)
	mana_changed.emit(current_mana, max_mana)

	print("[Player] Health: %.0f / %.0f" % [current_health, max_health])
	print("[Player] Mana: %.0f / %.0f" % [current_mana, max_mana])


func _physics_process(_delta: float) -> void:
	if current_health <= 0.0:
		return

	var input_vector := Input.get_vector(
		&"move_left", &"move_right", &"move_up", &"move_down"
	)
	velocity = input_vector * stats.get_stat(&"move_speed")
	move_and_slide()
	EntityCollision.apply_player_pushback(self, input_vector)
	_apply_play_area_constraints()


func _apply_play_area_constraints() -> void:
	var map_data := World.get_current_map_data()
	if map_data:
		EntityCollision.clamp_body_to_play_area(self, map_data.play_area_rect)


func _input(event: InputEvent) -> void:
	if current_health <= 0.0:
		return

	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			_try_cast_basic_spell()


func _try_cast_basic_spell() -> void:
	if not basic_spell or not basic_spell.projectile_data:
		push_warning("Player has no basic_spell with projectile_data configured")
		return

	var now := Time.get_ticks_msec() / 1000.0
	if _cast_cooldown_until > now:
		return

	if basic_spell.mana_cost > 0.0 and not spend_mana(basic_spell.mana_cost):
		return

	_cast_cooldown_until = now + basic_spell.cooldown

	var mouse_position := get_global_mouse_position()
	var direction: Vector2 = (mouse_position - global_position).normalized()
	if direction.length_squared() < 0.0001:
		direction = Vector2.RIGHT

	var projectile_data := basic_spell.projectile_data
	var spawn_position := EntityCollision.compute_projectile_spawn_position(
		self, direction, projectile_data.radius
	)

	var payload := DamageEvent.new()
	payload.source = self
	payload.base_damage = _compute_manual_attack_damage()
	payload.damage_type = basic_spell.damage_type
	payload.spell_id = basic_spell.id

	ProjectileManager.spawn(
		basic_spell.projectile_data,
		spawn_position,
		direction,
		payload
	)


func _compute_manual_attack_damage() -> float:
	var attack_power := stats.get_stat(&"attack_power")
	if attack_power <= 0.0:
		return 0.0
	return basic_spell.base_damage * (attack_power / 100.0)


func apply_buff(data: BuffData) -> void:
	if buff_container:
		buff_container.apply(data)


func grant_run_spell(spell: SpellData) -> void:
	if run_spells:
		run_spells.grant_spell(spell)


func upgrade_run_spell(spell: SpellData) -> void:
	if run_spells:
		run_spells.upgrade_spell(spell)


func get_run_spell_level(spell_id: StringName) -> int:
	if run_spells:
		return run_spells.get_spell_level(spell_id)
	return 0


func get_buff_stack_count(buff_id: StringName) -> int:
	if buff_container:
		return buff_container.get_buff_stack_count(buff_id)
	return 0


func clear_run_powers() -> void:
	if buff_container:
		buff_container.clear_run_only()
	if run_spells:
		run_spells.clear_all()


func get_active_run_spells() -> Array[SpellData]:
	if run_spells:
		return run_spells.get_active_spells()
	return []


func get_active_run_buffs() -> Array[BuffData]:
	if buff_container:
		return buff_container.get_active_buffs()
	return []


func take_damage(damage_event: DamageEvent) -> void:
	if current_health <= 0.0:
		return

	var amount := damage_event.base_damage
	current_health = maxf(current_health - amount, 0.0)
	player_damaged.emit(amount)
	health_changed.emit(current_health, max_health)
	_update_health_bar()

	print("[Player] Health: %.0f / %.0f" % [current_health, max_health])

	if current_health <= 0.0:
		player_died.emit()
		print("[Player] Died")


func gain_experience(amount: int) -> void:
	if RunManager.is_active() and amount > 0:
		RunManager.add_experience(amount)


func spend_mana(amount: float) -> bool:
	if amount <= 0.0:
		return false
	if current_mana < amount:
		return false

	current_mana -= amount
	mana_changed.emit(current_mana, max_mana)
	print("[Player] Mana: %.0f / %.0f" % [current_mana, max_mana])
	return true


func restore_mana(amount: float) -> void:
	if amount <= 0.0:
		return

	current_mana = minf(current_mana + amount, max_mana)
	mana_changed.emit(current_mana, max_mana)
	print("[Player] Mana: %.0f / %.0f" % [current_mana, max_mana])


func get_stats() -> StatsBlock:
	return stats


func is_dead() -> bool:
	return current_health <= 0.0


func _update_health_bar() -> void:
	if _health_bar and _health_bar.has_method("update_values"):
		_health_bar.update_values(current_health, max_health)
