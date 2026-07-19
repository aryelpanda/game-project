## Reusable yes/no confirm dialog. Emits `confirmed` / `cancelled` and self-frees.
class_name UIConfirmDialog
extends Control

signal confirmed()
signal cancelled()

@export var title: String = "Confirm":
	set(value):
		title = value
		if is_inside_tree():
			_title_label.text = value
@export var body: String = "Are you sure?":
	set(value):
		body = value
		if is_inside_tree():
			_body_label.text = value
@export var confirm_text: String = "Confirm":
	set(value):
		confirm_text = value
		if is_inside_tree():
			_confirm_button.text = value
@export var cancel_text: String = "Cancel":
	set(value):
		cancel_text = value
		if is_inside_tree():
			_cancel_button.text = value

@onready var _title_label: Label = $Panel/VBox/TitleLabel
@onready var _body_label: Label = $Panel/VBox/BodyLabel
@onready var _confirm_button: Button = $Panel/VBox/ButtonRow/ConfirmButton
@onready var _cancel_button: Button = $Panel/VBox/ButtonRow/CancelButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_title_label.text = title
	_body_label.text = body
	_confirm_button.text = confirm_text
	_cancel_button.text = cancel_text
	_confirm_button.pressed.connect(_on_confirm)
	_cancel_button.pressed.connect(_on_cancel)


func configure(title_text: String, body_text: String, confirm_label: String = "Confirm", cancel_label: String = "Cancel") -> void:
	title = title_text
	body = body_text
	confirm_text = confirm_label
	cancel_text = cancel_label


func _on_confirm() -> void:
	confirmed.emit()
	UIManager.pop_modal()


func _on_cancel() -> void:
	cancelled.emit()
	UIManager.pop_modal()
