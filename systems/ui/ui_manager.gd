## UIManager will coordinate top-level screens, modals, and notifications.
extends Node

var _screen_stack: Array[Control] = []


func push_screen(scene: PackedScene) -> Control:
	if scene == null:
		push_warning("UIManager.push_screen called with a null scene.")
		return null

	var screen := scene.instantiate()
	if not screen is Control:
		push_warning("UIManager.push_screen expected a Control scene.")
		screen.queue_free()
		return null

	get_tree().root.add_child(screen)
	_screen_stack.append(screen)
	return screen


func pop_screen() -> void:
	if _screen_stack.is_empty():
		return

	var screen := _screen_stack.pop_back() as Control
	if is_instance_valid(screen):
		screen.queue_free()


func show_toast(message: String, duration: float = 3.0) -> void:
	if message.is_empty():
		return

	push_warning("UIManager.show_toast is not implemented yet: %s" % message)


func show_save_slot_select(slots: Array) -> void:
	push_warning("UIManager.show_save_slot_select is not implemented yet.")


func show_profile_main_screen(slot: int) -> void:
	push_warning("UIManager.show_profile_main_screen is not implemented yet.")
