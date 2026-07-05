## SaveManager will coordinate profile slots and autosave flow.
extends Node

signal save_started(slot: int)
signal save_completed(slot: int)
signal load_completed(slot: int)
signal autosave_started(slot: int)
signal autosave_completed(slot: int)
signal save_failed(slot: int, reason: String)

var _saveables: Dictionary = {}


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


func save_profile(slot: int) -> bool:
	save_started.emit(slot)
	save_failed.emit(slot, "Save profile is not implemented yet.")
	return false


func load_profile(slot: int) -> bool:
	save_failed.emit(slot, "Load profile is not implemented yet.")
	return false
