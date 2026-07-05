# Maps Gameplay Index

Version: 0.3

> Index of gameplay designs for maps. Use [map_design_template.md](map_design_template.md) before creating any `MapData` Resource.

## Rules

- This file tracks map gameplay intent, not visual art.
- Do not create one Markdown file per map unless the map becomes complex enough to need it.
- Actual runtime data belongs in `content/maps/*.tres` and `content/spawn_curves/*.tres`.
- Every map uses stable IDs for enemies, rewards, unlocks, and resources.
- If a map changes required data fields, update [../systems/world.md](../systems/world.md) and [../CONTENT.md](../CONTENT.md).

## Map List

| Map ID | Display Name | Tier | Status | Resource | Notes |
| ------ | ------------ | ---- | ------ | -------- | ----- |
| test_arena | Test Arena | tutorial | Implemented | `content/maps/test_arena.tres` | Single `test_grunt` horde, ramping spawn curve, death ends run. M3 dev map. |
| five_minute_gauntlet | Five Minute Gauntlet | tutorial | Implemented | `content/maps/five_minute_gauntlet.tres` | M5 first map. 5-min timed victory, compounding spawn, tank enemy, reward leveling. |

## Map Status Legend

| Status | Meaning |
| ------ | ------- |
| Not Designed | No approved gameplay design yet. |
| Designed | Markdown design exists, no Resource yet. |
| Implemented | `MapData` and spawn curve Resources exist. |
| Tested | Played in-game and basic issues fixed. |
| Balanced | Difficulty and rewards are close to target. |
| Locked | Do not change without approval. |

---

## Five Minute Gauntlet — Gameplay Design (M5)

Approved design. **Implemented in M5.** See [ROADMAP.md](../ROADMAP.md) M5.

### 1. Map Identity

- **Map ID:** `five_minute_gauntlet`
- **Display Name:** Five Minute Gauntlet
- **Difficulty Tier:** tutorial
- **Expected Run Duration:** 5 minutes (300 seconds)
- **Unlock Requirement:** none (first designed map)
- **MapData Resource:** `content/maps/five_minute_gauntlet.tres` _(planned)_
- **SpawnCurve Resource:** `content/spawn_curves/five_minute_gauntlet_curve.tres` _(planned)_

### 2. Gameplay Fantasy

Survive a fixed 5-minute gauntlet while horde pressure ramps every minute. Level-up rewards can be picked again to **upgrade** existing spells and buffs instead of only collecting new ones.

### 3. Primary Gameplay Twist

- **Timed victory:** run ends automatically at 5:00 with a success summary (`time_up`).
- **Compounding spawn pressure:** spawn rate doubles every 30 seconds (`spawn_rate_growth_per_minute = 1.0`, `spawn_rate_growth_interval_seconds = 30`).
- **Reward leveling:** re-picking a spell or buff from the level-up pool increases its power.

### 4. Win / Lose Conditions

| Condition | Result |
| --------- | ------ |
| Survive 300 seconds | Victory (`time_up`) |
| Player dies | Defeat (`death`) |

### 5. Spawn Pressure

- Base spawn interval: ~1.33s at minute 0 (3× faster than original 4.0s tuning).
- **Spawn rate doubles every 30 seconds** (compounding): `effective_interval = base / pow(2.0, floor(elapsed / 30))`
- Phases at 0 / 60 / 120 / 180 / 240s also raise `max_concurrent` (e.g. 15 → 24 → 36 → 48 → 60; 3× original caps).

### 6. Enemy Roster

| ID | Visual | HP | Spawn weight | Notes |
| -- | ------ | -- | ------------ | ----- |
| `test_grunt` | Red square (existing) | 40 | 1.0 | Baseline horde enemy |
| `tank_grunt` | Blue square | 80 (2× grunt) | 0.3 (~70% less often than grunt) | New M5 enemy; same melee skill pattern |

Planned Resources: `content/stats/tank_grunt.tres`, `content/enemies/tank_grunt.tres`.

### 7. Level-Up Rewards (M4 pool, M5 leveling rules)

Uses existing M4 test reward pool. On repeat pick:

| Reward | Level-up effect |
| ------ | --------------- |
| `attack_power_boost` | Stack another +25% attack power |
| `big_fireball` | +1 fireball fired per cooldown tick |
| `orbiting_star` | +1 orbiting star |

### 8. Planned Code Changes (implementation checklist)

When M5 build starts on branch `m5-data-driven-content`:

- `MapData.run_duration_seconds`
- `EnemyData.spawn_weight`, `EnemyData.tint_color`
- `SpawnCurveData.spawn_rate_growth_per_minute`
- Weighted pick in `HordeSpawner`
- Spell upgrade + buff stacking in `RunSpellController`, `BuffContainer`, `RunManager`
- Timed victory in `RunManager`; summary UI shows victory vs defeat
- Wire default run to `five_minute_gauntlet` in `scenes/main/main.gd`

---

## Adding a Map

1. Add a row to **Map List**.
2. Fill a gameplay design using [map_design_template.md](map_design_template.md).
3. Create or update the matching `MapData` Resource.
4. Create or update the matching spawn curve Resource.
5. Test the map and add balancing notes.

## Changelog

- v0.4 - `five_minute_gauntlet` implemented (M5).
- v0.2 - added `test_arena` M3 dev map entry.
- v0.1 - initial map gameplay index
