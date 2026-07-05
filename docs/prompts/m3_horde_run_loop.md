# M3 — Horde & Run Loop Implementation Prompt

Version: 0.1

> Paste this prompt into a fresh AI session (or give it to a subagent) to implement M3. All design decisions below are locked. Do not re-open them without explicit approval.

---

## Persona and context

You are a senior Godot gameplay programmer working on a long-term commercial Steam game.

- Engine: Godot 4.7 stable
- Language: GDScript only
- Genre: 2D top-down pixel-art survivor-like
- You are NOT an autonomous agent. Implement only what is specified. Ask before guessing.

---

## Read first (in this order)

1. [AGENTS.md](../../AGENTS.md)
2. [docs/VISION.md](../VISION.md)
3. [docs/ARCHITECTURE.md](../ARCHITECTURE.md)
4. [docs/SYSTEM_MAP.md](../SYSTEM_MAP.md)
5. [docs/ROADMAP.md](../ROADMAP.md) — M3 section
6. [docs/PROGRESS.md](../PROGRESS.md)
7. [docs/TECH_STACK.md](../TECH_STACK.md) — Placeholder & Art Timing Policy
8. [docs/CONTENT.md](../CONTENT.md)
9. [docs/systems/run.md](../systems/run.md)
10. [docs/systems/world.md](../systems/world.md)
11. [docs/systems/enemies.md](../systems/enemies.md)
12. [docs/systems/player.md](../systems/player.md)
13. [docs/systems/combat.md](../systems/combat.md)
14. [docs/systems/core.md](../systems/core.md)
15. Existing M2 code: `systems/player/player.gd`, `systems/enemies/`, `systems/combat/`, `scenes/arena/`
16. [.cursor/rules/](../../.cursor/rules/) — always-applied rules

---

## Milestone goal

**M3 — Horde & Run Loop:** the first rough survivor-style run starts automatically, spawns a ramping horde, tracks time/kills/basic stats, ends when the player dies, and shows a summary placeholder. Checkpoint export shape exists (no full Save UI yet).

---

## Locked design decisions (do not re-open)

### Boot and map flow

- **No Save Slot Select, Profile Hub, or Map Selection UI in M3.** Those are M6.
- **Auto-start:** `Main` → `RunManager.start_run(&"test_arena", &"default")` → World loads map → run becomes `Active`.
- **Single test map:** reuse and extend existing [scenes/arena/Arena.tscn](scenes/arena/Arena.tscn). Wrap it in `MapData` at `content/maps/test_arena.tres`.
- World owns map loading; Run owns session lifecycle. Arena scene does NOT own run lifecycle logic.

### Horde spawner

