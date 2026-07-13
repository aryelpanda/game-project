## Minimal level-up overlay with three reward choices.
extends Control

const EFFECT_COLOR := Color(0.35, 0.92, 0.45)

@onready var _title_label: Label = $Panel/VBox/TitleLabel
@onready var _choices_container: VBoxContainer = $Panel/VBox/ChoicesContainer


func _ready() -> void:
	hide()
	RunManager.level_up_available.connect(_on_level_up_available)


func _on_level_up_available(options: Array) -> void:
	_clear_choices()
	_title_label.text = "Level Up! Choose one reward"
	for option in options:
		_add_choice_card(option)
	show()


func _add_choice_card(option: Dictionary) -> void:
	var reward_type := String(option.get("type", ""))
	var display_name := String(option.get("display_name", ""))
	var description := String(option.get("description", ""))
	var effect_text := String(option.get("effect_text", ""))
	var reward_id: StringName = option.get("id", &"")

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(440, 72)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_on_choice_pressed(reward_id)
	)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 8)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(vbox)

	var header := Label.new()
	header.text = "%s: %s" % [reward_type.capitalize(), display_name]
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(header)

	if not description.is_empty():
		var desc_label := Label.new()
		desc_label.text = description
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.add_child(desc_label)

	if not effect_text.is_empty():
		var effect_label := Label.new()
		effect_label.text = effect_text
		effect_label.add_theme_color_override("font_color", EFFECT_COLOR)
		effect_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		effect_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.add_child(effect_label)

	_choices_container.add_child(panel)


func _on_choice_pressed(reward_id: StringName) -> void:
	RunManager.choose_level_up_reward(reward_id)
	hide()
	_clear_choices()


func _clear_choices() -> void:
	for child in _choices_container.get_children():
		child.queue_free()
