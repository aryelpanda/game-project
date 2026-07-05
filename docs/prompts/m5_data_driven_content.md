# M5 — Data-Driven Content Implementation Prompt

Version: 0.1

> Paste this prompt into a fresh AI session (or give it to a subagent) to implement M5. All design decisions below are locked. Do not re-open them without explicit approval.

---

## Persona and context

You are a senior Godot gameplay programmer working on a long-term commercial Steam game.

- Engine: Godot 4.7 stable
- Language: GDScript only
- Genre: 2D top-down pixel-art survivor-like
- You are NOT an autonomous agent. Implement only what is specified. Ask before guessing.

---

## Git workflow (mandatory)

1. Create branch from latest `main`:
   ```powershell
   git checkout main
   git pull
   git checkout -b m5-data-driven-content
   ```
2. All M5 commits go on `m5-data-driven-content`, **never directly on `main`**.
3. **NEVER commit or push without explicit user permission.** Ask after each logical chunk.
4. When M5 is fully verified: merge to `main`, tag `m5-complete`, ask before push.
5. Do not force-push `main`.

---

## Read first (in this order)

1. [AGENTS.md](../../AGENTS.md)
2. [docs/VISION.md](../VISION.md)
3. [docs/ARCHITECTURE.md](../ARCHITECTURE.md)
4. [docs/SYSTEM_MAP.md](../SYSTEM_MAP.md)
5. [docs/ROADMAP.md](../ROADMAP.md) — M5 section
6. [docs/PROGRESS.md](../PROGRESS.md)
7. [docs/TECH_STACK.md](../TECH_STACK.md)
8. [docs/CONTENT.md](../CONTENT.md)
9. [docs/content/maps.md](../content/maps.md) — **Five Minute Gauntlet design (locked)**
10. [docs/content/rewards.md](../content/rewards.md) — reward leveling rules
11. [docs/systems/world.md](../systems/world.md)
12. [docs/systems/run.md](../systems/run.md)
13. [docs/systems/enemies.md](../systems/enemies.md)
14. [docs/systems/skills.md](../systems/skills.md)
15. [docs/systems/buffs.md](../systems/buffs.md)
16. [docs/systems/stats.md](../systems/stats.md)
17. [docs/systems/ui.md](../systems/ui.md)
18. Existing M4 code: `systems/run/`, `systems/world/horde_spawner.gd`, `systems/skills/run_spell_controller.gd`, `systems/buffs/buff_container.gd`, `scenes/main/main.gd`
19. [.cursor/rules/](../../.cursor/rules/) — especially `90-git-commits.mdc`, `50-resources.mdc`, `80-docs-sync.mdc`

---

## Milestone goal

**M5 — Data-Driven Content:** first intentional map (**Five Minute Gauntlet**) with data-driven tuning, timed victory, compounding spawn pressure, weighted enemy pool, and spell/buff **leveling** on repeat level-up picks. Finish hardcoded gameplay value audit.

M2–M4 Resource baseline already exists (`SpellData`, `BuffData`, `EnemyData`, `MapData`, `RewardPoolData`, `StatsData`, `test_arena` dev map). M5 extends systems and adds real content — do not rewrite working M4 loop.

---

## Locked design decisions (do not re-open)

### First map: Five Minute Gauntlet

- **Map ID:** `five_minute_gauntlet`
- **Duration:** 300 seconds — run ends with **`time_up` victory** (not death-only)
- **Default boot map:** `Main` starts `RunManager.start_run(&"five_minute_gauntlet", &"default")`
- Keep `test_arena` as dev map (do not delete)
- Reuse existing `scenes/arena/Arena.tscn` as the arena scene

### Spawn pressure

- Base spawn interval ~4.0s at minute 0 (in spawn curve `.tres`)
- **+35% spawn rate per minute, compounding:**
  `effective_interval = phase.spawn_interval_seconds / pow(1.0 + growth, floor(elapsed / 60))`
- `spawn_rate_growth_per_minute = 0.35` on spawn curve Resource
- Phases at 0 / 60 / 120 / 180 / 240s raise `max_concurrent`: 5 → 8 → 12 → 16 → 20

### Enemy roster

| ID | Visual | HP | spawn_weight | Notes |
|----|--------|-----|--------------|-------|
| `test_grunt` | Red square | 40 | 1.0 | Existing enemy |
| `tank_grunt` | Blue square | 80 (2× grunt) | 0.3 | New; same `melee_touch` skill pattern |

Weighted random pick in spawner (not equal random).

### Reward leveling (repeat level-up picks)

Uses existing M4 pool (`m4_test_rewards`). Already-owned rewards **stay in the level-up candidate pool**.

| Reward | Repeat-pick effect |
|--------|-------------------|
| `attack_power_boost` | Stack another +25% `attack_power` |
| `big_fireball` | +1 fireball per cooldown volley |
| `orbiting_star` | +1 orbiting star |

Level-up UI should show next level, e.g. `Big Fireball (Lv 2)`.

### Data-driven rule

Gameplay tuning values (HP, damage, cooldowns, spawn intervals, weights, duration) live in `.tres` — not hardcoded in `.gd`. Engine feel constants in `entity_collision.gd` (push strength, contact padding) may stay in code.

### M2–M4 runtime constraints (mandatory)

