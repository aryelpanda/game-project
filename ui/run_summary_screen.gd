## Placeholder run end summary. Displays RunSummary data and offers restart.
extends Control

@onready var _stats_label: Label = $Panel/StatsLabel
@onready var _restart_button: Button = $Panel/RestartButton


func _ready() -> void:
	hide()
	_restart_button.pressed.connect(_on_restart_pressed)
	RunManager.run_ended.connect(_on_run_ended)
	RunManager.run_started.connect(_on_run_started)


func _on_run_started(_map_id: StringName) -> void:
	hide()


func _on_run_ended(summary: RunSummary) -> void:
	var minutes := int(summary.duration_seconds) / 60
	var seconds := int(summary.duration_seconds) % 60
	_stats_label.text = (
		"Run Over (%s)\n\n"
		% summary.end_reason
		+ "Time: %02d:%02d\n" % [minutes, seconds]
		+ "Kills: %d\n" % summary.total_kills
		+ "Damage Dealt: %.0f\n" % summary.total_damage_done
		+ "Damage Taken: %.0f\n" % summary.damage_taken
		+ "XP Collected: %d\n" % summary.xp_collected
		+ "Level: %d" % summary.final_level
	)
	show()


func _on_restart_pressed() -> void:
	RunManager.restart_run()
