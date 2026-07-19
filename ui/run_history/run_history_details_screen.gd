## Full breakdown of one Run History entry: map, time, character, kills,
## damage, chosen Spells/Buffs (with levels/stacks), and per-Spell damage.
extends Control

@onready var _title_label: Label = $Layout/TitleLabel
@onready var _body_label: RichTextLabel = $Layout/Body
@onready var _back_btn: Button = $Layout/Footer/BackButton


func _ready() -> void:
	_back_btn.pressed.connect(func() -> void: UIManager.pop_screen())


func configure_from_entry(entry: RunHistoryEntry) -> void:
	_title_label.text = "%s — %s" % [_format_map_name(entry.map_id), _format_end_reason(entry.end_reason)]
	_body_label.clear()
	_body_label.append_text(_build_body(entry))


func _build_body(entry: RunHistoryEntry) -> String:
	var minutes := int(entry.duration_seconds) / 60
	var seconds := int(entry.duration_seconds) % 60
	var lines: PackedStringArray = []
	lines.append("[b]Character:[/b] %s" % String(entry.character_id))
	lines.append("[b]Time:[/b] %02d:%02d" % [minutes, seconds])
	lines.append("[b]Final Level:[/b] %d" % entry.final_level)
	lines.append("[b]Kills:[/b] %d" % entry.total_kills)
	lines.append("[b]Damage Dealt:[/b] %.0f" % entry.total_damage_done)
	lines.append("[b]Damage Taken:[/b] %.0f" % entry.damage_taken)
	lines.append("[b]XP Collected:[/b] %d" % entry.xp_collected)

	lines.append("")
	lines.append("[b]Spells[/b]")
	if entry.spell_powers.is_empty():
		lines.append("  (none)")
	else:
		for raw in entry.spell_powers:
			if not raw is Dictionary:
				continue
			var s: Dictionary = raw
			lines.append("  %s (Lv %d) - %.0f dmg" % [
				String(s.get("display_name", "Unknown")),
				int(s.get("level", 1)),
				float(s.get("damage", 0.0)),
			])

	lines.append("")
	lines.append("[b]Buffs[/b]")
	if entry.buff_powers.is_empty():
		lines.append("  (none)")
	else:
		for raw in entry.buff_powers:
			if not raw is Dictionary:
				continue
			var b: Dictionary = raw
			lines.append("  %s x%d" % [
				String(b.get("display_name", "Unknown")),
				int(b.get("stacks", 1)),
			])

	return "\n".join(lines)


func _format_map_name(map_id: StringName) -> String:
	if map_id == &"":
		return "(unknown)"
	return String(map_id).replace("_", " ").capitalize()


func _format_end_reason(reason: StringName) -> String:
	if reason == &"time_up":
		return "Survived"
	if reason == &"death":
		return "Defeated"
	if reason == &"forfeit":
		return "Forfeited"
	if reason == &"debug_end":
		return "Test Ended"
	return String(reason)
