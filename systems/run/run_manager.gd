## Coordinates run lifecycle: start, active tracking, end, checkpoint export.
extends Node

enum RunState { NOT_STARTED, STARTING, ACTIVE, LEVEL_UP_CHOICE, ENDED }

signal run_started(map_id: StringName)
signal run_ended(summary: RunSummary)
signal run_timer_changed(seconds: float)
signal kill_count_changed(kills: int)
signal xp_changed(current_xp: int, xp_to_next: int)
signal run_level_changed(level: int)
signal level_up_available(options: Array)
signal run_powers_changed()

const DEFAULT_PROGRESSION_PATH := "res://content/run/m4_default_progression.tres"

var _state: RunState = RunState.NOT_STARTED
var _map_id: StringName = &""
var _character_id: StringName = &""
var _elapsed_seconds: float = 0.0
var _kill_count: int = 0
var _total_damage_done: float = 0.0
var _spell_damage: Dictionary = {}
var _damage_taken: float = 0.0
var _xp_collected: int = 0
var _current_xp: int = 0
var _run_level: int = 1
var _xp_to_next_level: int = 20
var _level_ups_gained: int = 0
var _chosen_spells: Array[StringName] = []
var _chosen_buffs: Array[StringName] = []
var _pending_level_up_options: Array = []
var _progression: RunProgressionData
var _player_death_connected: bool = false


func _ready() -> void:
	_progression = _load_progression_data()
	_recompute_xp_threshold()
	DamageManager.damage_applied.connect(_on_damage_applied)
	EnemyManager.enemy_killed.connect(_on_enemy_killed)
	World.map_loaded.connect(_on_map_loaded)


func _process(delta: float) -> void:
	if _state != RunState.ACTIVE:
		return

	_elapsed_seconds += delta
	run_timer_changed.emit(_elapsed_seconds)

	var map_data := World.get_current_map_data()
	if map_data and map_data.run_duration_seconds > 0.0:
		if _elapsed_seconds >= map_data.run_duration_seconds:
			end_run(&"time_up")


func start_run(map_id: StringName, character_id: StringName) -> void:
	_stop_horde_spawner()
	EnemyManager.despawn_all_active()
	_clear_player_run_powers()

	_reset_run_stats()
	_map_id = map_id
	_character_id = character_id
	_state = RunState.STARTING
	_player_death_connected = false

	World.load_map(map_id)


func restart_run() -> void:
	start_run(_map_id if _map_id != &"" else &"test_arena", _character_id if _character_id != &"" else &"default")


func end_run(reason: StringName) -> RunSummary:
	if _state == RunState.ENDED:
		return _build_summary(reason)

	if _state == RunState.LEVEL_UP_CHOICE:
		_resume_from_level_up()

	_state = RunState.ENDED
	_stop_horde_spawner()

	var summary := _build_summary(reason)
	_clear_player_run_powers()
	run_ended.emit(summary)

	var checkpoint := to_checkpoint_dict()
	print("[RunManager] Checkpoint export: %s" % JSON.stringify(checkpoint))

	return summary


func add_experience(amount: int) -> void:
	if _state != RunState.ACTIVE or amount <= 0:
		return

	_current_xp += amount
	_xp_collected += amount
	xp_changed.emit(_current_xp, _xp_to_next_level)

	if _current_xp >= _xp_to_next_level:
		_current_xp -= _xp_to_next_level
		_run_level += 1
		_level_ups_gained += 1
		_recompute_xp_threshold()
		run_level_changed.emit(_run_level)
		xp_changed.emit(_current_xp, _xp_to_next_level)
		_trigger_level_up_choice()


func choose_level_up_reward(reward_id: StringName) -> void:
	if _state != RunState.LEVEL_UP_CHOICE:
		return

	var selected: Dictionary = {}
	for option in _pending_level_up_options:
		if option.get("id", &"") == reward_id:
			selected = option
			break

	if selected.is_empty():
		push_warning("RunManager: unknown reward id '%s'" % reward_id)
		return

	_apply_reward_option(selected)
	_pending_level_up_options.clear()
	_resume_from_level_up()


func grant_all_test_rewards() -> void:
	var pool := _get_reward_pool()
	if not pool:
		push_warning("RunManager: no reward pool configured for test grant")
		return

	for spell in pool.spells:
		if spell:
			_apply_spell_reward(spell)
	for buff in pool.buffs:
		if buff:
			_apply_buff_reward(buff)

	run_powers_changed.emit()


