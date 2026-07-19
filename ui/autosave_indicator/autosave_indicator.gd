## Small non-blocking indicator. Fades in when SaveManager autosaves and
## fades out shortly after completion. Never intercepts input.
extends Control

const VISIBLE_DURATION := 1.6

@onready var _label: Label = $Label

var _fade_timer: SceneTreeTimer


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	modulate.a = 0.0
	SaveManager.autosave_started.connect(_on_autosave_started)
	SaveManager.autosave_completed.connect(_on_autosave_completed)
	SaveManager.save_failed.connect(_on_save_failed)


func _on_autosave_started(_slot: int) -> void:
	_label.text = "Saving..."
	_label.modulate = Color(1, 1, 1, 1)
	modulate.a = 1.0


func _on_autosave_completed(_slot: int) -> void:
	_label.text = "Saved"
	modulate.a = 1.0
	_schedule_fade()


func _on_save_failed(_slot: int, _reason: String) -> void:
	_label.text = "Save failed"
	_label.modulate = Color(1.0, 0.5, 0.5)
	modulate.a = 1.0
	_schedule_fade()


func _schedule_fade() -> void:
	_fade_timer = get_tree().create_timer(VISIBLE_DURATION)
	_fade_timer.timeout.connect(_fade_out, CONNECT_ONE_SHOT)


func _fade_out() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