- Replace the M2 manual **Spawn Enemy** button with an automatic **HordeSpawner** driven by `SpawnCurveData`.
- Spawner reads enemy pool + spawn curve from `MapData`, picks spawn positions around the player (reuse Arena's ring-spawn logic), calls `EnemyManager.spawn()`.
- Pressure **ramps over time** (e.g. shorter intervals and/or higher concurrent cap in later phases). All tuning values in `.tres`, not code.
- One enemy type for M3: existing `test_grunt` (`content/enemies/test_grunt.tres`).

### Run lifecycle

- `RunManager` autoload coordinates: `NotStarted` → `Starting` → `Active` → `Ended`.
- Do **NOT** implement `LevelUpChoice` state or pause-for-level-up (M4).
- Run ends when player emits `player_died`.
- End reason for M3: `death` only (no timer victory, no boss kill).

### Stats tracked during run

Collect and expose in `RunSummary`:

- `duration_seconds` (run timer)
- `total_kills`
- `total_damage_done` (player → enemies)
- `damage_taken` (player received)
- `xp_collected` (sum of `EnemyData.xp_reward` on kills — **counter only**, no leveling)
- `final_level` (hardcode **1** for M3; real leveling is M4)

Wire stats from:

- Kills: `Enemy.enemy_died` → `RunManager.register_enemy_kill(enemy.data)`
- Damage: subscribe to `DamageManager.damage_applied` (attribute to `spell_id` when present)
- Player death: `Player.player_died` → `RunManager.end_run(&"death")`

### UI (minimal placeholders only)

- **Run HUD:** timer + kill counter (read from RunManager signals; UI does not own state).
- **Run summary:** simple overlay after death showing key stats + **Restart Run** button (calls `RunManager.start_run` again or reloads map cleanly).
- Godot built-in UI (`Label`, `Button`, `CanvasLayer`) — no polished screens (M6).

### Checkpoint stub

- Implement `RunManager.to_checkpoint_dict()` / `from_checkpoint_dict()` returning a **serializable Dictionary** (stable string IDs, no node paths).
- Minimum fields: `map_id`, `character_id`, `elapsed_seconds`, `kill_count`, `xp_collected`, `total_damage_done`, `damage_taken`, player `current_health` / `max_health`.
- **Do NOT** wire `SaveManager.save_active_run()` yet — log checkpoint JSON to console on run end or expose a debug print. Full save/resume is M6/M7.

### M2 runtime constraints (mandatory)

- **Never reparent** pooled enemies or projectiles or managers.
- `EnemyManager` / `ProjectileManager` stay autoload `Node2D` with `z_index = 10`.
- Pool despawn from physics/collision callbacks uses `call_deferred`.
- Scene changes use `get_tree().call_deferred("change_scene_to_file", ...)`.

### Placeholders and data

- Godot built-in placeholders only ([TECH_STACK.md](../TECH_STACK.md)).
- Spawn rates, intervals, caps, map metadata live in Resources — not hardcoded in `.gd`.

---

## Deliverables

### Code

| System | Files |
| ------ | ----- |
| Run | `systems/run/run_manager.gd` (autoload), `run_summary.gd` (`class_name RunSummary`), optional `run_state.gd` enum |
| World | `systems/world/world.gd` (autoload), `map_data.gd` (`class_name MapData`), `spawn_curve_data.gd` (`class_name SpawnCurveData`), `horde_spawner.gd` |
| Enemies | Wire kill → Run in `enemy.gd` or via RunManager listening to `enemy_died` |
| Player | Connect `player_died` to Run; optionally implement `gain_experience()` as Run stat hook (no level-up) |
| Combat | RunManager connects to `DamageManager.damage_applied` for stat tracking |
| Core / Main | Update [scenes/main/main.gd](scenes/main/main.gd) to start run via RunManager instead of directly loading Arena |
| Arena | Refactor [scenes/arena/arena.gd](scenes/arena/arena.gd): remove manual Spawn button logic; host or reference HordeSpawner; expose player reference for spawner |
| UI | `ui/run_hud.gd` + `RunHud.tscn`, `ui/run_summary_screen.gd` + `RunSummaryScreen.tscn` (minimal placeholders) |

### Autoload registration

Add to `project.godot`:

- `RunManager`
- `World`

Keep existing: `DamageManager`, `ProjectileManager`, `EnemyManager`.

### Content (`.tres`)

- `content/maps/test_arena.tres` — id `test_arena`, scene `Arena.tscn`, enemy pool `[test_grunt]`, spawn curve ref
- `content/spawn_curves/test_arena_spawn_curve.tres` — 3–4 phases ramping spawn pressure over ~5–10 minutes (values tunable)

### Map design doc (minimal)

Add one row to [docs/content/maps.md](docs/content/maps.md): `test_arena`, status **Implemented**, with brief notes (single grunt horde, ramping pressure, death ends run).

### Docs (same change as code)

- Update Current Status in `docs/systems/run.md`, `world.md`, `enemies.md` (spawner + XP hook checkboxes).
- Update `docs/PROGRESS.md`: Run + World → In Progress/MVP; bump version + changelog.
- Check off M3 items in `docs/ROADMAP.md` **only when verified working**.
- Update `docs/SYSTEM_MAP.md` if autoload list changes.

---

## Definition of Done

- [ ] Editor launches without errors.
- [ ] F5: Main auto-starts a run on `test_arena` (no manual spawn button needed).
- [ ] Enemies spawn automatically; spawn rate/pressure increases over time per spawn curve data.
- [ ] Run HUD shows elapsed time and kill count updating live.
- [ ] Left-click fireball still works; enemies still die via Combat pipeline.
- [ ] Player death ends the run and shows summary placeholder with duration, kills, damage, XP collected.
- [ ] **Restart Run** starts a fresh run (clean enemy pool, reset stats/timer).
- [ ] `RunManager.to_checkpoint_dict()` produces a valid Dictionary (console-verifiable).
- [ ] No `remove_child` / physics-flush console errors during normal play.
- [ ] All spawn tuning values come from `.tres` files.

---

## Anti-scope (explicitly NOT in M3)

Do NOT build:

- XP bar, level-up, or 3-choice reward screen (M4)
- Applying XP to player level or `gain_experience` leveling logic (M4)
- Save Slot Select, Profile Hub, Map Selection screen, pause menu (M6)
- `SaveManager.save_active_run()` / resume-forfeit flow (M6/M7)
- Run History UI or persistence (M6/M7)
- New enemy types, elites, bosses
- Auto-fire level-up spells (M4+)
- VFX, audio, screen shake, animations beyond placeholders
- Timer-based run victory (death-only end for M3)
- Reparenting pooled entities or managers

---

## Order of implementation

1. `MapData`, `SpawnCurveData` Resources + content `.tres` for test_arena
2. `World` autoload — `load_map(map_id)` loads Arena scene, emits `map_loaded`
3. `RunSummary` + `RunManager` autoload — state machine, timer, stat counters, signals
4. `HordeSpawner` — reads map data, ramps spawns, uses EnemyManager
5. Wire kill/damage/death events into RunManager
6. Refactor Main + Arena (remove manual spawn button; run starts through RunManager)
7. Minimal Run HUD + Run Summary placeholder UI
8. Checkpoint dict export (console log)
9. Playtest full loop: start → horde → fight → die → summary → restart
10. Update system docs, PROGRESS, ROADMAP

---

## Workflow rules (from `.cursor/rules/`)

- Read `docs/systems/<name>.md` before editing `systems/<name>/`.
- Follow documented public APIs in run.md / world.md unless you have approval to change them.
- Docs update in the same change as code.
- No new plugins or dependencies without approval.
- Ask before guessing on contradictions between ROADMAP wording and locked decisions above.

---

## Ask before doing

- If spawn curve shape in code doesn't match world.md expectations, propose minimal API and update world.md in the same change.
- If Arena refactor risks breaking M2 combat, stop and preserve fireball + damage pipeline.
- If you need a second enemy type or map for testing, ask — M3 scope is one map, one enemy.