func end_run_for_testing() -> void:
	if _state != RunState.ACTIVE and _state != RunState.LEVEL_UP_CHOICE:
		return

	end_run(&"debug_end")


func register_enemy_kill(enemy_data: EnemyData) -> void:
	if _state != RunState.ACTIVE or not enemy_data:
		return

	_kill_count += 1
	kill_count_changed.emit(_kill_count)
	add_experience(enemy_data.xp_reward)


func register_spell_damage(spell_id: StringName, amount: float) -> void:
	if _state != RunState.ACTIVE:
		return

	if amount <= 0.0:
		return

	_total_damage_done += amount
	if spell_id != &"":
		_spell_damage[spell_id] = _spell_damage.get(spell_id, 0.0) + amount


func current_kill_count() -> int:
	return _kill_count


func current_run_level() -> int:
	return _run_level


func current_xp() -> int:
	return _current_xp


func xp_to_next_level() -> int:
	return _xp_to_next_level


func get_chosen_spells() -> Array[StringName]:
	return _chosen_spells.duplicate()


func get_chosen_buffs() -> Array[StringName]:
	return _chosen_buffs.duplicate()


func get_elapsed_seconds() -> float:
	return _elapsed_seconds


func is_active() -> bool:
	return _state == RunState.ACTIVE


func is_level_up_choice() -> bool:
	return _state == RunState.LEVEL_UP_CHOICE


func to_checkpoint_dict() -> Dictionary:
	var player := _find_player()
	var player_health := 0.0
	var player_max_health := 0.0
	if player:
		player_health = player.current_health
		player_max_health = player.max_health

	return {
		"map_id": String(_map_id),
		"character_id": String(_character_id),
		"elapsed_seconds": _elapsed_seconds,
		"kill_count": _kill_count,
		"xp_collected": _xp_collected,
		"current_xp": _current_xp,
		"run_level": _run_level,
		"level_ups_gained": _level_ups_gained,
		"chosen_spells": _chosen_spells.map(func(id): return String(id)),
		"chosen_buffs": _chosen_buffs.map(func(id): return String(id)),
		"total_damage_done": _total_damage_done,
		"damage_taken": _damage_taken,
		"player_current_health": player_health,
		"player_max_health": player_max_health,
	}


func from_checkpoint_dict(data: Dictionary) -> void:
	_map_id = StringName(data.get("map_id", ""))
	_character_id = StringName(data.get("character_id", ""))
	_elapsed_seconds = float(data.get("elapsed_seconds", 0.0))
	_kill_count = int(data.get("kill_count", 0))
	_xp_collected = int(data.get("xp_collected", 0))
	_current_xp = int(data.get("current_xp", 0))
	_run_level = int(data.get("run_level", 1))
	_level_ups_gained = int(data.get("level_ups_gained", 0))
	_total_damage_done = float(data.get("total_damage_done", 0.0))
	_damage_taken = float(data.get("damage_taken", 0.0))
	_chosen_spells.clear()
	for id in data.get("chosen_spells", []):
		_chosen_spells.append(StringName(id))
	_chosen_buffs.clear()
	for id in data.get("chosen_buffs", []):
		_chosen_buffs.append(StringName(id))
	_recompute_xp_threshold()


func _on_map_loaded(map_id: StringName) -> void:
	if _state != RunState.STARTING:
		return

	_state = RunState.ACTIVE
	run_started.emit(map_id)
	run_timer_changed.emit(_elapsed_seconds)
	kill_count_changed.emit(_kill_count)
	xp_changed.emit(_current_xp, _xp_to_next_level)
	run_level_changed.emit(_run_level)

	call_deferred("_connect_player_death")
	call_deferred("_start_horde_spawner")


func _on_enemy_killed(enemy_data: EnemyData) -> void:
	register_enemy_kill(enemy_data)


func _on_damage_applied(event: DamageEvent, final_damage: float) -> void:
	if _state != RunState.ACTIVE:
		return

	if not event or not event.target:
		return

	if event.target.is_in_group("player"):
		_damage_taken += final_damage
		return

	if event.target.is_in_group("enemy") and event.source and event.source.is_in_group("player"):
		register_spell_damage(event.spell_id, final_damage)


func _on_player_died() -> void:
	if _state != RunState.ACTIVE and _state != RunState.LEVEL_UP_CHOICE:
		return

	end_run(&"death")


