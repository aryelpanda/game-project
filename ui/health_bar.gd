## Simple placeholder health bar for M2 combat testing.
extends Control

const BAR_WIDTH := 40.0
const BAR_HEIGHT := 6.0

@export var fill_color: Color = Color(0.2, 0.85, 0.3, 1.0)

@onready var _fill: ColorRect = $Fill


func _ready() -> void:
	custom_minimum_size = Vector2(BAR_WIDTH, BAR_HEIGHT)
	position = Vector2(-BAR_WIDTH * 0.5, -28.0)
	if _fill:
		_fill.color = fill_color


func update_values(current: float, maximum: float) -> void:
	var ratio := 0.0
	if maximum > 0.0:
		ratio = clampf(current / maximum, 0.0, 1.0)
	_fill.size = Vector2(BAR_WIDTH * ratio, BAR_HEIGHT)
