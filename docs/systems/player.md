# Player System

Status: In Progress

## Goal

Represent the player character during a survivor-style Run. Own movement, input, health, mana, and character-facing state. Expose interfaces to Run, Combat, Stats, and Skills without owning their internals.

## Components

- Movement
- Input handling
- Health
- Mana
- In-run experience and level
- Character statistics (via Stats system)
- Spell interface (via Skills system)
- Animation

## Current Status

- [x] Movement controller (M1)
- [x] Input mapping (project settings, not hardcoded) (M1)
- [x] Health component (M1, wired through Combat in M2)
- [x] Mana component (M1)
- [x] XP / level tracking (M4 via RunManager; Player forwards `gain_experience`)
- [x] Stats integration (M2 minimal StatsBlock from StatsData; M4 attack_power scaling + BuffContainer)
- [x] Skills / Spell integration (M2 left-click basic_fireball; M4 RunSpellController for temp spells)
- [ ] Animation state machine
- [x] Character stats ownership and display expectations documented

## Implemented in M1

- `systems/player/player.gd` extends `CharacterBody2D` with WASD + gamepad left-stick top-down movement using `Input.get_vector`.
- `systems/player/Player.tscn` contains `CharacterBody2D` + `Sprite2D` (PlaceholderTexture2D 32x32) + `CollisionShape2D` + `Camera2D`.
- `scenes/arena/Arena.tscn` provides a test arena with a placeholder background and an instanced Player. Run with F6 for M1 verification; `Main.tscn` remains the project's main scene.
- M2 adds a **Spawn Enemy** test button (top-left) that spawns another `test_grunt` at a random position around the player. **Removed in M3** — replaced by automatic `HordeSpawner`.
- Health and mana runtime values print on `_ready()` and on every change until a HUD is added later.
- Placeholder max values (`base_max_health`, `base_max_mana`, `base_move_speed`) are `@export`ed on Player. They will migrate into `StatsData` when the Stats system is implemented.

## Design Rules

- Player does NOT manage enemies or UI.
- Player exposes signals for damage taken, died, leveled up.
- Player reads stats from the Stats System — it does not own permanent stats.
- Player owns `BuffContainer` for run-only Buffs and `RunSpellController` for temporary run Spells.
- Manual left-click damage scales with `attack_power` from Stats (`base_damage * attack_power / 100`).
- Player owns current health and current mana during play, but maximum health, maximum mana, regeneration, attack-facing values, and scaling values come from Stats.
- Mana is consumed only by talent-granted Spells.
- Temporary level-up Spells do not use mana and are cleared by the Run system at run end.
- XP gain belongs to the current Run. Permanent progression is saved only after run end.
- Input actions are named (`move_left`, `attack`, `interact`), never keycodes in code.
- Movement is deterministic and testable.
- Player has collision with enemies via physics (`collision_mask` includes enemy layer). Both Player and Enemy use `MOTION_MODE_FLOATING` (top-down — no platform/floor carry).
- When the player presses into overlapping enemies, `EntityCollision.apply_player_pushback` nudges them along the separation axis (input-driven, uses slide collisions + touch range, ~1.2–1.6 px/frame).
- Player position is clamped to `MapData.play_area_rect` via `EntityCollision.clamp_body_to_play_area` (hull inset by collision radius).

## Character Stats

The player character's normal out-of-run stats are the result of:

- Base character stats.
- Permanent Talent passive modifiers.
- Equipped item modifiers, later.
- Future permanent progression modifiers.

During a run, the Player reads the current final Stats values, which may also include temporary run modifiers from chosen skills, run-only Buffs, or temporary run items. When the run ends, temporary modifiers are cleared by their owning systems and Player returns to the normal out-of-run stat state.

The Player should expose access to its `StatsBlock` for UI and gameplay systems, but the Character Stats screen must read display values from Stats rather than duplicating Player-side calculations.

## Public API

```gdscript
signal player_damaged(amount: float)
signal player_died()
signal player_leveled_up(new_level: int)
signal mana_changed(current_mana: float, max_mana: float)

func take_damage(damage_event: DamageEvent) -> void
func gain_experience(amount: int) -> void
func spend_mana(amount: float) -> bool
func restore_mana(amount: float) -> void
func apply_buff(data: BuffData) -> void
func grant_run_spell(spell: SpellData) -> void
func clear_run_powers() -> void
func get_active_run_spells() -> Array[SpellData]
func get_active_run_buffs() -> Array[BuffData]
func get_stats() -> StatsBlock
```

## Dependencies

- Stats (reads modifiers)
- Combat (receives DamageEvents)
- Run (XP, level-up flow, run end)
- Skills (casts talent-granted Spells and temporary Spells)
- Buffs (receives temporary and permanent modifiers)

## Open Questions

- Exact movement model: free top-down movement assumed, final feel TBD.
- Sprint / dodge mechanics?
- Does the player have a default automatic attack, manual spell casting, or both?

## References

- [../ARCHITECTURE.md](../ARCHITECTURE.md#player-system)
