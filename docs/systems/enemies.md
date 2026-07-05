# Enemies System

Status: MVP

## Goal

Spawn, run, and dispose of hostile horde entities. Enemies rush the player, attack or collide, die, and award XP to the current Run.

## Components

- Horde spawning (via EnemyManager and Run / World spawn curves)
- Enemy AI / behavior states (first MVP: chase player)
- Enemy state (alive, dying, dead)
- Enemy stat block (`StatsData` / `StatsBlock`, shared shape with the player)
- Enemy skills (`SpellData`, drawn from the enemy skill content pool)
- Enemy death and cleanup
- XP awards on death (delegates to Run)
- Optional drops (delegates to Loot system later)
- Enemy pooling

## Current Status

- [x] Base Enemy scene / script
- [x] EnemyManager autoload
- [x] Basic horde spawner (`HordeSpawner` + `SpawnCurveData`)
- [x] Simple AI (chase, attack)
- [x] Damage handling via Combat
- [x] Enemy stat block wired from `EnemyData.stats`
- [x] Enemy skill(s) wired from `EnemyData.skills`
- [x] Death flow
- [x] XP award hook to Run (`EnemyManager.enemy_killed` → `RunManager.register_enemy_kill`)
- [x] Weighted enemy spawn (`EnemyData.spawn_weight`)
- [x] Data-driven enemy tint (`EnemyData.tint_color`)

## Design Rules

- Enemies do NOT directly modify player systems.
- Enemies emit signals and use Combat System for damage.
- Enemy data lives in `EnemyData` Resources (`content/enemies/*.tres`).
- Pool enemies via EnemyManager. Do not `instantiate()` in hot paths.
- Every pooled enemy must enter the pool through `reset_for_pool()` so collision layers are disabled while idle. Never `hide()` a freshly instantiated enemy without resetting — default scene collision at the autoload origin will block the player at run start.
- Pooled enemies stay under `EnemyManager` (autoload `Node2D`, `z_index = 10`). Never reparent nodes — reparenting during scene load or physics flush causes engine errors.
- Enemy despawn from `kill()` must use `call_deferred` on `EnemyManager.despawn` so cleanup does not run inside physics callbacks.
- MVP enemy behavior is simple and explicit: spawn -> chase player -> attack/collide -> die/despawn.
- Horde spawns must place enemies **off-screen**: `HordeSpawner` uses the active camera viewport plus `MapData.spawn_min_distance` / `spawn_max_distance` as extra margin beyond the visible edge.
- Enemies stop at the player when chasing: zero chase velocity while `EntityCollision.is_in_contact` is true (hysteresis — chase only resumes after the player clears an extra gap). `MOTION_MODE_FLOATING` prevents riding the player as a platform in top-down contact.
- When the player walks into enemies, `EntityCollision.apply_player_pushback` displaces them slightly along the radial separation axis; enemies are not dragged when the player strafes at contact.
- Enemy–enemy overlap is allowed; enemies stack in hordes.
- Melee contact skills use `EntityCollision.is_within_touch` — not hardcoded distance values.
- AI states are explicit (state machine), never deeply nested conditionals.
- Enemy XP value is data-driven on `EnemyData`.
- Every enemy has its own `StatsBlock` sourced from `EnemyData.stats: StatsData`. Enemies use the same stat catalog as the player, minus player-only stats such as `xp_gain` and `pickup_radius`.
- Enemy stat modifier layers are simpler than the player's: base + optional spawn / elite tags + in-combat debuffs applied by player Spells or Buffs. Enemies have no talent layer, no run-reward layer, and no permanent progression layer.
- Every `EnemyData` must define **at least one** entry in `skills: Array[SpellData]`. This is a data-integrity rule to be enforced at load time.
- Enemy skills use the shared `SpellData` shape but are unique to enemies. They live in `content/enemy_skills/*.tres` and are never mixed with `content/spells/*.tres`.
- Enemy skills never enter the player level-up reward pool. Player Spells never appear on enemies.
- Enemy skills go through the same Combat pipeline as player Spells (`DamageEvent` -> `DamageManager`).
- Enemy skill selection and trigger conditions are part of enemy AI (state machine). Exact triggers are designed per enemy later.

## Public API

```gdscript
class_name Enemy
extends CharacterBody2D

signal enemy_died(enemy: Enemy)

@export var data: EnemyData
var stats: StatsBlock

func take_damage(event: DamageEvent) -> void
func kill() -> void
func try_use_skill(skill_id: StringName) -> bool
```

```gdscript
class_name EnemyData
extends Resource

@export var id: StringName
@export var display_name: String
@export var stats: StatsData              # base stat block (shared shape with player)
@export var skills: Array[SpellData]      # must contain at least 1 entry
@export var xp_reward: int
@export var spawn_weight: float = 1.0
@export var tint_color: Color
```

```gdscript
class_name EnemyManager  # autoload

signal enemy_killed(enemy_data: EnemyData)

func spawn(data: EnemyData, position: Vector2) -> Enemy
func despawn(enemy: Enemy) -> void
func despawn_all_active() -> void
func active_count() -> int
```

## Dependencies

- Combat (sends and receives DamageEvents)
- Run (reports kills and XP)
- Loot (optional non-XP drops later)
- Stats (for enemy stat blocks; shared `StatsData` / `StatsBlock`)
- Skills (for `SpellData` shape used by enemy skills; enemy skills are a separate content pool)
- World (map spawn positions and spawn curve data)

## Open Questions

- How many concurrent enemies at peak? Influences pooling strategy and hit detection choice.
- First target: simple chase-only enemies. More complex AI comes later.
- Are XP gems physical pickups or direct XP on kill?
- Exact AI trigger rules per enemy skill (cooldown-only, condition-gated, telegraphed windup, etc.).
- How spawn / elite modifiers are declared in data (tag list on the spawner, dedicated `EliteModifierData` Resource, or inline on `EnemyData`).

## References

- [../ARCHITECTURE.md](../ARCHITECTURE.md#enemy-system)
