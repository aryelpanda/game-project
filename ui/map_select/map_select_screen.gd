## Opened from Profile Hub → Start Run. Lists unlocked maps and starts a run
## via RunManager.start_run() when a map is selected.
extends Control

const MAPS_DIR := "res://content/maps/"

@onready var _map_container: VBoxContainer = $Layout/ScrollBox/MapList
@onready var _back_btn: Button = $Layout/Footer/BackButton


func _ready() -> void:
	_back_btn.pressed.connect(func() -> void: UIManager.pop_screen())
	_rebuild_maps()


func _rebuild_maps() -> void:
	for child in _map_container.get_children():
		child.queue_free()

	var maps := _list_unlocked_maps()
	if maps.is_empty():
		var empty := Label.new()
		empty.text = "No maps unlocked."
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_map_container.add_child(empty)
		return

	for map in maps:
		_map_container.add_child(_make_map_row(map))


func _list_unlocked_maps() -> Array[MapData]:
	var meta := SaveManager.current_metadata()
	var unlocked_ids: Array[StringName] = []
	if meta and not meta.unlocked_maps.is_empty():
		unlocked_ids = meta.unlocked_maps.duplicate()
	else:
		unlocked_ids = SaveManager.DEFAULT_UNLOCKED_MAPS.duplicate()

	var out: Array[MapData] = []
	for map_id in unlocked_ids:
		var map := _load_map(map_id)
		if map:
			out.append(map)
	return out


func _load_map(map_id: StringName) -> MapData:
	var path := "%s%s.tres" % [MAPS_DIR, map_id]
	if not ResourceLoader.exists(path):
		push_warning("MapSelect: MapData not found at %s" % path)
		return null
	var resource := load(path)
	if resource is MapData:
		return resource
	push_warning("MapSelect: resource at %s is not MapData" % path)
	return null


func _make_map_row(map: MapData) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 88)

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
	title.text = map.display_name if not map.display_name.is_empty() else String(map.id)
	title.theme_type_variation = &"HeaderMedium"
	info.add_child(title)

	var detail := Label.new()
	detail.modulate = Color(0.8, 0.8, 0.85)
	detail.text = _format_map_detail(map)
	info.add_child(detail)

	var play_btn := Button.new()
	play_btn.text = "Play"
	play_btn.custom_minimum_size = Vector2(140, 36)
	var map_id := map.id
	play_btn.pressed.connect(func() -> void: _on_play_map(map_id))
	row.add_child(play_btn)

	return panel


func _format_map_detail(map: MapData) -> String:
	if map.run_duration_seconds > 0.0:
		var minutes := int(map.run_duration_seconds) / 60
		return "Survive %d min. Enemy pool: %d" % [minutes, map.enemy_pool.size()]
	return "Endless. Enemy pool: %d" % map.enemy_pool.size()


func _on_play_map(map_id: StringName) -> void:
	UIManager.clear_screens()
	RunManager.start_run(map_id, &"default")
