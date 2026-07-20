## Out-of-run hub. Shows the selected character in the center and offers
## navigation to Start Run, Talent Tree, Inventory, Run History, Stats, Settings.
extends Control

const MAP_SELECT_SCENE := preload("res://ui/map_select/MapSelectScreen.tscn")
const RUN_HISTORY_SCENE := preload("res://ui/run_history/RunHistoryScreen.tscn")
const CHARACTER_STATS_SCENE := preload("res://ui/character_stats/CharacterStatsScreen.tscn")
const TALENT_TREE_SCENE := preload("res://ui/talent_tree/TalentTreeScreen.tscn")
const INVENTORY_SCENE := preload("res://ui/inventory/InventoryPlaceholderScreen.tscn")
const SETTINGS_SCENE := preload("res://ui/settings/SettingsScreen.tscn")

@onready var _character_label: Label = $Layout/Header/CharacterLabel
@onready var _slot_label: Label = $Layout/Header/SlotLabel
@onready var _character_portrait: ColorRect = $Layout/Body/CenterColumn/PortraitFrame/Portrait
@onready var _portrait_name: Label = $Layout/Body/CenterColumn/PortraitFrame/PortraitLabel

@onready var _start_run_btn: Button = $Layout/Body/RightColumn/StartRunButton
@onready var _talent_btn: Button = $Layout/Body/RightColumn/TalentButton
@onready var _inventory_btn: Button = $Layout/Body/RightColumn/InventoryButton
@onready var _history_btn: Button = $Layout/Body/RightColumn/HistoryButton
@onready var _stats_btn: Button = $Layout/Body/RightColumn/StatsButton
@onready var _settings_btn: Button = $Layout/Body/RightColumn/SettingsButton
@onready var _back_btn: Button = $Layout/Footer/BackButton


func _ready() -> void:
	_start_run_btn.pressed.connect(_on_start_run)
	_talent_btn.pressed.connect(func() -> void: UIManager.push_screen(TALENT_TREE_SCENE))
	_inventory_btn.pressed.connect(func() -> void: UIManager.push_screen(INVENTORY_SCENE))
	_history_btn.pressed.connect(func() -> void: UIManager.push_screen(RUN_HISTORY_SCENE))
	_stats_btn.pressed.connect(_on_stats)
	_settings_btn.pressed.connect(func() -> void: UIManager.push_screen(SETTINGS_SCENE))
	_back_btn.pressed.connect(_on_back_to_slot_select)

	SaveManager.current_slot_changed.connect(_refresh_header)
	_refresh_header(SaveManager.current_slot())


func _refresh_header(_slot: int) -> void:
	var meta := SaveManager.current_metadata()
	if not meta:
		_character_label.text = "No profile loaded"
		_slot_label.text = ""
		_portrait_name.text = "?"
		return
	_character_label.text = meta.character_name
	_slot_label.text = "Slot %d" % meta.slot
	_portrait_name.text = meta.character_name
	_character_portrait.color = _color_for_slot(meta.slot)


func _color_for_slot(slot: int) -> Color:
	var palette: PackedColorArray = [
		Color(0.40, 0.65, 0.90),
		Color(0.90, 0.55, 0.40),
		Color(0.55, 0.85, 0.55),
		Color(0.90, 0.85, 0.40),
		Color(0.75, 0.55, 0.90),
	]
	if slot < 1 or slot > palette.size():
		return Color(0.6, 0.6, 0.65)
	return palette[slot - 1]


func _on_start_run() -> void:
	UIManager.push_screen(MAP_SELECT_SCENE)


func _on_stats() -> void:
	var screen := UIManager.push_screen(CHARACTER_STATS_SCENE)
	if screen and screen.has_method("configure_out_of_run"):
		screen.call("configure_out_of_run")


func _on_back_to_slot_select() -> void:
	SaveManager.unload_current_slot()
	# NOTE: Use runtime `load()` (not parse-time `preload`) to avoid a circular
	# preload with SaveSlotSelectScreen.gd, which itself preloads ProfileHub.
	var scene: PackedScene = load("res://ui/save_slot_select/SaveSlotSelectScreen.tscn")
	UIManager.replace_screen(scene)
