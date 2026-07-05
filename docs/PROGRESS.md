# PROGRESS.md

Version: 0.15

> Snapshot of where every system stands. Update this in the SAME change that advances a system (see [.cursor/rules/80-docs-sync.mdc](../.cursor/rules/80-docs-sync.mdc)).

## Status Legend

| Status        | Meaning                                                                       |
| ------------- | ----------------------------------------------------------------------------- |
| Not Started   | No code, no design detail beyond the system doc stub.                         |
| In Progress   | Actively being built. Not usable end-to-end.                                  |
| MVP           | Minimum viable: works for its role in the current milestone. Rough edges OK.  |
| Stable        | Feature-complete for near-term needs. Documented. No known blocking bugs.     |
| Locked        | Frozen for the current milestone. Changes require explicit approval.          |

---

## Systems Status

| # | System        | Doc                                          | Code Folder             | Status       | Last Touched | Notes |
| - | ------------- | -------------------------------------------- | ----------------------- | ------------ | ------------ | ----- |
| 1  | Core         | [systems/core.md](systems/core.md)           | `systems/core/`         | In Progress  | 2026-07-03   | M0 skeleton verified booting to black screen; state machine and scene transitions still stubs. |
| 2  | Run          | [systems/run.md](systems/run.md)             | `systems/run/`          | MVP          | 2026-07-04   | M4: XP/leveling, level-up choices, RewardPoolData, RunProgressionData, temp reward apply/clear. |
| 3  | Player       | [systems/player.md](systems/player.md)       | `systems/player/`       | MVP          | 2026-07-04   | M4: BuffContainer, RunSpellController, attack_power scaling on manual cast. |
| 4  | Enemies      | [systems/enemies.md](systems/enemies.md)     | `systems/enemies/`      | MVP          | 2026-07-04   | M3 horde loop; pool init fix — idle enemies disable collision via `reset_for_pool()`. |
| 5  | Combat       | [systems/combat.md](systems/combat.md)       | `systems/combat/`       | MVP          | 2026-07-04   | M2: DamageEvent + DamageManager autoload; armor stub; crit/dodge stubbed. |
| 6  | Weapons      | [systems/weapons.md](systems/weapons.md)     | `systems/weapons/`      | Not Started  | —            | De-prioritized for early survivor MVP unless needed. |
| 7  | Projectiles  | [systems/projectiles.md](systems/projectiles.md) | `systems/projectiles/` | MVP          | 2026-07-04   | M2: ProjectileData, pooled Projectile scene, ProjectileManager autoload. |
| 8  | Items        | [systems/items.md](systems/items.md)         | `systems/items/`        | Not Started  | —            | De-prioritized for early survivor MVP. |
| 9  | Inventory    | [systems/inventory.md](systems/inventory.md) | `systems/inventory/`    | Not Started  | —            | Not part of early core loop unless later approved. |
| 10 | Equipment    | [systems/equipment.md](systems/equipment.md) | `systems/equipment/`    | Not Started  | —            | Not part of early core loop unless later approved. |
| 11 | Stats        | [systems/stats.md](systems/stats.md)         | `systems/stats/`        | In Progress  | 2026-07-04   | M4: StatModifier + flat/percent_add pipeline in StatsBlock. |
| 12 | Skills       | [systems/skills.md](systems/skills.md)       | `systems/skills/`       | In Progress  | 2026-07-04   | M4: spell_type, RunSpellController, orbit/auto executors; talent trees TODO. |
| 13 | Buffs        | [systems/buffs.md](systems/buffs.md)         | `systems/buffs/`        | MVP          | 2026-07-04   | M4: BuffData, BuffContainer, run-only apply/remove via Player. |
| 14 | Loot         | [systems/loot.md](systems/loot.md)           | `systems/loot/`         | Not Started  | —            | XP rewards may be separate from item loot. |
| 15 | World        | [systems/world.md](systems/world.md)         | `systems/world/`        | MVP          | 2026-07-04   | M3: World autoload, MapData, SpawnCurveData, HordeSpawner, test_arena map content. |
| 16 | Save         | [systems/save.md](systems/save.md)           | `systems/save/`         | In Progress  | 2026-07-03   | SaveManager autoload stub and talent progression save shape documented; save runtime not implemented. |
| 17 | UI           | [systems/ui.md](systems/ui.md)               | `systems/ui/`           | In Progress  | 2026-07-04   | M4: RunHud XP/level, LevelUpChoiceScreen, RunPowersPanel with debug grant-all. |
| 18 | Audio        | [systems/audio.md](systems/audio.md)         | `systems/audio/`        | In Progress  | 2026-07-03   | AudioManager autoload stub added; audio runtime not implemented. |
| 19 | VFX          | [systems/vfx.md](systems/vfx.md)             | `systems/vfx/`          | Not Started  | —            |       |
| 20 | Debug        | [systems/debug.md](systems/debug.md)         | `systems/debug/`        | Not Started  | —            |       |

---

## Current Milestone

Active milestone: **M5 — Data-Driven Content** (see [ROADMAP.md](ROADMAP.md)). M0–M4 are Done.

**M5 status:** Design approved for first map ([Five Minute Gauntlet](content/maps.md)). **Implementation not started** — waiting for explicit approval to create `m5-data-driven-content` branch.

Blocking issues: _(none yet)_

---

## How To Update

When a system changes state:

1. Update the row in the table above.
2. Set "Last Touched" to today's date (YYYY-MM-DD).
3. Add a short "Notes" entry if useful (e.g. "Only spawner implemented; behaviors TODO").
4. If a milestone item was completed, check it off in [ROADMAP.md](ROADMAP.md).

## Changelog

- v0.15 - M5 Five Minute Gauntlet design approved; implementation not started.
- v0.14 - M4 XP & Level-Up Choices: BuffData, StatModifier, RewardPoolData, RunProgressionData, level-up UI, RunPowersPanel, three test rewards. Active milestone advanced to M5.
- v0.13 - M3 Horde & Run Loop: RunManager + World autoloads, MapData/SpawnCurveData, HordeSpawner, run HUD/summary UI, test_arena content. Active milestone advanced to M4.
- v0.11 - enemies system design revised: per-enemy stat block and required skill(s) documented; runtime still not started.
- v0.10 - M1 Player Prototype implemented (movement, camera, placeholder sprite, health/mana debug prints, test arena). Active milestone advanced to M2.
- v0.9 - M0 skeleton verified booting; Godot 4.7 stable pinned in `project.godot` and `TECH_STACK.md`. Active milestone advanced to M1.
- v0.8 - created Godot M0 skeleton, folder layout, autoload stubs, main scene, git repository, and `.gitignore`; Godot editor launch test pending.
- v0.7 - documented Character Stats screen, stat layers, and permanent vs temporary modifier display.
- v0.6 - documented first-pass Talent Trees design across Skills, Buffs, Save, UI, and M7 roadmap notes.
- v0.5 - added Profile Main Screen / hub and Map Selection notes.
- v0.4 - added Run History notes for Run, Combat, Save, and UI.
- v0.3 - updated Run, Save, and UI notes for slots, autosave, checkpoints, and resume/forfeit.
- v0.2 - added Run system and survivor-specific notes while keeping all systems Not Started.
- v0.1 - initial template
