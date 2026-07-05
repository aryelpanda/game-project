## Minimal level-up overlay with three reward choices.
extends Control

@onready var _title_label: Label = $Panel/VBox/TitleLabel
@onready var _choices_container: VBoxContainer = $Panel/VBox/ChoicesContainer


func _ready() -> void:
	hide()
	RunManager.level_up_available.connect(_on_level_up_available)


func _on_level_up_available(options: Array) -> void:
	_clear_choices()
	_title_label.text = "Level Up! Choose one reward"
	for option in options:
		_add_choice_button(option)
	show()


func _add_choice_button(option: Dictionary) -> void:
	var button := Button.new()
	var reward_type := String(option.get("type", ""))
	var display_name := String(option.get("display_name", ""))
	var description := String(option.get("description", ""))
	button.text = "%s: %s\n%s" % [reward_type.capitalize(), display_name, description]
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.custom_minimum_size = Vector2(420, 64)
	var reward_id: StringName = option.get("id", &"")
	button.pressed.connect(func(): _on_choice_pressed(reward_id))
	_choices_container.add_child(button)


func _on_choice_pressed(reward_id: StringName) -> void:
	RunManager.choose_level_up_reward(reward_id)
	hide()
	_clear_choices()


func _clear_choices() -> void:
	for child in _choices_container.get_children():
		child.queue_free()
