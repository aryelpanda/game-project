## Minimal run HUD: health, mana, XP bar, run level, timer, kills.
## Reads state from Player + RunManager. Owns no game state itself.
extends Control

const CHARACTER_STATS_SCENE := preload("res://ui/character_stats/CharacterStatsScreen.tscn")

@onready var _timer_label: Label = $TopLeft/TimerLabel
@onready var _kills_label: Label = $TopLeft/KillsLabel
@onready var _level_label: Label = $TopLeft/LevelLabel
@onready var _hp_bar: UIStatBar = $VitalsBox/HealthBar
@onready var _mana_bar: UIStatBar = $VitalsBox/ManaBar
@onready var _xp_bar: UIStatBar = $VitalsBox/XpBar
@onready var _stats_button: Button = $TopLeft/CharacterStatsButton

var _player: Node = null


func _ready() -> void:
	RunManager.run_timer_changed.connect(_on_timer_changed)
	RunManager.kill_count_changed.connect(_on_kills_changed)
	RunManager.run_ended.connect(_on_run_ended)
	RunManager.run_started.connect(_on_run_started)
	RunManager.xp_changed.connect(_on_xp_changed)
	RunManager.run_level_changed.connect(_on_run_level_changed)

	_stats_button.pressed.connect(_on_stats_button_pressed)

	_update_timer(0.0)
	_update_kills(0)
	_update_xp(0, 20)
	_update_level(1)

	call_deferred("_bind_player")


func _on_run_started(_map_id: StringName) -> void:
	show()
	_update_timer(RunManager.get_elapsed_seconds())
	_update_kills(RunManager.current_kill_count())
	_update_xp(RunManager.current_xp(), RunManager.xp_to_next_level())
	_update_level(RunManager.current_run_level())
	call_deferred("_bind_player")


func _on_run_ended(_summary: RunSummary) -> void:
	hide()
	_unbind_player()


func _on_timer_changed(seconds: float) -> void:
	_update_timer(seconds)


func _on_kills_changed(kills: int) -> void:
	_update_kills(kills)


func _on_xp_changed(current_xp: int, xp_to_next: int) -> void:
	_update_xp(current_xp, xp_to_next)


func _on_run_level_changed(level: int) -> void:
	_update_level(level)


func _on_stats_button_pressed() -> void:
	Core.set_paused(true)
	var screen := UIManager.push_screen(CHARACTER_STATS_SCENE)
	if screen and screen.has_method("configure_in_run"):
		screen.call("configure_in_run")
	UIManager.screen_popped.connect(_on_stats_screen_popped, CONNECT_ONE_SHOT)


func _on_stats_screen_popped(_screen: Control) -> void:
	if not RunManager.is_level_up_choice():
		Core.set_paused(false)


func _bind_player() -> void:
	if _player and is_instance_valid(_player):
		return

	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return
	_player = players[0]

	if not _player.health_changed.is_connected(_on_health_changed):
		_player.health_changed.connect(_on_health_changed)
	if not _player.mana_changed.is_connected(_on_mana_changed):
		_player.mana_changed.connect(_on_mana_changed)

	_on_health_changed(_player.current_health, _player.max_health)
	_on_mana_changed(_player.current_mana, _player.max_mana)


func _unbind_player() -> void:
	_player = null


func _on_health_changed(current: float, maximum: float) -> void:
	if _hp_bar:
		_hp_bar.set_values(current, maximum)


func _on_mana_changed(current: float, maximum: float) -> void:
	if _mana_bar:
		_mana_bar.set_values(current, maximum)


func _update_timer(seconds: float) -> void:
	var total_seconds := int(seconds)
	var minutes := total_seconds / 60
	var secs := total_seconds % 60
	_timer_label.text = "Time: %02d:%02d" % [minutes, secs]


func _update_kills(kills: int) -> void:
	_kills_label.text = "Kills: %d" % kills


func _update_xp(current_xp: int, xp_to_next: int) -> void:
	if _xp_bar:
		_xp_bar.set_values(float(current_xp), float(xp_to_next))


func _update_level(level: int) -> void:
	_level_label.text = "Level: %d" % level
