## Core coordinates global game state and scene transitions.
extends Node

signal game_state_changed(new_state: int)

enum GameState {
	BOOT,
	MAIN_MENU,
	IN_GAME,
	PAUSED,
	GAME_OVER,
}

var current_state: int = GameState.BOOT


func _ready() -> void:
	change_state(GameState.MAIN_MENU)


func change_state(new_state: int) -> void:
	if current_state == new_state:
		return

	current_state = new_state
	game_state_changed.emit(current_state)


func transition_to_scene(path: String) -> void:
	if path.is_empty():
		push_warning("Core.transition_to_scene called with an empty path.")
		return

	var error := get_tree().change_scene_to_file(path)
	if error != OK:
		push_error("Failed to transition to scene: %s" % path)


func set_paused(paused: bool) -> void:
	get_tree().paused = paused
	change_state(GameState.PAUSED if paused else GameState.IN_GAME)
