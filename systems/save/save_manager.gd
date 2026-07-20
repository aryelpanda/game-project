## Coordinates profile slots, active run checkpoints, run history, and autosave.
##
## File layout (per slot):
##   user://saves/slot_<N>/profile.json         + profile.json.bak
##   user://saves/slot_<N>/active_run.json      (present only for interrupted runs)
##   user://saves/slot_<N>/run_history.json
##
## Writes are atomic: write to <path>.tmp, keep previous copy as <path>.bak, then rename.
extends Node

signal current_slot_changed(slot: int)
signal save_started(slot: int)
signal save_completed(slot: int)
signal load_completed(slot: int)
signal autosave_started(slot: int)
signal autosave_completed(slot: int)
signal save_failed(slot: int, reason: String)
signal slot_list_changed()
signal run_history_updated(slot: int)

const SAVE_DIR := "user://saves"
const SLOT_COUNT := 5
const HISTORY_MAX := 100
const PROFILE_VERSION := 1

const DEFAULT_UNLOCKED_MAPS: Array[StringName] = [&"five_minute_gauntlet", &"test_arena"]

var _current_slot: int = -1
var _current_metadata: SaveMetadata
var _saveables: Dictionary = {}


func _ready() -> void:
	_ensure_root_dir()


func register_saveable(id: StringName, obj: Object) -> void:
	if id == &"":
		push_warning("SaveManager.register_saveable called with an empty id.")
		return
	if obj == null:
		push_warning("SaveManager.register_saveable called with a null object.")
		return
	_saveables[id] = obj


func unregister_saveable(id: StringName) -> void:
	_saveables.erase(id)


# ---- Slot management -----------------------------------------------------


func slot_count() -> int:
	return SLOT_COUNT


func list_slots() -> Array[SaveMetadata]:
	var out: Array[SaveMetadata] = []
	for i in range(1, SLOT_COUNT + 1):
		out.append(get_slot_metadata(i))
	return out


func get_slot_metadata(slot: int) -> SaveMetadata:
	var meta := SaveMetadata.new()
	meta.slot = slot
	var profile_data := _read_json(_profile_path(slot))
	if profile_data.is_empty():
		return meta
	meta.from_dict(profile_data)
	meta.slot = slot
	meta.has_active_run = _file_exists(_active_run_path(slot))
	if meta.has_active_run:
		var run_data := _read_json(_active_run_path(slot))
		var payload: Dictionary = run_data.get("checkpoint", {})
		meta.active_run_map = StringName(String(payload.get("map_id", "")))
		meta.active_run_elapsed_seconds = float(payload.get("elapsed_seconds", 0.0))
		meta.active_run_level = int(payload.get("run_level", 1))
	return meta


func slot_exists(slot: int) -> bool:
	return _file_exists(_profile_path(slot))


func create_slot(slot: int, character_name: String) -> bool:
	if not _valid_slot(slot):
		return false
	if slot_exists(slot):
		push_warning("SaveManager.create_slot: slot %d already exists" % slot)
		return false

	_ensure_slot_dir(slot)
	# A brand-new profile starts from default progression state.
	_reset_saveables()

	var meta := SaveMetadata.new()
	meta.slot = slot
	meta.character_name = character_name if not character_name.is_empty() else "Adventurer %d" % slot
	meta.created_at = int(Time.get_unix_time_from_system())
	meta.last_played_at = meta.created_at
	meta.total_play_seconds = 0.0
	meta.unlocked_maps = DEFAULT_UNLOCKED_MAPS.duplicate()
	meta.highest_unlocked_map = DEFAULT_UNLOCKED_MAPS[0] if not DEFAULT_UNLOCKED_MAPS.is_empty() else &""

	var ok := _write_profile(slot, meta)
	if ok:
		slot_list_changed.emit()
	return ok


func select_slot(slot: int) -> bool:
	if not _valid_slot(slot):
		return false
	if not slot_exists(slot):
		push_warning("SaveManager.select_slot: no profile in slot %d" % slot)
		return false

	var meta := get_slot_metadata(slot)
	_current_slot = slot
	_current_metadata = meta
	_hydrate_saveables(_read_json(_profile_path(slot)))
	current_slot_changed.emit(slot)
	load_completed.emit(slot)
	return true


