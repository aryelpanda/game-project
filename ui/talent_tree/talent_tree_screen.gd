## WotLK-style Talent Tree screen. Shows the 3 trees side by side with a points
## header, a testing reset button, and a game-master toggle. Free spending
## across all trees (MVP): left-click a node to spend, right-click to refund.
extends Control

const CONFIRM_DIALOG := preload("res://ui/common/ConfirmDialog.tscn")

@onready var _points_label: Label = $Layout/Header/PointsLabel
@onready var _gm_check: CheckButton = $Layout/Header/GameMasterCheck
@onready var _reset_btn: Button = $Layout/Header/ResetButton
@onready var _trees_row: HBoxContainer = $Layout/TreesScroll/TreesRow
@onready var _back_btn: Button = $Layout/Footer/BackButton

var _panels: Array[TalentTreePanel] = []


func _ready() -> void:
	_back_btn.pressed.connect(func() -> void: UIManager.pop_screen())
	_reset_btn.pressed.connect(_on_reset)

	_gm_check.button_pressed = TalentManager.is_game_master()
	_gm_check.toggled.connect(_on_gm_toggled)

	_build_panels()

	TalentManager.talent_points_changed.connect(_on_points_changed)
	TalentManager.talent_rank_changed.connect(_on_rank_changed)
	TalentManager.talents_reset.connect(_refresh_all)
	TalentManager.talents_loaded.connect(_refresh_all)

	_update_points_label()


func _build_panels() -> void:
	for tree in TalentManager.get_trees():
		var panel := TalentTreePanel.new()
		_trees_row.add_child(panel)
		panel.configure(tree)
		panel.talent_activated.connect(_on_talent_activated)
		_panels.append(panel)


func _on_talent_activated(talent_id: StringName, refund: bool) -> void:
	if refund:
		TalentManager.refund_talent(talent_id)
	else:
		TalentManager.unlock_talent(talent_id)


func _on_points_changed(_points: int) -> void:
	_update_points_label()
	_refresh_all()


func _on_rank_changed(_talent_id: StringName, _rank: int) -> void:
	_refresh_all()


func _refresh_all() -> void:
	for panel in _panels:
		panel.refresh()


func _update_points_label() -> void:
	var suffix := "  (Game Master)" if TalentManager.is_game_master() else ""
	_points_label.text = "Points: %d%s" % [TalentManager.available_points(), suffix]


func _on_gm_toggled(pressed: bool) -> void:
	TalentManager.set_game_master_enabled(pressed)
	_update_points_label()


func _on_reset() -> void:
	var dialog := UIManager.push_modal(CONFIRM_DIALOG)
	if not dialog:
		return
	if dialog.has_method("configure"):
		dialog.call(
			"configure",
			"Reset Talents",
			"Refund all spent talent points? This is a testing tool.",
			"Reset",
			"Cancel"
		)
	if dialog.has_signal("confirmed"):
		dialog.connect("confirmed", func() -> void: TalentManager.reset_talents())
