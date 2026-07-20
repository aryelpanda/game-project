## Draws the Talent Tree panel background and the connector arrows between a
## Talent and its prerequisite (decorative in the free-spend MVP). TalentNodes
## are added as children on top of this Control.
class_name TalentTreeGrid
extends Control

var _segments: Array = []  # each: { "from": Vector2, "to": Vector2 }
var _line_color: Color = Color(0.55, 0.55, 0.65, 0.7)


func set_segments(segments: Array) -> void:
	_segments = segments
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.09, 0.10, 0.15, 0.6), true)
	for seg in _segments:
		var a: Vector2 = seg["from"]
		var b: Vector2 = seg["to"]
		draw_line(a, b, _line_color, 2.0)
		_draw_arrow_head(a, b)


func _draw_arrow_head(a: Vector2, b: Vector2) -> void:
	var dir := (b - a).normalized()
	if dir == Vector2.ZERO:
		return
	var head := 8.0
	var left := b - dir.rotated(0.5) * head
	var right := b - dir.rotated(-0.5) * head
	draw_colored_polygon(PackedVector2Array([b, left, right]), _line_color)