func _connect_player_death() -> void:
	if _player_death_connected:
		return

	var player := _find_player()
	if not player:
		return

	if not player.player_died.is_connected(_on_player_died):
		player.player_died.connect(_on_player_died)
	_player_death_connected = true


func _start_horde_spawner() -> void:
	var spawner := _find_horde_spawner()
	if not spawner:
		push_warning("RunManager: HordeSpawner not found in map scene")
		return

	spawner.set_elapsed_provider(Callable(self, "get_elapsed_seconds"))
	spawner.start_spawning()


func _stop_horde_spawner() -> void:
	var spawner := _find_horde_spawner()
	if spawner:
		spawner.stop_spawning()


func _trigger_level_up_choice() -> void:
	_state = RunState.LEVEL_UP_CHOICE
	_stop_horde_spawner()
	Core.set_paused(true)
	_pending_level_up_options = _generate_level_up_options()
	level_up_available.emit(_pending_level_up_options)
	print("[RunManager] Level %d — choose a reward" % _run_level)


func _resume_from_level_up() -> void:
	Core.set_paused(false)
	if _state == RunState.LEVEL_UP_CHOICE:
		_state = RunState.ACTIVE
		call_deferred("_start_horde_spawner")


func _generate_level_up_options() -> Array:
	var pool := _get_reward_pool()
	if not pool:
		return []

	var candidates: Array = []
	for spell in pool.spells:
		if spell:
			candidates.append(_make_spell_option(spell))
	for buff in pool.buffs:
		if buff:
			candidates.append(_make_buff_option(buff))

	candidates.shuffle()

	var options: Array = []
	var used_ids: Dictionary = {}
	for candidate in candidates:
		var reward_id: StringName = candidate.get("id", &"")
		if reward_id == &"" or used_ids.has(reward_id):
			continue
		used_ids[reward_id] = true
		options.append(candidate)
		if options.size() >= 3:
			break

	return options


func _make_spell_option(spell: SpellData) -> Dictionary:
	var next_level := 1
	var player := _find_player()
	if player and player.has_method("get_run_spell_level"):
		var current_level: int = player.get_run_spell_level(spell.id)
		if current_level > 0:
			next_level = current_level + 1

	var display_name := spell.display_name
	if next_level > 1:
		display_name = "%s (Lv %d)" % [spell.display_name, next_level]

	return {
		"type": &"spell",
		"id": spell.id,
		"display_name": display_name,
		"description": spell.description,
		"resource": spell,
		"next_level": next_level,
	}


func _make_buff_option(buff: BuffData) -> Dictionary:
	var next_level := 1
	var player := _find_player()
	if player and player.has_method("get_buff_stack_count"):
		var current_stacks: int = player.get_buff_stack_count(buff.id)
		if current_stacks > 0:
			next_level = current_stacks + 1

	var display_name := buff.display_name
	if next_level > 1:
		display_name = "%s (Lv %d)" % [buff.display_name, next_level]

	return {
		"type": &"buff",
		"id": buff.id,
		"display_name": display_name,
		"description": buff.description,
		"resource": buff,
		"next_level": next_level,
	}


func _apply_reward_option(option: Dictionary) -> void:
	var reward_type: StringName = option.get("type", &"")
	if reward_type == &"spell":
		_apply_spell_reward(option.get("resource") as SpellData)
	elif reward_type == &"buff":
		_apply_buff_reward(option.get("resource") as BuffData)


func _apply_spell_reward(spell: SpellData) -> void:
	if not spell:
		return

	var player := _find_player()
	if not player:
		return

	if spell.id not in _chosen_spells:
		_chosen_spells.append(spell.id)

	if player.has_method("get_run_spell_level") and player.get_run_spell_level(spell.id) > 0:
		player.upgrade_run_spell(spell)
		print("[RunManager] Upgraded spell '%s'" % spell.display_name)
	else:
		player.grant_run_spell(spell)
		print("[RunManager] Chose spell '%s'" % spell.display_name)

	run_powers_changed.emit()


func _apply_buff_reward(buff: BuffData) -> void:
	if not buff:
		return

	var player := _find_player()
	if not player:
		return

	if buff.id not in _chosen_buffs:
		_chosen_buffs.append(buff.id)

	player.apply_buff(buff)
	run_powers_changed.emit()

	if player.has_method("get_buff_stack_count") and player.get_buff_stack_count(buff.id) > 1:
		print("[RunManager] Stacked buff '%s' to level %d" % [buff.display_name, player.get_buff_stack_count(buff.id)])
	else:
		print("[RunManager] Chose buff '%s'" % buff.display_name)


