## In-run pause overlay. Toggled by the `pause_run` input action. Pauses gameplay
## via Core.set_paused. Offers Resume, Character Stats, Forfeit, Back to Hub.
extends Control

const CHARACTER_STATS_SCENE := preload("res://ui/character_stats/CharacterStatsScreen.tscn")
const CONFIRM_DIALOG := preload("res://ui/common/ConfirmDialog.tscn")

@onready var _resume_btn: Button = $Panel/VBox/ResumeButton
@onready var _stats_btn: Button = $Panel/VBox/StatsButton
@onready var _forfeit_btn: Button = $Panel/VBox/ForfeitButton
@onready var _quit_btn: Button = $Panel/VBox/QuitToHubButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()

	_resume_btn.pressed.connect(_close)
	_stats_btn.pressed.connect(_on_stats)
	_forfeit_btn.pressed.connect(_on_forfeit)
	_quit_btn.pressed.connect(_on_quit_to_hub)

	RunManager.run_ended.connect(_on_run_ended)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause_run"):
		if visible:
			_close()
		else:
			_open()


func _open() -> void:
	if RunManager.is_level_up_choice():
		return
	if not RunManager.is_active():
		return
	show()
	Core.set_paused(true)


func _close() -> void:
	hide()
	if not RunManager.is_level_up_choice():
		Core.set_paused(false)


func _on_run_ended(_summary: RunSummary) -> void:
	if visible:
		hide()


func _on_stats() -> void:
	var screen := UIManager.push_screen(CHARACTER_STATS_SCENE)
	if screen and screen.has_method("configure_in_run"):
		screen.call("configure_in_run")


func _on_forfeit() -> void:
	var modal := UIManager.push_modal(CONFIRM_DIALOG) as UIConfirmDialog
	if not modal:
		return
	modal.configure(
		"Forfeit Run",
		"Forfeiting ends the run and grants no rewards. Continue?",
		"Forfeit",
		"Cancel",
	)
	modal.confirmed.connect(func() -> void:
		hide()
		Core.set_paused(false)
		SaveManager.clear_active_run()
		RunManager.forfeit_run()
	)


func _on_quit_to_hub() -> void:
	var modal := UIManager.push_modal(CONFIRM_DIALOG) as UIConfirmDialog
	if not modal:
		return
	modal.configure(
		"Return to Hub",
		"Leave to the Profile Hub? Your active run will remain and can be resumed later.",
		"Leave",
		"Cancel",
	)
	modal.confirmed.connect(func() -> void:
		hide()
		Core.set_paused(false)
		RunManager.leave_to_hub()
	)
