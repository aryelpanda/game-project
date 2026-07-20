## Displays character stats. Out-of-run reads base values from player StatsData.
## In-run also reads the live StatsBlock and lists temporary buff sources.
extends Control

const PLAYER_STATS_PATH := "res://content/stats/player_default.tres"

const STAT_ROWS: Array = [
	{"id": &"max_health", "label": "Max Health"},
	{"id": &"max_mana", "label": "Max Mana"},
	{"id": &"attack_power", "label": "Attack Power"},
	{"id": &"spell_power", "label": "Spell Power"},
	{"id": &"move_speed", "label": "Move Speed"},
]

var _in_run: bool = false
var _ready_done: bool = false

@onready var _title_label: Label = $Layout/TitleLabel
@onready var _rows_container: VBoxContainer = $Layout/ScrollBox/RowsContainer
@onready var _temp_section: VBoxContainer = $Layout/ScrollBox/TempSection
@onready var _temp_list: VBoxContainer = $Layout/ScrollBox/TempSection/TempList
@onready var _back_btn: Button = $Layout/Footer/BackButton


func _ready() -> void:
	_back_btn.pressed.connect(func() -> void: UIManager.pop_screen())
	_ready_done = true
	_render()


func configure_out_of_run() -> void:
	_in_run = false
	if _ready_done:
		_render()


func configure_in_run() -> void:
	_in_run = true
	if _ready_done:
		_render()


func _render() -> void:
	for child in _rows_container.get_children():
		child.queue_free()
	if _in_run:
		_render_in_run()
	else:
		_render_out_of_run()


func _render_out_of_run() -> void:
	_title_label.text = "Character Stats"
	_temp_section.hide()

	var stats_data: StatsData = null
	if ResourceLoader.exists(PLAYER_STATS_PATH):
		stats_data = load(PLAYER_STATS_PATH) as StatsData
	if not stats_data:
		_add_row("(no stats data)", "", "", "")
		return

	# Permanent bonuses come from the player's spent Talents (M7).
	var preview: StatsBlock = TalentManager.get_permanent_preview()

	_add_header_row()
	for row in STAT_ROWS:
		var stat_id: StringName = row["id"]
		var label: String = row["label"]
		var base := stats_data.get_value(stat_id)
		var final := preview.get_stat(stat_id) if preview else base
		var permanent := final - base
		var permanent_text := "-"
		if abs(permanent) > 0.001:
			permanent_text = _format_signed(permanent)
		_add_row(label, _format_number(base), permanent_text, _format_number(final))


func _render_in_run() -> void:
	_title_label.text = "Character Stats (In Run)"

	var player := _find_player()
	if not player or not player.get_stats():
		_temp_section.hide()
		_add_row("(no player)", "", "", "")
		return

	var stats: StatsBlock = player.get_stats()

	_add_header_row_temp()
	for row in STAT_ROWS:
		var stat_id: StringName = row["id"]
		var label: String = row["label"]
		var base := stats.get_base_stat(stat_id)
		var final := stats.get_stat(stat_id)
		var temp := final - base
		var temp_text := "-"
		if abs(temp) > 0.001:
			temp_text = _format_signed(temp)
		_add_row(label, _format_number(base), temp_text, _format_number(final), 4)

	_temp_section.show()
	for child in _temp_list.get_children():
		child.queue_free()

	for buff in player.get_active_run_buffs():
		var stacks := 1
		if player.has_method("get_buff_stack_count"):
			stacks = maxi(player.get_buff_stack_count(buff.id), 1)
		var line := Label.new()
		line.text = "  %s x%d" % [buff.display_name, stacks]
		_temp_list.add_child(line)

	if _temp_list.get_child_count() == 0:
		var none_label := Label.new()
		none_label.modulate = Color(0.7, 0.7, 0.75)
		none_label.text = "  (no temporary buffs)"
		_temp_list.add_child(none_label)


func _add_header_row() -> void:
	_add_row("Stat", "Base", "Permanent", "Final", 4).modulate = Color(0.7, 0.7, 0.75)


func _add_header_row_temp() -> void:
	_add_row("Stat", "Base", "Temp Run", "Final", 4).modulate = Color(0.7, 0.7, 0.75)


func _add_row(a: String, b: String, c: String, d: String, columns: int = 4) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	_rows_container.add_child(row)

	var cols: PackedStringArray = [a, b, c, d]
	for i in range(columns):
		var label := Label.new()
		label.text = cols[i]
		label.custom_minimum_size = Vector2(140, 0)
		if i > 0:
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(label)
	return row


func _format_number(value: float) -> String:
	if abs(value - roundf(value)) < 0.001:
		return "%d" % int(round(value))
	return "%.1f" % value


func _format_signed(value: float) -> String:
	var prefix := "+"
	if value < 0.0:
		prefix = ""
	return "%s%s" % [prefix, _format_number(value)]


func _find_player() -> Node:
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return null
	return players[0]
