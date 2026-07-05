## AudioManager will coordinate music, sound effects, and audio settings.
extends Node


func play_music(track: AudioStream, fade_time: float = 1.0) -> void:
	if track == null:
		push_warning("AudioManager.play_music called with a null track.")
		return

	push_warning("AudioManager.play_music is not implemented yet.")


func stop_music(fade_time: float = 1.0) -> void:
	push_warning("AudioManager.stop_music is not implemented yet.")


func play_sfx(stream: AudioStream, position: Vector2 = Vector2.ZERO, volume_db: float = 0.0) -> void:
	if stream == null:
		push_warning("AudioManager.play_sfx called with a null stream.")
		return

	push_warning("AudioManager.play_sfx is not implemented yet.")


func set_bus_volume(bus: StringName, volume_db: float) -> void:
	if bus == &"":
		push_warning("AudioManager.set_bus_volume called with an empty bus.")
		return

	var bus_index := AudioServer.get_bus_index(bus)
	if bus_index == -1:
		push_warning("Audio bus does not exist: %s" % bus)
		return

	AudioServer.set_bus_volume_db(bus_index, volume_db)