func unload_current_slot() -> void:
	if _current_slot == -1:
		return
	_current_slot = -1
	_current_metadata = null
	_reset_saveables()
	current_slot_changed.emit(-1)


func delete_slot(slot: int) -> bool:
	if not _valid_slot(slot):
		return false
	if _current_slot == slot:
		unload_current_slot()

	var dir_path := _slot_dir(slot)
	_delete_dir_recursive(dir_path)
	slot_list_changed.emit()
	return true


func current_slot() -> int:
	return _current_slot


func has_current_slot() -> bool:
	return _current_slot != -1


func current_metadata() -> SaveMetadata:
	return _current_metadata


# ---- Profile persistence ------------------------------------------------


func save_current_profile() -> bool:
	if not has_current_slot():
		return false
	_current_metadata.last_played_at = int(Time.get_unix_time_from_system())
	return _write_profile(_current_slot, _current_metadata)


# ---- Active run checkpoint ----------------------------------------------


func has_active_run(slot: int = -1) -> bool:
	var s := slot if slot != -1 else _current_slot
	if s == -1:
		return false
	return _file_exists(_active_run_path(s))


func save_active_run(checkpoint: Dictionary) -> bool:
	if not has_current_slot():
		return false
	autosave_started.emit(_current_slot)

	var wrapper := {
		"version": PROFILE_VERSION,
		"saved_at": int(Time.get_unix_time_from_system()),
		"checkpoint": checkpoint,
	}
	var ok := _write_json_atomic(_active_run_path(_current_slot), wrapper)
	if ok:
		autosave_completed.emit(_current_slot)
	else:
		save_failed.emit(_current_slot, "Failed to write active_run.json")
	return ok


func load_active_run(slot: int = -1) -> Dictionary:
	var s := slot if slot != -1 else _current_slot
	if s == -1:
		return {}
	var data := _read_json(_active_run_path(s))
	return data.get("checkpoint", {})


func clear_active_run(slot: int = -1) -> bool:
	var s := slot if slot != -1 else _current_slot
	if s == -1:
		return false
	return _delete_file(_active_run_path(s))


# ---- Run history --------------------------------------------------------


func get_run_history(slot: int = -1) -> Array[RunHistoryEntry]:
	var s := slot if slot != -1 else _current_slot
	var result: Array[RunHistoryEntry] = []
	if s == -1:
		return result

	var data := _read_json(_run_history_path(s))
	var entries: Array = data.get("entries", [])
	for raw in entries:
		if not raw is Dictionary:
			continue
		var entry := RunHistoryEntry.new()
		entry.from_dict(raw)
		result.append(entry)
	return result


func append_run_history(entry: RunHistoryEntry) -> bool:
	if not has_current_slot() or not entry:
		return false

	var existing := get_run_history()
	existing.push_front(entry)
	if existing.size() > HISTORY_MAX:
		existing.resize(HISTORY_MAX)

	var payload := {
		"version": PROFILE_VERSION,
		"entries": existing.map(func(e: RunHistoryEntry) -> Dictionary: return e.to_dict()),
	}
	var ok := _write_json_atomic(_run_history_path(_current_slot), payload)
	if ok:
		if _current_metadata:
			_current_metadata.run_count = existing.size()
		run_history_updated.emit(_current_slot)
	else:
		save_failed.emit(_current_slot, "Failed to write run_history.json")
	return ok


# ---- Path helpers -------------------------------------------------------


func _slot_dir(slot: int) -> String:
	return "%s/slot_%d" % [SAVE_DIR, slot]


func _profile_path(slot: int) -> String:
	return "%s/profile.json" % _slot_dir(slot)


func _active_run_path(slot: int) -> String:
	return "%s/active_run.json" % _slot_dir(slot)


func _run_history_path(slot: int) -> String:
	return "%s/run_history.json" % _slot_dir(slot)


# ---- Filesystem helpers -------------------------------------------------


