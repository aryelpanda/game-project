## Placeholder shown from Profile Hub. Inventory is de-prioritized (see docs).
extends Control

@onready var _back_btn: Button = $Layout/Footer/BackButton


func _ready() -> void:
	_back_btn.pressed.connect(func() -> void: UIManager.pop_screen())