func _clear_player_run_powers() -> void:
	var player := _find_player()
	if player and player.has_method("clear_run_powers"):
		player.clear_run_powers()


func _get_reward_pool() -> RewardPoolData:
	if _progression and _progression.reward_pool:
		return _progression.reward_pool
	return null


func _recompute_xp_threshold() -> void:
	if not _progression:
		_xp_to_next_level = 20 + (_run_level - 1) * 10
		return

	_xp_to_next_level = _progression.base_xp_to_level + (_run_level - 1) * _progression.xp_per_level_increment


func _load_progression_data() -> RunProgressionData:
	if ResourceLoader.exists(DEFAULT_PROGRESSION_PATH):
		var resource := load(DEFAULT_PROGRESSION_PATH)
		if resource is RunProgressionData:
			return resource
	return null


func _find_horde_spawner() -> HordeSpawner:
	var root := get_tree().current_scene
	if not root:
		return null
	return root.find_child("HordeSpawner", true, false) as HordeSpawner


func _find_player() -> Node:
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return null
	return players[0]


func _reset_run_stats() -> void:
	_elapsed_seconds = 0.0
	_kill_count = 0
	_total_damage_done = 0.0
	_spell_damage.clear()
	_damage_taken = 0.0
	_xp_collected = 0
	_current_xp = 0
	_run_level = 1
	_level_ups_gained = 0
	_chosen_spells.clear()
	_chosen_buffs.clear()
	_pending_level_up_options.clear()
	_recompute_xp_threshold()


func _build_summary(reason: StringName) -> RunSummary:
	var summary := RunSummary.new()
	summary.map_id = _map_id
	summary.character_id = _character_id
	summary.end_reason = reason
	summary.duration_seconds = _elapsed_seconds
	summary.total_kills = _kill_count
	summary.total_damage_done = _total_damage_done
	summary.damage_taken = _damage_taken
	summary.xp_collected = _xp_collected
	summary.final_level = _run_level
	summary.spell_powers = _snapshot_spell_powers()
	summary.buff_powers = _snapshot_buff_powers()
	return summary


func _snapshot_spell_powers() -> Array:
	var entries: Array = []
	var player := _find_player()
	var display_names: Dictionary = {}

	if player and player.has_method("get_active_run_spells"):
		for spell in player.get_active_run_spells():
			if spell:
				display_names[spell.id] = spell.display_name

	var seen: Dictionary = {}

	if player and player.get("basic_spell"):
		var basic_spell: SpellData = player.basic_spell
		if basic_spell:
			seen[basic_spell.id] = true
			entries.append({
				"spell_id": basic_spell.id,
				"display_name": basic_spell.display_name,
				"level": 1,
				"damage": float(_spell_damage.get(basic_spell.id, 0.0)),
			})

	for spell_id in _chosen_spells:
		if seen.has(spell_id):
			continue

		seen[spell_id] = true
		var level := 1
		if player and player.has_method("get_run_spell_level"):
			level = maxi(player.get_run_spell_level(spell_id), 1)

		entries.append({
			"spell_id": spell_id,
			"display_name": display_names.get(spell_id, String(spell_id)),
			"level": level,
			"damage": float(_spell_damage.get(spell_id, 0.0)),
		})

	for spell_id in _spell_damage.keys():
		if seen.has(spell_id):
			continue

		entries.append({
			"spell_id": spell_id,
			"display_name": display_names.get(spell_id, String(spell_id)),
			"level": 1,
			"damage": float(_spell_damage[spell_id]),
		})

	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get("damage", 0.0)) > float(b.get("damage", 0.0))
	)
	return entries


func _snapshot_buff_powers() -> Array:
	var entries: Array = []
	var player := _find_player()
	var display_names: Dictionary = {}

	if player and player.has_method("get_active_run_buffs"):
		for buff in player.get_active_run_buffs():
			if buff:
				display_names[buff.id] = buff.display_name

	for buff_id in _chosen_buffs:
		var stacks := 1
		if player and player.has_method("get_buff_stack_count"):
			stacks = maxi(player.get_buff_stack_count(buff_id), 1)

		entries.append({
			"buff_id": buff_id,
			"display_name": display_names.get(buff_id, String(buff_id)),
			"stacks": stacks,
		})

	return entries
