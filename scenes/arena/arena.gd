## Test arena for M1 movement and M2/M3 combat. Hosts HordeSpawner and run UI.
extends Node2D

@onready var _horde_spawner: HordeSpawner = $HordeSpawner


func _ready() -> void:
	var map_data := World.get_current_map_data()
	if map_data:
		_horde_spawner.map_data = map_data

	World.notify_map_ready()