- Never reparent pooled enemies/projectiles/managers
- Pool despawn via `call_deferred`
- Scene changes via `get_tree().call_deferred("change_scene_to_file", ...)`
- Godot built-in placeholders only

---

## Code changes required

### Data model extensions

| File | Add |
|------|-----|
| `systems/world/map_data.gd` | `@export var run_duration_seconds: float = 0.0` (0 = no limit) |
| `systems/enemies/enemy_data.gd` | `@export var spawn_weight: float = 1.0`, `@export var tint_color: Color` |
| `systems/world/spawn_curve_data.gd` | `@export var spawn_rate_growth_per_minute: float = 0.0` |

### Runtime systems

| System | Change |
|--------|--------|
| `systems/world/horde_spawner.gd` | Apply compounding spawn interval; weighted `_pick_enemy_data()` |
| `systems/enemies/enemy.gd` | Apply `data.tint_color` to Sprite2D + health bar on `initialize()` |
| `systems/run/run_manager.gd` | Check map duration → `end_run(&"time_up")`; upgrade spells/buffs on repeat pick; show level in level-up options |
| `systems/skills/run_spell_controller.gd` | `upgrade_spell()` with levels; orbit count + projectile volley scale with level |
| `systems/buffs/buff_container.gd` | Stack buffs on re-apply; `get_buff_stack_count()` |
| `systems/player/player.gd` | Expose upgrade/stack helpers if needed |
| `ui/run_summary_screen.gd` | Friendly text: `time_up` = "Time Survived!", `death` = "Defeated" |
| `ui/run_powers_panel.gd` | Show spell/buff levels (e.g. `Big Fireball x2`) |
| `ui/level_up_choice_screen.gd` | Show `(Lv N+1)` on upgrade options |
| `scenes/main/main.gd` | Start `five_minute_gauntlet` |

### Hardcoded audit (fix where found)

- Remove gameplay fallbacks like `attack_power = 100.0` in player damage calc — rely on StatsData
- Keep `RunManager` progression path as Resource ref (already data-driven)
- Do not hardcode map id except as boot default in `main.gd`

---

## Content (`.tres`) to create

| File | Purpose |
|------|---------|
| `content/maps/five_minute_gauntlet.tres` | MapData: 300s duration, enemy pool, spawn curve, Arena scene |
| `content/spawn_curves/five_minute_gauntlet_curve.tres` | 5 phases, growth 0.35/min |
| `content/stats/tank_grunt.tres` | max_health 80 |
| `content/enemies/tank_grunt.tres` | Blue tint, spawn_weight 0.3, melee_touch, xp_reward |

Update `content/enemies/test_grunt.tres` if needed to set explicit `spawn_weight = 1.0`.

---

## Docs (same change as code)

Update per [80-docs-sync.mdc](../../.cursor/rules/80-docs-sync.mdc):

- `docs/systems/world.md`, `run.md`, `enemies.md`, `skills.md`, `buffs.md` — new fields + public API
- `docs/content/maps.md` — status `five_minute_gauntlet`: Designed → Implemented
- `docs/ROADMAP.md` — check off M5 implementation items; status → Done when verified
- `docs/PROGRESS.md` — bump version, update affected systems, advance milestone to M6 when done

---

## Definition of Done

- [ ] Branch `m5-data-driven-content` created; all work committed there
- [ ] F5: game auto-starts **Five Minute Gauntlet**
- [ ] Run auto-ends at 5:00 with victory summary (`time_up`)
- [ ] Player death still ends run with defeat summary
- [ ] Spawn rate visibly increases each minute
- [ ] Blue tank (80 HP) spawns ~70% less often than red grunt
- [ ] Re-picking Big Fireball adds +1 projectile per volley
- [ ] Re-picking Orbiting Star adds +1 star
- [ ] Re-picking Attack Power Boost stacks +25% each time
- [ ] Level-up cards and powers panel show levels
- [ ] M4 loop still works: XP, level-up, rewards, horde, combat
- [ ] Tuning values in `.tres`, not hardcoded in scripts
- [ ] No console errors during normal 5-min play
- [ ] Docs synced; ROADMAP M5 checked off

---

## Anti-scope (explicitly NOT in M5)

Do NOT build:

- Save Slot Select, Profile Hub, Map Selection UI (M6)
- Pause menu polish, tooltips, Run History (M6)
- Talent trees (M7)
- New spell types beyond M4 test pool
- Boss, audio, VFX, animations
- Delete or break `test_arena`

---

## Order of implementation

1. Create `m5-data-driven-content` branch
2. Data model extensions (MapData, EnemyData, SpawnCurveData)
3. HordeSpawner: weighted pick + compounding interval
4. Enemy tint from EnemyData
5. Spell upgrade + buff stacking (RunSpellController, BuffContainer, RunManager)
6. Timed victory + summary UI text
7. Author content `.tres` files for gauntlet map + tank
8. Wire `main.gd` to new map
9. UI level display (powers panel + level-up screen)
10. Hardcoded value audit pass
11. Playtest full 5-min loop + level-up upgrades
12. Update docs, ROADMAP, PROGRESS
13. Ask user to commit; ask user to merge + tag `m5-complete` when approved

---

## Workflow rules

- Read `docs/systems/<name>.md` before editing `systems/<name>/`
- One feature at a time; minimal focused diffs
- Docs update in the same change as code
- Ask before guessing; ask before commit/push