func _valid_slot(slot: int) -> bool:
	if slot < 1 or slot > SLOT_COUNT:
		push_warning("SaveManager: invalid slot %d (valid 1..%d)" % [slot, SLOT_COUNT])
		return false
	return true


func _ensure_root_dir() -> void:
	if DirAccess.dir_exists_absolute(SAVE_DIR):
		return
	var err := DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	if err != OK:
		push_error("SaveManager: could not create save dir '%s' (err %d)" % [SAVE_DIR, err])


func _ensure_slot_dir(slot: int) -> void:
	var path := _slot_dir(slot)
	if DirAccess.dir_exists_absolute(path):
		return
	var err := DirAccess.make_dir_recursive_absolute(path)
	if err != OK:
		push_error("SaveManager: could not create slot dir '%s' (err %d)" % [path, err])


func _file_exists(path: String) -> bool:
	return FileAccess.file_exists(path)


func _write_profile(slot: int, meta: SaveMetadata) -> bool:
	save_started.emit(slot)
	_ensure_slot_dir(slot)
	var ok := _write_json_atomic(_profile_path(slot), _collect_profile_payload(meta))
	if ok:
		save_completed.emit(slot)
	else:
		save_failed.emit(slot, "Failed to write profile.json")
	return ok


func _collect_profile_payload(meta: SaveMetadata) -> Dictionary:
	# profile.json holds the slot metadata plus one section per registered
	# saveable system (e.g. "talents"), keyed by its registry id.
	var payload := meta.to_dict()
	for id in _saveables.keys():
		var obj: Object = _saveables[id]
		if obj and obj.has_method("to_save_dict"):
			payload[String(id)] = obj.to_save_dict()
	return payload


func _hydrate_saveables(profile_data: Dictionary) -> void:
	for id in _saveables.keys():
		var obj: Object = _saveables[id]
		if obj and obj.has_method("from_save_dict"):
			obj.from_save_dict(profile_data.get(String(id), {}))


func _reset_saveables() -> void:
	for id in _saveables.keys():
		var obj: Object = _saveables[id]
		if not obj:
			continue
		if obj.has_method("reset_runtime"):
			obj.reset_runtime()
		elif obj.has_method("from_save_dict"):
			obj.from_save_dict({})


func _write_json_atomic(path: String, payload: Dictionary) -> bool:
	var tmp_path := "%s.tmp" % path
	var bak_path := "%s.bak" % path

	var file := FileAccess.open(tmp_path, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: could not open '%s' for writing (err %d)" % [tmp_path, FileAccess.get_open_error()])
		return false

	file.store_string(JSON.stringify(payload, "\t"))
	file.close()

	if FileAccess.file_exists(path):
		if FileAccess.file_exists(bak_path):
			DirAccess.remove_absolute(bak_path)
		var rename_err := DirAccess.rename_absolute(path, bak_path)
		if rename_err != OK:
			push_warning("SaveManager: could not create backup at '%s' (err %d)" % [bak_path, rename_err])

	var final_err := DirAccess.rename_absolute(tmp_path, path)
	if final_err != OK:
		push_error("SaveManager: could not rename '%s' -> '%s' (err %d)" % [tmp_path, path, final_err])
		return false
	return true


func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("SaveManager: could not open '%s' for reading (err %d)" % [path, FileAccess.get_open_error()])
		return {}
	var text := file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(text)
	if parsed is Dictionary:
		return parsed
	push_warning("SaveManager: file '%s' does not contain a JSON object" % path)
	return {}


func _delete_file(path: String) -> bool:
	if not FileAccess.file_exists(path):
		return true
	var err := DirAccess.remove_absolute(path)
	if err != OK:
		push_warning("SaveManager: could not delete '%s' (err %d)" % [path, err])
		return false
	return true


func _delete_dir_recursive(path: String) -> void:
	if not DirAccess.dir_exists_absolute(path):
		return
	var dir := DirAccess.open(path)
	if dir == null:
		return
	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		var child_path := "%s/%s" % [path, entry]
		if dir.current_is_dir():
			_delete_dir_recursive(child_path)
		else:
			DirAccess.remove_absolute(child_path)
		entry = dir.get_next()
	dir.list_dir_end()
	DirAccess.remove_absolute(path)
