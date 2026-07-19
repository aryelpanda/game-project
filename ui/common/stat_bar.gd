## Reusable labeled bar. Used by HUD for HP/mana/XP and by dialogs for stat previews.
class_name UIStatBar
extends Control

@export var label_text: String = "Stat":
	set(value):
		label_text = value
		_apply_label()
@export var fill_color: Color = Color(0.85, 0.85, 0.85):
	set(value):
		fill_color = value
		_apply_fill_color()
@export var show_values: bool = true:
	set(value):
		show_values = value
		_refresh_value_label()

var _current: float = 0.0
var _maximum: float = 1.0

@onready var _label: Label = $VBox/HeaderRow/Label
@onready var _value_label: Label = $VBox/HeaderRow/ValueLabel
@onready var _bar: ProgressBar = $VBox/Bar


func _ready() -> void:
	_apply_label()
	_apply_fill_color()
	_refresh_value_label()
	_refresh_bar()


func set_values(current: float, maximum: float) -> void:
	_current = maxf(current, 0.0)
	_maximum = maxf(maximum, 0.0)
	if is_inside_tree():
		_refresh_bar()
		_refresh_value_label()


func _apply_label() -> void:
	if _label:
		_label.text = label_text


func _apply_fill_color() -> void:
	if not _bar:
		return
	var style := StyleBoxFlat.new()
	style.bg_color = fill_color
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_left = 2
	style.corner_radius_bottom_right = 2
	_bar.add_theme_stylebox_override("fill", style)


func _refresh_bar() -> void:
	if not _bar:
		return
	_bar.max_value = maxf(_maximum, 1.0)
	_bar.value = clampf(_current, 0.0, _bar.max_value)


func _refresh_value_label() -> void:
	if not _value_label:
		return
	if show_values:
		_value_label.show()
		_value_label.text = "%d / %d" % [int(round(_current)), int(round(_maximum))]
	else:
		_value_label.hide()
