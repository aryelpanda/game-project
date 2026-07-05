## Main boot scene. Starts the M3 run loop via RunManager.
extends Node


func _ready() -> void:
	RunManager.start_run(&"test_arena", &"default")
