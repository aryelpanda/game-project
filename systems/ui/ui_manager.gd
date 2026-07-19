## Owns the top-level screen stack, modals, and toasts on a persistent CanvasLayer.
## UI never mutates gameplay state directly — it emits input, gameplay reacts.
extends Node

signal screen_pushed(screen: Control)
signal screen_popped(screen: Control)

const CANVAS_LAYER := 100
const MODAL_LAYER := 110

var _screen_layer: CanvasLayer
var _modal_layer: CanvasLayer
var _screen_stack: Array[Control] = []
var _modal_stack: Array[Control] = []


func _ready() -> void:
	_screen_layer = CanvasLayer.new()
	_screen_layer.name = "UIScreens"
	_screen_layer.layer = CANVAS_LAYER
	add_child(_screen_layer)

	_modal_layer = CanvasLayer.new()
	_modal_layer.name = "UIModals"
	_modal_layer.layer = MODAL_LAYER
	_modal_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_modal_layer)


# ---- Screens (fullscreen stacked) ---------------------------------------


func push_screen(scene: PackedScene) -> Control:
	if scene == null:
		push_warning("UIManager.push_screen called with a null scene.")
		return null

	var screen := _instance_control(scene)
	if screen == null:
		return null

	if not _screen_stack.is_empty():
		var top := _screen_stack.back() as Control
		if is_instance_valid(top):
			top.hide()

	_screen_layer.add_child(screen)
	_screen_stack.append(screen)
	screen_pushed.emit(screen)
	return screen


func replace_screen(scene: PackedScene) -> Control:
	clear_screens()
	return push_screen(scene)


func pop_screen() -> void:
	if _screen_stack.is_empty():
		return

	var screen := _screen_stack.pop_back() as Control
	if is_instance_valid(screen):
		screen_popped.emit(screen)
		screen.queue_free()

	if not _screen_stack.is_empty():
		var top := _screen_stack.back() as Control
		if is_instance_valid(top):
			top.show()


func clear_screens() -> void:
	while not _screen_stack.is_empty():
		var screen := _screen_stack.pop_back() as Control
		if is_instance_valid(screen):
			screen_popped.emit(screen)
			screen.queue_free()


func current_screen() -> Control:
	if _screen_stack.is_empty():
		return null
	return _screen_stack.back() as Control


# ---- Modals (drawn above screens, do NOT hide the screen behind) --------


func push_modal(scene: PackedScene) -> Control:
	if scene == null:
		push_warning("UIManager.push_modal called with a null scene.")
		return null

	var modal := _instance_control(scene)
	if modal == null:
		return null

	_modal_layer.add_child(modal)
	_modal_stack.append(modal)
	return modal


func pop_modal() -> void:
	if _modal_stack.is_empty():
		return
	var modal := _modal_stack.pop_back() as Control
	if is_instance_valid(modal):
		modal.queue_free()


func clear_modals() -> void:
	while not _modal_stack.is_empty():
		pop_modal()


# ---- Toast (non-blocking, top-right) ------------------------------------


func show_toast(message: String, duration: float = 3.0) -> void:
	if message.is_empty():
		return

	var toast := Label.new()
	toast.text = message
	toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	toast.position = Vector2(24, 24)
	toast.z_index = 100
	_modal_layer.add_child(toast)

	var timer := get_tree().create_timer(duration)
	timer.timeout.connect(func() -> void:
		if is_instance_valid(toast):
			toast.queue_free()
	)


# ---- Helpers ------------------------------------------------------------


func _instance_control(scene: PackedScene) -> Control:
	if scene == null:
		push_warning("UIManager: _instance_control called with a null PackedScene.")
		return null

	var node := scene.instantiate()
	if node == null:
		# Empty PackedScene stubs (e.g. from a broken import) instantiate to null.
		push_warning("UIManager: instantiate() returned null for scene %s" % scene.resource_path)
		return null
	if not node is Control:
		push_warning("UIManager: expected a Control scene, got %s" % node.get_class())
		node.queue_free()
		return null
	return node as Control
