# Audio System

Status: In Progress

## Goal

Play music and sound effects. Manage buses, volumes, and mixing. Fully decoupled from gameplay.

## Components

- AudioManager (autoload)
- Music playback and crossfade
- SFX playback (2D/3D positional)
- Audio buses (Master, Music, SFX, UI, Ambience)
- Volume settings (persisted)

## Current Status

- [x] AudioManager autoload stub registered
- [ ] Bus setup
- [ ] Music playback with crossfade
- [ ] SFX playback (pooled voices)
- [ ] Volume options integration
- [ ] Save integration for volume preferences

## Design Rules

- Audio is triggered by signals from other systems (e.g. `Combat.hit_landed`, `Enemy.enemy_died`).
- Audio never queries gameplay state. It reacts.
- SFX voices are pooled — never `AudioStreamPlayer.new()` in hot paths.
- Music transitions are declarative (`AudioManager.play_music(track)`), not scripted per-scene.

## Public API

```gdscript
class_name AudioManager  # autoload

func play_music(track: AudioStream, fade_time: float = 1.0) -> void
func stop_music(fade_time: float = 1.0) -> void
func play_sfx(stream: AudioStream, position: Vector2 = Vector2.ZERO, volume_db: float = 0.0) -> void
func set_bus_volume(bus: StringName, volume_db: float) -> void
```

## Dependencies

- Combat, Enemies, Player, UI (subscribers as signal emitters).
- Save (volume settings persist).

## Open Questions

- Adaptive music (layers, stems) or linear tracks?
- 3D positional audio needs — depends on [../VISION.md](../VISION.md) perspective decision.

## References

- [../ARCHITECTURE.md](../ARCHITECTURE.md#audio-system)
