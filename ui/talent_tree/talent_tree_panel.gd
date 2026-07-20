## One Talent Tree column (a magic school). Positions TalentNodes on a
## tier/column grid and draws prerequisite arrows behind them.
class_name TalentTreePanel
extends VBoxContainer

signal talent_activated(talent_id: StringName, refund: bool)

const NODE_SIZE := 64
const COL_STRIDE := 84
const ROW_STRIDE := 88
const GRID_MARGIN := 8
const GRID_COLUMNS := 4

var _tree: TalentTreeData
var _nodes: Dictionary = {}  # StringName talent_id -> TalentNode
var _spent_label: Label
var _grid: TalentTreeGrid


func configure(tree: TalentTreeData) -> void:
	_tree = tree
	_build()


func refresh() -> void:
	for talent_id in _nodes.keys():
		(_nodes[talent_id] as TalentNode).set_rank(TalentManager.get_rank(talent_id))
	if _spent_label:
		_spent_label.text = "Spent: %d" % TalentManager.spent_points(_tree.id)


func _build() -> void:
	add_theme_constant_override("separation", 6)

	var header := Label.new()
	header.text = _tree.display_name
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 20)
	header.modulate = _tree.theme_color
	add_child(header)

	_spent_label = Label.new()
	_spent_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_spent_label.modulate = Color(0.8, 0.8, 0.85)
	add_child(_spent_label)

	_grid = TalentTreeGrid.new()
	var max_tier := 0
	for talent in _tree.talents:
		max_tier = maxi(max_tier, talent.tier)
	_grid.custom_minimum_size = Vector2(
		GRID_COLUMNS * COL_STRIDE + GRID_MARGIN,
		(max_tier + 1) * ROW_STRIDE + GRID_MARGIN
	)
	add_child(_grid)

	for talent in _tree.talents:
		var node := TalentNode.new()
		_grid.add_child(node)
		node.position = _node_position(talent)
		node.configure(talent, _tree.theme_color, TalentManager.get_rank(talent.id))
		node.left_clicked.connect(_on_node_left)
		node.right_clicked.connect(_on_node_right)
		_nodes[talent.id] = node

	_update_segments()
	refresh()


func _node_position(talent: TalentData) -> Vector2:
	return Vector2(
		GRID_MARGIN + talent.column * COL_STRIDE,
		GRID_MARGIN + talent.tier * ROW_STRIDE
	)


func _update_segments() -> void:
	var segments: Array = []
	for talent in _tree.talents:
		if talent.requires == &"" or not _nodes.has(talent.requires):
			continue
		var from_node: TalentNode = _nodes[talent.requires]
		var to_node: TalentNode = _nodes[talent.id]
		segments.append({
			"from": from_node.position + Vector2(NODE_SIZE * 0.5, NODE_SIZE),
			"to": to_node.position + Vector2(NODE_SIZE * 0.5, 0),
		})
	_grid.set_segments(segments)


func _on_node_left(talent_id: StringName) -> void:
	talent_activated.emit(talent_id, false)


func _on_node_right(talent_id: StringName) -> void:
	talent_activated.emit(talent_id, true)
