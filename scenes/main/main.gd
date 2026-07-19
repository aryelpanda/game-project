## Boot router. Displays Save Slot Select on first launch and the Profile Hub
## when returning from a run (SaveManager keeps the current slot loaded).
extends Node

const SAVE_SLOT_SELECT_SCENE := preload("res://ui/save_slot_select/SaveSlotSelectScreen.tscn")
const PROFILE_HUB_SCENE := preload("res://ui/profile_hub/ProfileHubScreen.tscn")


func _ready() -> void:
	UIManager.clear_screens()
	UIManager.clear_modals()

	if SaveManager.has_current_slot():
		UIManager.push_screen(PROFILE_HUB_SCENE)
	else:
		UIManager.push_screen(SAVE_SLOT_SELECT_SCENE)
