## First clickable screen. Lists SLOT_COUNT save slots with metadata and actions.
extends Control

const RESUME_FORFEIT_MODAL := preload("res://ui/resume_forfeit/ResumeForfeitModal.tscn")
const PROFILE_HUB_SCENE := preload("res://ui/profile_hub/ProfileHubScreen.tscn")
const CONFIRM_DIALOG := preload("res://ui/common/ConfirmDialog.tscn")

@onready var _slot_container: VBoxContainer = $CenterBox/Panel/VBox/SlotList
@onready var _quit_button: Button = $CenterBox/Panel/VBox/QuitRow/QuitButton


func _ready() -> void:
	_quit_button.pressed.connect(_on_quit_pressed)
	SaveManager.slot_list_changed.connect(_rebuild_slots)
	_rebuild_slots()


func _rebuild_slots() -> void:
	for child in _slot_container.get_children():
		child.queue_free()

	for meta in SaveManager.list_slots():
		_slot_container.add_child(_make_slot_row(meta))


func _make_slot_row(meta: SaveMetadata) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 84)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	margin.add_child(row)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 2)
	row.add_child(info)

	var title := Label.new()
	title.theme_type_variation = &"HeaderMedium"
	if meta.is_empty():
		title.text = "Slot %d — <empty>" % meta.slot
	else:
		title.text = "Slot %d — %s" % [meta.slot, meta.character_name]
	info.add_child(title)

	var detail := Label.new()
	detail.modulate = Color(0.8, 0.8, 0.85)
	detail.text = _format_slot_detail(meta)
	info.add_child(detail)

	if meta.has_active_run:
		var active_label := Label.new()
		active_label.modulate = Color(1.0, 0.85, 0.35)
		var minutes := int(meta.active_run_elapsed_seconds) / 60
		var seconds := int(meta.active_run_elapsed_seconds) % 60
		active_label.text = "Active run: %s  Lv %d  %02d:%02d" % [
			_format_map_name(meta.active_run_map),
			meta.active_run_level,
			minutes,
			seconds,
		]
		info.add_child(active_label)

	var actions := VBoxContainer.new()
	actions.custom_minimum_size = Vector2(160, 0)
	actions.add_theme_constant_override("separation", 6)
	row.add_child(actions)

	var slot_number := meta.slot
	if meta.is_empty():
		var new_btn := Button.new()
		new_btn.text = "New Profile"
		new_btn.pressed.connect(func() -> void: _on_new_profile(slot_number))
		actions.add_child(new_btn)
	else:
		var select_btn := Button.new()
		select_btn.text = "Select"
		select_btn.pressed.connect(func() -> void: _on_select_slot(slot_number))
		actions.add_child(select_btn)

		var delete_btn := Button.new()
		delete_btn.text = "Delete"
		delete_btn.pressed.connect(func() -> void: _on_delete_slot(slot_number, meta.character_name))
		actions.add_child(delete_btn)

	return panel


func _format_slot_detail(meta: SaveMetadata) -> String:
	if meta.is_empty():
		return "No profile"
	var last_played := "never"
	if meta.last_played_at > 0:
		last_played = Time.get_datetime_string_from_unix_time(meta.last_played_at)
	var minutes := int(meta.total_play_seconds) / 60
	return "Runs: %d   Playtime: %dm   Last played: %s" % [meta.run_count, minutes, last_played]


func _format_map_name(map_id: StringName) -> String:
	if map_id == &"":
		return "(unknown)"
	return String(map_id).replace("_", " ").capitalize()


func _on_new_profile(slot: int) -> void:
	if not SaveManager.create_slot(slot, ""):
		UIManager.show_toast("Could not create profile in slot %d." % slot)
		return
	_on_select_slot(slot)


func _on_select_slot(slot: int) -> void:
	if not SaveManager.select_slot(slot):
		UIManager.show_toast("Could not load profile in slot %d." % slot)
		return

	if SaveManager.has_active_run():
		var modal := UIManager.push_modal(RESUME_FORFEIT_MODAL) as Control
		if modal and modal.has_method("configure_for_slot"):
			modal.call("configure_for_slot", slot)
		return

	UIManager.replace_screen(PROFILE_HUB_SCENE)


func _on_delete_slot(slot: int, character_name: String) -> void:
	var modal := UIManager.push_modal(CONFIRM_DIALOG) as UIConfirmDialog
	if not modal:
		return
	modal.configure(
		"Delete Profile",
		"Delete '%s' in slot %d? This cannot be undone." % [character_name, slot],
		"Delete",
		"Cancel",
	)
	modal.confirmed.connect(func() -> void:
		SaveManager.delete_slot(slot)
		UIManager.show_toast("Slot %d deleted." % slot)
	)


func _on_quit_pressed() -> void:
	get_tree().quit()
