## Owns permanent Talent Tree progression: available points, spent ranks, and
## the game-master testing toggle. Applies permanent effects to the player at
## run start and persists via the SaveManager saveable registry.
##
## MVP rules (see docs/systems/skills.md): free spending across all 3 trees,
## 1 point per rank, talents grant permanent StatModifiers and/or Spell unlocks.
extends Node

signal talent_points_changed(points: int)
signal talent_rank_changed(talent_id: StringName, rank: int)
signal talents_reset()
signal talents_loaded()

const SAVEABLE_ID := &"talents"
const PLAYER_STATS_PATH := "res://content/stats/player_default.tres"

const TREE_PATHS: Array[String] = [
	"res://content/talents/ember_tree.tres",
	"res://content/talents/frost_tree.tres",
	"res://content/talents/arcane_tree.tres",
]

var _trees: Array[TalentTreeData] = []
var _talent_index: Dictionary = {}      # StringName talent_id -> TalentData

var _available_points: int = 0
var _ranks: Dictionary = {}             # StringName talent_id -> int rank
var _game_master: bool = false


func _ready() -> void:
	_load_trees()
	SaveManager.register_saveable(SAVEABLE_ID, self)


# ---- Tree data ----------------------------------------------------------


func get_trees() -> Array[TalentTreeData]:
	return _trees


func get_talent(talent_id: StringName) -> TalentData:
	return _talent_index.get(talent_id, null)


func get_rank(talent_id: StringName) -> int:
	return int(_ranks.get(talent_id, 0))


# ---- Points -------------------------------------------------------------


func available_points() -> int:
	return _available_points


func spent_points(tree_id: StringName = &"") -> int:
	var total := 0
	for talent_id in _ranks.keys():
		var talent: TalentData = _talent_index.get(talent_id, null)
		if not talent:
			continue
		if tree_id != &"" and talent.tree_id != tree_id:
			continue
		total += int(_ranks[talent_id]) * maxi(talent.cost_per_rank, 1)
	return total


func add_points(amount: int) -> void:
	if amount <= 0:
		return
	_available_points += amount
	talent_points_changed.emit(_available_points)
	_autosave()


# ---- Spending -----------------------------------------------------------


func can_unlock(talent_id: StringName) -> bool:
	var talent: TalentData = _talent_index.get(talent_id, null)
	if not talent:
		return false
	if get_rank(talent_id) >= talent.max_rank:
		return false
	if _game_master:
		return true
	return _available_points >= maxi(talent.cost_per_rank, 1)


func unlock_talent(talent_id: StringName) -> bool:
	if not can_unlock(talent_id):
		return false

	var talent: TalentData = _talent_index[talent_id]
	var new_rank := get_rank(talent_id) + 1
	_ranks[talent_id] = new_rank
	if not _game_master:
		_available_points -= maxi(talent.cost_per_rank, 1)

	talent_rank_changed.emit(talent_id, new_rank)
	talent_points_changed.emit(_available_points)
	_autosave()
	return true


func refund_talent(talent_id: StringName) -> bool:
	var talent: TalentData = _talent_index.get(talent_id, null)
	if not talent:
		return false
	var current := get_rank(talent_id)
	if current <= 0:
		return false

	var new_rank := current - 1
	if new_rank <= 0:
		_ranks.erase(talent_id)
	else:
		_ranks[talent_id] = new_rank
	if not _game_master:
		_available_points += maxi(talent.cost_per_rank, 1)

	talent_rank_changed.emit(talent_id, new_rank)
	talent_points_changed.emit(_available_points)
	_autosave()
	return true


func reset_talents() -> void:
	# Testing tool: refund all spent ranks back into available points.
	_available_points += spent_points()
	_ranks.clear()
	talents_reset.emit()
	talent_points_changed.emit(_available_points)
	_autosave()


# ---- Game master toggle -------------------------------------------------


func is_game_master() -> bool:
	return _game_master


func set_game_master_enabled(enabled: bool) -> void:
	if _game_master == enabled:
		return
	_game_master = enabled
	talent_points_changed.emit(_available_points)
	_autosave()


# ---- Runtime application ------------------------------------------------


## Applies all permanent Talent effects to a freshly spawned player. Call from
## Player._ready() before max_health / max_mana are computed.
func apply_to_player(player: Node) -> void:
	if not player:
		return

	var stats: StatsBlock = player.get_stats() if player.has_method("get_stats") else null

	for talent_id in _ranks.keys():
		var talent: TalentData = _talent_index.get(talent_id, null)
		if not talent:
			continue
		var rank := int(_ranks[talent_id])
		if rank <= 0:
			continue

		if stats:
			var source := StringName("talent:%s" % String(talent_id))
			for mod in talent.effect_modifiers:
				if not mod:
					continue
				# Add one copy per rank so the pipeline sums to value * rank
				# without mutating the shared modifier resource.
				for i in range(rank):
					stats.add_modifier(source, mod)

		if talent.unlock_spell and player.has_method("grant_run_spell"):
			player.grant_run_spell(talent.unlock_spell)


## Builds a preview StatsBlock (base player stats + permanent talent modifiers)
## for the out-of-run Character Stats screen.
func get_permanent_preview() -> StatsBlock:
	var block := StatsBlock.new()
	if ResourceLoader.exists(PLAYER_STATS_PATH):
		var stats_data := load(PLAYER_STATS_PATH) as StatsData
		if stats_data:
			block.setup_from_data(stats_data)

	for talent_id in _ranks.keys():
		var talent: TalentData = _talent_index.get(talent_id, null)
		if not talent:
			continue
		var rank := int(_ranks[talent_id])
		var source := StringName("talent:%s" % String(talent_id))
		for mod in talent.effect_modifiers:
			if not mod:
				continue
			for i in range(rank):
				block.add_modifier(source, mod)
	return block


# ---- Save / load --------------------------------------------------------


func to_save_dict() -> Dictionary:
	var spent: Dictionary = {}
	for talent_id in _ranks.keys():
		spent[String(talent_id)] = int(_ranks[talent_id])
	return {
		"talent_currency": _available_points,
		"spent_talents": spent,
		"game_master_enabled": _game_master,
	}


func from_save_dict(data: Dictionary) -> void:
	_available_points = int(data.get("talent_currency", 0))
	_game_master = bool(data.get("game_master_enabled", false))
	_ranks.clear()
	var spent: Dictionary = data.get("spent_talents", {})
	for key in spent.keys():
		var talent_id := StringName(String(key))
		if _talent_index.has(talent_id):
			_ranks[talent_id] = int(spent[key])
	talents_loaded.emit()
	talent_points_changed.emit(_available_points)


func reset_runtime() -> void:
	_available_points = 0
	_ranks.clear()
	_game_master = false
	talents_loaded.emit()
	talent_points_changed.emit(_available_points)


# ---- Internal -----------------------------------------------------------


func _load_trees() -> void:
	_trees.clear()
	_talent_index.clear()
	for path in TREE_PATHS:
		if not ResourceLoader.exists(path):
			push_warning("TalentManager: talent tree not found at '%s'" % path)
			continue
		var tree := load(path) as TalentTreeData
		if not tree:
			push_warning("TalentManager: '%s' is not a TalentTreeData" % path)
			continue
		_trees.append(tree)
		for talent in tree.talents:
			if talent:
				_talent_index[talent.id] = talent


func _autosave() -> void:
	if SaveManager.has_current_slot():
		SaveManager.save_current_profile()
