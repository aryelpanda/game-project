## Executes temporary run Spells granted during level-up. Auto-fire on cooldown.
class_name RunSpellController
extends Node2D

signal spell_granted(spell: SpellData)
signal spell_removed(spell_id: StringName)
signal powers_changed()

const ORBIT_AURA_SCENE := preload("res://systems/skills/OrbitAura.tscn")
const AUTO_PROJECTILE_SPREAD := 0.26

var _player: Node2D
var _active_spells: Dictionary = {}
var _spell_levels: Dictionary = {}
var _cooldowns: Dictionary = {}
var _orbit_nodes: Dictionary = {}


func setup(player: Node2D) -> void:
	_player = player


func grant_spell(spell: SpellData) -> void:
	if not spell or not _player:
		return

	if _active_spells.has(spell.id):
		upgrade_spell(spell)
		return

	_active_spells[spell.id] = spell
	_spell_levels[spell.id] = 1
	_cooldowns[spell.id] = 0.0

	if spell.spell_type == SpellData.TYPE_ORBIT_AURA:
		_spawn_orbit_aura(spell)

	spell_granted.emit(spell)
	powers_changed.emit()
	print("[RunSpellController] Granted spell '%s'" % spell.display_name)


func upgrade_spell(spell: SpellData) -> void:
	if not spell or not _player:
		return

	if not _active_spells.has(spell.id):
		grant_spell(spell)
		return

	_spell_levels[spell.id] = get_spell_level(spell.id) + 1

	if spell.spell_type == SpellData.TYPE_ORBIT_AURA:
		_spawn_orbit_aura(spell)

	powers_changed.emit()
	print(
		"[RunSpellController] Upgraded spell '%s' to level %d"
		% [spell.display_name, get_spell_level(spell.id)]
	)


func remove_spell(spell_id: StringName) -> void:
	if not _active_spells.has(spell_id):
		return

	var spell: SpellData = _active_spells[spell_id]
	if spell.spell_type == SpellData.TYPE_ORBIT_AURA:
		_clear_orbit_aura(spell_id)

	_active_spells.erase(spell_id)
	_spell_levels.erase(spell_id)
	_cooldowns.erase(spell_id)
	spell_removed.emit(spell_id)
	powers_changed.emit()
	print("[RunSpellController] Removed spell '%s'" % spell_id)


func clear_all() -> void:
	var ids := _active_spells.keys()
	for spell_id in ids:
		remove_spell(spell_id)


func get_active_spells() -> Array[SpellData]:
	var result: Array[SpellData] = []
	for spell in _active_spells.values():
		result.append(spell as SpellData)
	return result


func has_spell(spell_id: StringName) -> bool:
	return _active_spells.has(spell_id)


func get_spell_level(spell_id: StringName) -> int:
	return int(_spell_levels.get(spell_id, 0))


func _physics_process(delta: float) -> void:
	if not _player or not RunManager.is_active():
		return

	var now := Time.get_ticks_msec() / 1000.0
	for spell_id in _active_spells.keys():
		var spell: SpellData = _active_spells[spell_id]
		if spell.spell_type != SpellData.TYPE_AUTO_PROJECTILE:
			continue
		if _cooldowns.get(spell_id, 0.0) > now:
			continue
		if not spell.projectile_data:
			continue

		_cooldowns[spell_id] = now + spell.cooldown
		_fire_auto_projectile(spell)


func _fire_auto_projectile(spell: SpellData) -> void:
	var level := maxi(get_spell_level(spell.id), 1)
	var base_angle := randf() * TAU

	for i in range(level):
		var angle_offset := 0.0
		if level > 1:
			angle_offset = lerpf(-AUTO_PROJECTILE_SPREAD, AUTO_PROJECTILE_SPREAD, float(i) / float(level - 1))
		var direction := Vector2.from_angle(base_angle + angle_offset)
		var spawn_position := EntityCollision.compute_projectile_spawn_position(
			_player as CharacterBody2D,
			direction,
			spell.projectile_data.radius
		)

		var payload := DamageEvent.new()
		payload.source = _player
		payload.base_damage = spell.base_damage
		payload.damage_type = spell.damage_type
		payload.spell_id = spell.id

		ProjectileManager.spawn(spell.projectile_data, spawn_position, direction, payload)


func _spawn_orbit_aura(spell: SpellData) -> void:
	_clear_orbit_aura(spell.id)

	var nodes: Array[OrbitAura] = []
	var level := maxi(get_spell_level(spell.id), 1)
	var count := spell.orbit_count + (level - 1)
	for i in range(count):
		var aura: OrbitAura = ORBIT_AURA_SCENE.instantiate()
		var start_angle := (TAU / float(count)) * float(i)
		aura.configure(spell, _player, start_angle)
		add_child(aura)
		nodes.append(aura)

	_orbit_nodes[spell.id] = nodes


func _clear_orbit_aura(spell_id: StringName) -> void:
	if not _orbit_nodes.has(spell_id):
		return

	for aura in _orbit_nodes[spell_id]:
		if is_instance_valid(aura):
			aura.reset_for_pool()
			aura.queue_free()

	_orbit_nodes.erase(spell_id)
