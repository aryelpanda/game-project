## Tracks active Buff instances on an entity and forwards modifiers to Stats.
class_name BuffContainer
extends RefCounted

signal buff_applied(buff_id: StringName, data: BuffData)
signal buff_removed(buff_id: StringName)

var _stats: StatsBlock
var _active: Dictionary = {}
var _buff_stacks: Dictionary = {}


func setup(stats: StatsBlock) -> void:
	_stats = stats


func apply(data: BuffData) -> void:
	if not data or not _stats:
		return

	var stack_index := int(_buff_stacks.get(data.id, 0))
	_buff_stacks[data.id] = stack_index + 1
	_active[data.id] = data

	for mod in data.modifiers:
		if mod:
			_stats.add_modifier(_stack_source_key(data.id, stack_index), mod)

	buff_applied.emit(data.id, data)
	print("[BuffContainer] Applied buff '%s' (stack %d)" % [data.display_name, _buff_stacks[data.id]])


func remove(buff_id: StringName) -> void:
	if not _stats or not _active.has(buff_id):
		return

	var stack_count := get_buff_stack_count(buff_id)
	for i in range(stack_count):
		_stats.remove_modifiers_from(_stack_source_key(buff_id, i))

	_active.erase(buff_id)
	_buff_stacks.erase(buff_id)
	buff_removed.emit(buff_id)
	print("[BuffContainer] Removed buff '%s'" % buff_id)


func has(buff_id: StringName) -> bool:
	return _active.has(buff_id)


func get_buff_stack_count(buff_id: StringName) -> int:
	return int(_buff_stacks.get(buff_id, 0))


func get_active_buffs() -> Array[BuffData]:
	var result: Array[BuffData] = []
	for data in _active.values():
		result.append(data as BuffData)
	return result


func clear_run_only() -> void:
	var to_remove: Array[StringName] = []
	for buff_id in _active.keys():
		var data: BuffData = _active[buff_id]
		if data.lifetime == BuffData.LIFETIME_RUN_ONLY:
			to_remove.append(buff_id)

	for buff_id in to_remove:
		remove(buff_id)


func clear_all() -> void:
	var ids := _active.keys()
	for buff_id in ids:
		remove(buff_id)


func _stack_source_key(buff_id: StringName, index: int) -> StringName:
	return StringName("%s#%d" % [buff_id, index])
