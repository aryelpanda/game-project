## Minimal run HUD: timer, kills, XP bar, and run level.
extends Control

@onready var _timer_label: Label = $TimerLabel
@onready var _kills_label: Label = $KillsLabel
@onready var _level_label: Label = $LevelLabel
@onready var _xp_bar: ProgressBar = $XpBar
@onready var _xp_label: Label = $XpLabel


func _ready() -> void:
	RunManager.run_timer_changed.connect(_on_timer_changed)
	RunManager.kill_count_changed.connect(_on_kills_changed)
	RunManager.run_ended.connect(_on_run_ended)
	RunManager.run_started.connect(_on_run_started)
	RunManager.xp_changed.connect(_on_xp_changed)
	RunManager.run_level_changed.connect(_on_run_level_changed)
	_update_timer(0.0)
	_update_kills(0)
	_update_xp(0, 20)
	_update_level(1)


func _on_run_started(_map_id: StringName) -> void:
	show()
	_update_timer(0.0)
	_update_kills(0)
	_update_xp(RunManager.current_xp(), RunManager.xp_to_next_level())
	_update_level(RunManager.current_run_level())


func _on_run_ended(_summary: RunSummary) -> void:
	hide()


func _on_timer_changed(seconds: float) -> void:
	_update_timer(seconds)


func _on_kills_changed(kills: int) -> void:
	_update_kills(kills)


func _on_xp_changed(current_xp: int, xp_to_next: int) -> void:
	_update_xp(current_xp, xp_to_next)


func _on_run_level_changed(level: int) -> void:
	_update_level(level)


func _update_timer(seconds: float) -> void:
	var total_seconds := int(seconds)
	var minutes := total_seconds / 60
	var secs := total_seconds % 60
	_timer_label.text = "Time: %02d:%02d" % [minutes, secs]


func _update_kills(kills: int) -> void:
	_kills_label.text = "Kills: %d" % kills


func _update_xp(current_xp: int, xp_to_next: int) -> void:
	_xp_bar.max_value = maxf(float(xp_to_next), 1.0)
	_xp_bar.value = float(current_xp)
	_xp_label.text = "XP: %d / %d" % [current_xp, xp_to_next]


func _update_level(level: int) -> void:
	_level_label.text = "Level: %d" % level
