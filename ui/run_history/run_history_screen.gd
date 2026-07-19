## Lists the current profile's latest completed/forfeited runs.
extends Control

const DETAILS_SCENE := preload("res://ui/run_history/RunHistoryDetailsScreen.tscn")

@onready var _list_container: VBoxContainer = $Layout/ScrollBox/EntryList
@onready var _empty_label: Label = $Layout/EmptyLabel
@onready var _back_btn: Button = $Layout/Footer/BackButton


func _ready() -> void:
	_back_btn.pressed.connect(func() -> void: UIManager.pop_screen())
	SaveManager.run_history_updated.connect(func(_slot: int) -> void: _rebuild_list())
	_rebuild_list()


func _rebuild_list() -> void:
	for child in _list_container.get_children():
		child.queue_free()

	var entries := SaveManager.get_run_history()
	if entries.is_empty():
		_empty_label.show()
		return
	_empty_label.hide()

	for entry in entries:
		_list_container.add_child(_make_entry_row(entry))


func _make_entry_row(entry: RunHistoryEntry) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 72)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	margin.add_child(row)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(info)

	var minutes := int(entry.duration_seconds) / 60
	var seconds := int(entry.duration_seconds) % 60

	var title := Label.new()
	title.text = "%s — %s" % [_format_map_name(entry.map_id), _format_end_reason(entry.end_reason)]
	info.add_child(title)

	var detail := Label.new()
	detail.modulate = Color(0.8, 0.8, 0.85)
	detail.text = "Time %02d:%02d   Lv %d   Kills %d   Dmg %.0f   Top: %s" % [
		minutes,
		seconds,
		entry.final_level,
		entry.total_kills,
		entry.total_damage_done,
		entry.top_spell_name(),
	]
	info.add_child(detail)

	var view_btn := Button.new()
	view_btn.text = "View"
	view_btn.custom_minimum_size = Vector2(120, 32)
	view_btn.pressed.connect(func() -> void: _on_view_entry(entry))
	row.add_child(view_btn)

	return panel


func _on_view_entry(entry: RunHistoryEntry) -> void:
	var screen := UIManager.push_screen(DETAILS_SCENE)
	if screen and screen.has_method("configure_from_entry"):
		screen.call("configure_from_entry", entry)


func _format_map_name(map_id: StringName) -> String:
	if map_id == &"":
		return "(unknown map)"
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
