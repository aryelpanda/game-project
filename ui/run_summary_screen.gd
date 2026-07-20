## Placeholder run end summary. Displays RunSummary data and offers restart /
## return to the Profile Hub. Restart re-enters the last-played map.
extends Control

@onready var _stats_label: Label = $Panel/StatsLabel
@onready var _restart_button: Button = $Panel/ButtonRow/RestartButton
@onready var _hub_button: Button = $Panel/ButtonRow/HubButton


func _ready() -> void:
	hide()
	_restart_button.pressed.connect(_on_restart_pressed)
	_hub_button.pressed.connect(_on_hub_pressed)
	RunManager.run_ended.connect(_on_run_ended)
	RunManager.run_started.connect(_on_run_started)


func _on_run_started(_map_id: StringName) -> void:
	hide()


func _on_run_ended(summary: RunSummary) -> void:
	var minutes := int(summary.duration_seconds) / 60
	var seconds := int(summary.duration_seconds) % 60
	var end_label := _format_end_reason(summary.end_reason)
	var lines: PackedStringArray = [
		end_label,
		"",
		"Time: %02d:%02d" % [minutes, seconds],
		"Enemies Killed: %d" % summary.total_kills,
		"Damage Dealt: %.0f" % summary.total_damage_done,
		"Damage Taken: %.0f" % summary.damage_taken,
		"XP Collected: %d" % summary.xp_collected,
		"Level: %d" % summary.final_level,
	]

	if summary.talent_points_awarded > 0:
		lines.append("Talent Points Earned: +%d" % summary.talent_points_awarded)

	lines.append("")
	lines.append("Spells:")
	if summary.spell_powers.is_empty():
		lines.append("  (none)")
	else:
		for entry in summary.spell_powers:
			if not entry is Dictionary:
				continue
			var spell_entry: Dictionary = entry
			lines.append(
				"  %s (Lv %d) - %.0f dmg"
				% [
					spell_entry.get("display_name", "Unknown"),
					int(spell_entry.get("level", 1)),
					float(spell_entry.get("damage", 0.0)),
				]
			)

	lines.append("")
	lines.append("Buffs:")
	if summary.buff_powers.is_empty():
		lines.append("  (none)")
	else:
		for entry in summary.buff_powers:
			if not entry is Dictionary:
				continue
			var buff_entry: Dictionary = entry
			lines.append(
				"  %s (Lv %d)"
				% [
					buff_entry.get("display_name", "Unknown"),
					int(buff_entry.get("stacks", 1)),
				]
			)

	_stats_label.text = "\n".join(lines)
	show()


func _format_end_reason(reason: StringName) -> String:
	if reason == &"time_up":
		return "Time Survived!"
	if reason == &"death":
		return "Defeated"
	if reason == &"forfeit":
		return "Forfeited"
	if reason == &"debug_end":
		return "Run Ended (Test)"
	return "Run Over (%s)" % reason


func _on_restart_pressed() -> void:
	hide()
	RunManager.restart_run()


func _on_hub_pressed() -> void:
	hide()
	RunManager.leave_to_hub()
