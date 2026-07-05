# Debug System

Status: Not Started

## Goal

Developer-only tools for testing, spawning, inspecting, and profiling. NEVER shipped in release builds.

## Components

- Debug console / command palette
- Spawn commands (enemies, items, currency)
- Stat inspectors and overlays
- Performance overlay (FPS, draw calls, physics ticks)
- Save state inspector
- Cheat toggles (invincibility, one-shot kills)

## Current Status

- [ ] Debug console
- [ ] Command registry
- [ ] Spawn commands
- [ ] Stats overlay
- [ ] Performance overlay
- [ ] Build-mode gating

## Design Rules

- Debug tools MUST be gated behind a build flag or feature tag and STRIPPED from release builds.
- Debug never depends on release code. Release code never depends on Debug.
- Commands are registered from their owning systems, not hardcoded in Debug.
- Debug UI is a distinct scene, not entangled with the game HUD.

## Public API

```gdscript
class_name Debug  # autoload, only when enabled

func register_command(name: StringName, callable: Callable, help: String) -> void
func log(message: String) -> void
func toggle_overlay(overlay: StringName) -> void
```

Systems register their own debug commands during boot:

```gdscript
func _ready() -> void:
    if OS.is_debug_build():
        Debug.register_command(&"spawn_enemy", Callable(self, "_debug_spawn"), "Spawn an enemy by ID.")
```

## Dependencies

- Reads from every system. No system reads from Debug.

## Open Questions

- Console UI style — command bar overlay or full panel?
- Persist debug commands across sessions?

## References

- [../ARCHITECTURE.md](../ARCHITECTURE.md#debug-system)
