## Runtime stat container with base values and modifier pipeline.
class_name StatsBlock
extends RefCounted

signal stat_changed(stat: StringName, new_value: float)

var _base: Dictionary = {}
var _modifiers: Dictionary = {}
var _final: Dictionary = {}


func setup_from_data(data: StatsData) -> void:
	if not data:
		push_warning("StatsBlock.setup_from_data called with null StatsData")
		return

	_base = data.values.duplicate()
	_recompute_all()


func get_stat(stat: StringName) -> float:
	return float(_final.get(stat, _base.get(stat, 0.0)))


func get_base_stat(stat: StringName) -> float:
	return float(_base.get(stat, 0.0))


func get_stat_breakdown(stat: StringName) -> Dictionary:
	var base_value := get_base_stat(stat)
	return {
		"base": base_value,
		"final": get_stat(stat),
	}


func add_modifier(source: StringName, mod: StatModifier) -> void:
	if not mod:
		return

	if not _modifiers.has(source):
		_modifiers[source] = []
	(_modifiers[source] as Array).append(mod)
	_recompute_stat(mod.stat)


func remove_modifiers_from(source: StringName) -> void:
	if not _modifiers.has(source):
		return

	var affected: Array[StringName] = []
	for mod in _modifiers[source]:
		if mod is StatModifier and mod.stat not in affected:
			affected.append(mod.stat)

	_modifiers.erase(source)

	for stat in affected:
		_recompute_stat(stat)


func clear_all_modifiers() -> void:
	var affected: Array[StringName] = []
	for source in _modifiers.keys():
		for mod in _modifiers[source]:
			if mod is StatModifier and mod.stat not in affected:
				affected.append(mod.stat)

	_modifiers.clear()

	for stat in affected:
		_recompute_stat(stat)


func _recompute_all() -> void:
	_final.clear()
	for stat in _base.keys():
		_recompute_stat(stat)


func _recompute_stat(stat: StringName) -> void:
	var base_value := get_base_stat(stat)
	var flat_bonus := 0.0
	var percent_add := 0.0

	for source in _modifiers.keys():
		for mod in _modifiers[source]:
			if not mod is StatModifier or mod.stat != stat:
				continue
			if mod.type == StatModifier.TYPE_FLAT:
				flat_bonus += mod.value
			elif mod.type == StatModifier.TYPE_PERCENT_ADD:
				percent_add += mod.value

	var final_value := (base_value + flat_bonus) * (1.0 + percent_add)
	_final[stat] = final_value
	stat_changed.emit(stat, final_value)
