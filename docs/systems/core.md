# Core System

Status: In Progress

## Goal

Initialize the game, own top-level state, and coordinate scene transitions. The Core system does NOT contain gameplay logic.

## Components

- Boot / initialization
- Global game state (enum: MainMenu, InGame, Paused, GameOver)
- Scene transitions
- Global configuration
- Time management (pause, time scale)

## Current Status

- [ ] Boot flow
- [ ] Game state enum + transitions
- [ ] Scene transition helper
- [ ] Global time / pause handling
- [ ] Configuration loader
- [x] Core autoload stub registered
- [x] Empty boot scene scaffolded

## Design Rules

- Core is an autoload singleton.
- Core does not know about specific gameplay systems.
- Other systems observe Core state via signals, not by importing Core internals.
- Time scale and pause changes go through Core, never directly.

## Public API

_(TODO: fill in as implementation lands.)_

```gdscript
signal game_state_changed(new_state: int)

enum GameState { BOOT, MAIN_MENU, IN_GAME, PAUSED, GAME_OVER }

func change_state(new_state: GameState) -> void
func transition_to_scene(path: String) -> void
func set_paused(paused: bool) -> void
```

## Dependencies

- None inbound. Every other system may depend on Core.

## Open Questions

- Do we need a loading screen scene, or fade-based transitions?
- How is the main menu wired — its own scene, or a UI layer?

## References

- [../ARCHITECTURE.md](../ARCHITECTURE.md#core-system)
- [../SYSTEM_MAP.md](../SYSTEM_MAP.md)
