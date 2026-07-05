# SYSTEM_MAP.md

Version: 0.10

> Index of every system. The AI reads this first to know where things live. Keep it accurate. When a system is added, renamed, or removed, this file MUST be updated in the same change.

## How to Read This File

Each row lists a system, its design doc, its code folder, and a one-line responsibility. For deep detail on any system, open its doc.

## Foundational Documents

| Doc                                                     | Purpose                                                    |
| ------------------------------------------------------- | ---------------------------------------------------------- |
| [VISION.md](VISION.md)                                  | What the game is and is not.                               |
| [ARCHITECTURE.md](ARCHITECTURE.md)                      | System boundaries and responsibilities.                    |
| [ROADMAP.md](ROADMAP.md)                                | Milestone plan.                                            |
| [PROGRESS.md](PROGRESS.md)                              | Current status of each system.                             |
| [TECH_STACK.md](TECH_STACK.md)                          | Approved tools, formats, and technical constraints.        |
| [AI_RULES.md](AI_RULES.md)                              | Human-readable rules (enforcement is in `.cursor/rules/`). |
| [CONTENT.md](CONTENT.md)                                | Where content data (Resources / JSON) lives.               |
| [content/maps.md](content/maps.md)                      | Index of map gameplay designs.                             |
| [content/map_design_template.md](content/map_design_template.md) | Template for AI-assisted map gameplay design.      |
| [GLOSSARY.md](GLOSSARY.md)                              | Canonical terminology.                                     |
| [Cursor_AI_Game_Documentation_Guide.md](Cursor_AI_Game_Documentation_Guide.md) | How docs are organized (reference).       |

## Systems Index

| System       | Doc                                                | Code Folder             | Responsibility (one line)                                                         |
| ------------ | -------------------------------------------------- | ----------------------- | --------------------------------------------------------------------------------- |
| Core         | [systems/core.md](systems/core.md)                 | `systems/core/`         | Initialization, game state, scene transitions, global time.                       |
| Run          | [systems/run.md](systems/run.md)                   | `systems/run/`          | Run lifecycle after hub/map selection, checkpoints, stats, history, rewards.      |
| Player       | [systems/player.md](systems/player.md)             | `systems/player/`       | Movement, input, health, mana, in-run XP/level state, character interface.        |
| Enemies      | [systems/enemies.md](systems/enemies.md)           | `systems/enemies/`      | Horde spawning, chase behavior, death, XP awards, per-enemy stat blocks, per-enemy skills. |
| Combat       | [systems/combat.md](systems/combat.md)             | `systems/combat/`       | Damage calculation, hit detection, damage events, per-Spell result signals.       |
| Weapons      | [systems/weapons.md](systems/weapons.md)           | `systems/weapons/`      | Weapon behavior, cooldowns, attack execution, scaling.                            |
| Projectiles  | [systems/projectiles.md](systems/projectiles.md)   | `systems/projectiles/`  | Projectile motion, lifetime, collision, pooling.                                  |
| Items        | [systems/items.md](systems/items.md)               | `systems/items/`        | Item definitions and metadata (data only).                                        |
| Inventory    | [systems/inventory.md](systems/inventory.md)       | `systems/inventory/`    | Slots, storage, stacks, sorting, filtering.                                       |
| Equipment    | [systems/equipment.md](systems/equipment.md)       | `systems/equipment/`    | Equipped items, slot rules, stat bonuses.                                         |
| Stats        | [systems/stats.md](systems/stats.md)               | `systems/stats/`        | Base, derived, modifiers, multipliers. Single source of stat truth.               |
| Skills       | [systems/skills.md](systems/skills.md)             | `systems/skills/`       | Temporary run Spells, mana-using talent Spells, and permanent Talent Trees.       |
| Buffs        | [systems/buffs.md](systems/buffs.md)               | `systems/buffs/`        | Run-only, timed, and permanent talent Buffs / modifiers.                          |
| Loot         | [systems/loot.md](systems/loot.md)                 | `systems/loot/`         | Loot tables, drop chances, currency.                                              |
| World        | [systems/world.md](systems/world.md)               | `systems/world/`        | Map selection metadata, arenas, spawn points, enemy pools, spawn curves.          |
| Save         | [systems/save.md](systems/save.md)                 | `systems/save/`         | 5 slots, autosave, profile saves, Run History, checkpoints, resume/forfeit.       |
| UI           | [systems/ui.md](systems/ui.md)                     | `systems/ui/`           | Save slots, Profile Main Screen, Map Selection, HUD, history, talents, settings.  |
| Audio        | [systems/audio.md](systems/audio.md)               | `systems/audio/`        | Music, SFX, volume, buses.                                                        |
| VFX          | [systems/vfx.md](systems/vfx.md)                   | `systems/vfx/`          | Particles, screen shake, hit flashes, explosions. Never modifies gameplay.        |
| Debug        | [systems/debug.md](systems/debug.md)               | `systems/debug/`        | Dev tools, spawn testing, metrics. Excluded from release builds.                  |

## Autoloads

| Name             | Purpose                                                 |
| ---------------- | ------------------------------------------------------- |
| `Core`           | Global initialization and game state.                   |
| `SaveManager`    | Slot selection, autosave, profile saves, Run History, active run checkpoints. |
| `AudioManager`   | Audio buses and playback.                               |
| `UIManager`      | Top-level UI stack, modal management.                   |
| `RunManager`     | Coordinates current run state, timer, XP, rewards.      |
| `EnemyManager`   | Enemy pooling and lifecycle.                            |
| `ProjectileManager` | Projectile pooling and lifecycle.                    |
| `DamageManager`  | Central damage application and combat signals.          |

_(Add / remove entries here when autoloads change.)_

## Content Locations

See [CONTENT.md](CONTENT.md) for the full policy. Quick reference:

| Content        | Location                              |
| -------------- | ------------------------------------- |
| Weapon data    | `content/weapons/*.tres`              |
| Enemy data     | `content/enemies/*.tres`              |
| Map data       | `content/maps/*.tres`                 |
| Spawn curves   | `content/spawn_curves/*.tres`         |
| Item data      | `content/items/*.tres`                |
| Spell data     | `content/spells/*.tres`               |
| Enemy skill data | `content/enemy_skills/*.tres`       |
| Reward pools   | `content/reward_pools/*.tres`         |
| Talent trees   | `content/talents/*.tres`              |
| Stats presets  | `content/stats/*.tres`                |
| Loot tables    | `content/loot/*.tres`                 |
| Buffs          | `content/buffs/*.tres`                |

## Content Design Docs

| Design Doc | Purpose |
| ---------- | ------- |
| [content/map_design_template.md](content/map_design_template.md) | Reusable map gameplay design template. |
| [content/maps.md](content/maps.md) | Index of map gameplay designs before they become `.tres` Resources. |

## Changelog

- v0.10 - registered RunManager and World autoloads; M3 horde/run loop runtime added.
- v0.9 - registered DamageManager autoload; M2 combat/projectile/enemy runtime added.
- v0.8 - enemies gained per-enemy stat blocks and at least one SpellData-based skill; added enemy_skills content location.
- v0.7 - added map gameplay design docs to foundational/content references.
- v0.6 - added Profile Main Screen / hub and Map Selection responsibilities.
- v0.5 - added Run History responsibilities to Run, Save, UI, and Combat.
- v0.4 - updated Save, Run, and UI responsibilities for slots, autosave, and active run checkpoints.
- v0.3 - added TECH_STACK.md to foundational documents.
- v0.2 - added Run system and survivor-specific content locations.
- v0.1 - initial index
