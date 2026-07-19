## Prompt to resume or forfeit an interrupted run. Shown after selecting a slot
## with an active checkpoint. Forfeit clears the checkpoint (no rewards, MVP).
extends Control

const PROFILE_HUB_SCENE := preload("res://ui/profile_hub/ProfileHubScreen.tscn")

@onready var _title_label: Label = $Panel/VBox/TitleLabel
@onready var _body_label: Label = $Panel/VBox/BodyLabel
@onready var _resume_button: Button = $Panel/VBox/ButtonRow/ResumeButton
@onready var _forfeit_button: Button = $Panel/VBox/ButtonRow/ForfeitButton

var _slot: int = -1
var _map_id: StringName = &""
var _elapsed: float = 0.0
var _run_level: int = 1


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_resume_button.pressed.connect(_on_resume_pressed)
	_forfeit_button.pressed.connect(_on_forfeit_pressed)


func configure_for_slot(slot: int) -> void:
	_slot = slot
	var checkpoint := SaveManager.load_active_run(slot)
	_map_id = StringName(String(checkpoint.get("map_id", "")))
	_elapsed = float(checkpoint.get("elapsed_seconds", 0.0))
	_run_level = int(checkpoint.get("run_level", 1))
	_refresh()


func _refresh() -> void:
	_title_label.text = "Interrupted Run"
	var minutes := int(_elapsed) / 60
	var seconds := int(_elapsed) % 60
	_body_label.text = "An active run was found in this slot:\n\nMap: %s\nLevel: %d\nElapsed: %02d:%02d\n\nResume the run, or forfeit it (no rewards)?" % [
		_format_map_name(_map_id),
		_run_level,
		minutes,
		seconds,
	]


func _format_map_name(map_id: StringName) -> String:
	if map_id == &"":
		return "(unknown)"
	return String(map_id).replace("_", " ").capitalize()


func _on_resume_pressed() -> void:
	UIManager.pop_modal()
	UIManager.clear_screens()
	var checkpoint := SaveManager.load_active_run(_slot)
	RunManager.resume_run(checkpoint)


func _on_forfeit_pressed() -> void:
	SaveManager.clear_active_run(_slot)
	UIManager.pop_modal()
	UIManager.replace_screen(PROFILE_HUB_SCENE)
