## Right-side panel listing active temporary run Spells and Buffs.
extends Control

@onready var _title_label: Label = $Panel/VBox/TitleLabel
@onready var _list_container: VBoxContainer = $Panel/VBox/ListContainer
@onready var _grant_all_button: Button = $Panel/VBox/GrantAllButton


func _ready() -> void:
	_grant_all_button.pressed.connect(_on_grant_all_pressed)
	RunManager.run_started.connect(_on_run_started)
	RunManager.run_ended.connect(_on_run_ended)
	RunManager.run_powers_changed.connect(_refresh)
	RunManager.level_up_available.connect(func(_opts): _refresh())

	hide()
	_refresh()


func _on_run_started(_map_id: StringName) -> void:
	show()
	_refresh()


func _on_run_ended(_summary: RunSummary) -> void:
	hide()
	_clear_list()


func _on_grant_all_pressed() -> void:
	RunManager.grant_all_test_rewards()
	_refresh()


func _refresh() -> void:
	_clear_list()

	var player := _find_player()
	if not player:
		_add_row("(no player)", "")
		return

	var has_any := false
	for spell in player.get_active_run_spells():
		has_any = true
		_add_row("[Spell] %s" % spell.display_name, String(spell.id))

	for buff in player.get_active_run_buffs():
		has_any = true
		_add_row("[Buff] %s" % buff.display_name, String(buff.id))

	if not has_any:
		_add_row("(none yet)", "Kill enemies or use Grant All")


func _add_row(title: String, subtitle: String) -> void:
	var row := VBoxContainer.new()
	row.add_theme_constant_override("separation", 2)

	var title_label := Label.new()
	title_label.text = title
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	row.add_child(title_label)

	if not subtitle.is_empty():
		var sub_label := Label.new()
		sub_label.text = subtitle
		sub_label.modulate = Color(0.75, 0.75, 0.8)
		sub_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.add_child(sub_label)

	_list_container.add_child(row)


func _clear_list() -> void:
	for child in _list_container.get_children():
		child.queue_free()


func _find_player() -> Node:
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return null
	return players[0]
