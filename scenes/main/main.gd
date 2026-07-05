## Main boot scene. Starts the M5 Five Minute Gauntlet run via RunManager.
extends Node


func _ready() -> void:
	RunManager.start_run(&"five_minute_gauntlet", &"default")
