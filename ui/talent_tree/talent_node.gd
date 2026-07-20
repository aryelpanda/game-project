## A single Talent node widget for the WotLK-style Talent Tree UI.
## Placeholder art: a theme-colored square with the talent's initials, a rank
## badge, and a border that turns gold when maxed. Left-click spends a point,
## right-click refunds one. Real icons land in M9.
class_name TalentNode
extends Control

signal left_clicked(talent_id: StringName)
signal right_clicked(talent_id: StringName)

const NODE_SIZE := Vector2(64, 64)

var _talent: TalentData
var _tree_color: Color = Color.WHITE
var _rank: int = 0

var _icon: ColorRect
var _initials: Label
var _badge: Label


func _ready() -> void:
	custom_minimum_size = NODE_SIZE
	size = NODE_SIZE
	mouse_filter = Control.MOUSE_FILTER_STOP

	_icon = ColorRect.new()
	_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_icon.position = Vector2(5, 5)
	_icon.size = Vector2(54, 54)
	add_child(_icon)

	_initials = Label.new()
	_initials.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_initials.position = Vector2(0, 4)
	_initials.size = Vector2(64, 42)
	_initials.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_initials.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_initials.add_theme_font_size_override("font_size", 20)
	add_child(_initials)

	_badge = Label.new()
	_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_badge.position = Vector2(2, 44)
	_badge.size = Vector2(58, 18)
	_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_badge.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	_badge.add_theme_font_size_override("font_size", 13)
	add_child(_badge)

	_refresh()


func configure(talent: TalentData, tree_color: Color, rank: int) -> void:
	_talent = talent
	_tree_color = tree_color
	_rank = rank
	if is_node_ready():
		_refresh()


func set_rank(rank: int) -> void:
	_rank = rank
	if is_node_ready():
		_refresh()


func _gui_input(event: InputEvent) -> void:
	if not _talent:
		return
	if event is InputEventMouseButton and event.pressed:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			left_clicked.emit(_talent.id)
			accept_event()
		elif mb.button_index == MOUSE_BUTTON_RIGHT:
			right_clicked.emit(_talent.id)
			accept_event()


func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	draw_rect(rect, Color(0.05, 0.06, 0.09, 1.0), true)

	var border := Color(0.3, 0.3, 0.35)
	if _talent:
		if _rank > 0 and _rank >= _talent.max_rank:
			border = Color(1.0, 0.84, 0.2)
		elif _rank > 0:
			border = _tree_color.lightened(0.2)
	draw_rect(rect, border, false, 3.0)


func _refresh() -> void:
	if not _talent:
		return

	_initials.text = _compute_initials(_talent.display_name)

	var maxed := _rank > 0 and _rank >= _talent.max_rank
	if _rank <= 0:
		_icon.color = _tree_color.darkened(0.6)
		_initials.modulate = Color(0.6, 0.6, 0.65)
	else:
		_icon.color = _tree_color.darkened(0.15)
		_initials.modulate = Color.WHITE

	_badge.text = "%d/%d" % [_rank, _talent.max_rank]
	_badge.modulate = Color(1.0, 0.84, 0.2) if maxed else Color(0.85, 0.85, 0.9)

	tooltip_text = _build_tooltip()
	queue_redraw()


func _build_tooltip() -> String:
	var lines := PackedStringArray()
	lines.append(_talent.display_name)
	lines.append("Rank %d / %d" % [_rank, _talent.max_rank])
	if not _talent.description.is_empty():
		lines.append(_talent.description)
	for mod in _talent.effect_modifiers:
		if mod and not mod.display_name.is_empty():
			lines.append(mod.display_name)
	if _talent.unlock_spell:
		lines.append("Unlocks: %s" % _talent.unlock_spell.display_name)
	return "\n".join(lines)


func _compute_initials(display_name: String) -> String:
	var parts := display_name.split(" ", false)
	var out := ""
	for part in parts:
		if part.length() > 0:
			out += part.substr(0, 1).to_upper()
		if out.length() >= 2:
			break
	return out
