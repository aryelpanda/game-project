# M2 — Combat Spike Implementation Prompt

Version: 0.1

> Paste this prompt into a fresh AI session (or give it to a subagent) to implement M2. All design decisions below are locked. Do not re-open them without explicit approval.

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
5. [docs/ROADMAP.md](../ROADMAP.md) — M2 section
6. [docs/PROGRESS.md](../PROGRESS.md)
7. [docs/TECH_STACK.md](../TECH_STACK.md) — Placeholder & Art Timing Policy
8. [docs/CONTENT.md](../CONTENT.md)
9. [docs/systems/combat.md](../systems/combat.md)
10. [docs/systems/enemies.md](../systems/enemies.md)
11. [docs/systems/skills.md](../systems/skills.md)
12. [docs/systems/projectiles.md](../systems/projectiles.md)
13. [docs/systems/stats.md](../systems/stats.md)
14. [.cursor/rules/](../../.cursor/rules/) — always-applied rules

---

## Milestone goal

**M2 — Combat Spike:** one player attack, one enemy, damage lands, enemy dies. No polish, no VFX, no audio.

---

## Locked design decisions (do not re-open)

### Player attack model

- **Basic attack (M2 scope):** left mouse click casts a fireball toward the cursor. Uses `SpellData` at `content/spells/basic_fireball.tres`. This is M2's only player attack.
- **Level-up spells (M3+ scope, NOT in M2):** spells gained from leveling auto-fire on cooldown. Do not build this in M2.
- **Talent-granted spells (M7+ scope, NOT in M2):** spells unlocked from the talent tree are activated by keyboard press. Do not build this in M2.

### Attack system

- **Skills / `SpellData`** owns the player attack (`content/spells/*.tres`).
- The **Weapons** system stays untouched and de-prioritized.

### Enemy

- One test enemy: `test_grunt` at `content/enemies/test_grunt.tres`.
- Has its own `StatsBlock` from `content/stats/test_grunt.tres`.
- Per [enemies.md](../systems/enemies.md) design rules, `skills: Array[SpellData]` must contain **at least one** entry.
- For M2, that entry is `content/enemy_skills/melee_touch.tres` — a minimal contact-damage skill fired when the enemy touches the player.

### Placeholders and data

- **Placeholders only:** Godot `PlaceholderTexture2D`, `ColorRect`, `Polygon2D`. No downloaded packs, no AI-generated sprites, no Aseprite art (per [TECH_STACK.md](../TECH_STACK.md) Placeholder & Art Timing Policy).
- **All values data-driven:** no hardcoded damage, health, speed, or cooldowns in `.gd` files. Values live in `.tres` Resources.

---

## Deliverables

### Code (under `systems/<name>/`)

| System | Files |
| ------ | ----- |
| Combat | `systems/combat/damage_event.gd` (`class_name DamageEvent`), `systems/combat/damage_manager.gd` (autoload) |
| Projectiles | `systems/projectiles/projectile.gd`, `Projectile.tscn` (pooled), `systems/projectiles/projectile_manager.gd` (autoload) |
| Skills | `systems/skills/spell_data.gd` (`class_name SpellData`) |
| Stats | `systems/stats/stats_data.gd` (`class_name StatsData`), `systems/stats/stats_block.gd` (`class_name StatsBlock`) — minimum viable: `max_health`, `move_speed`, damage stat; full modifier pipeline may stay stubbed with TODOs |
| Enemies | `systems/enemies/enemy_data.gd` (`class_name EnemyData`), `systems/enemies/enemy.gd`, `Enemy.tscn`, `systems/enemies/enemy_manager.gd` (autoload) |
| Player | Extend `systems/player/player.gd`: hold a `StatsBlock`, read cursor position, on left mouse click cast the equipped `basic_fireball` SpellData through the projectile pipeline |

### Autoload registration

Register in `project.godot`:

- `DamageManager`
- `ProjectileManager`
- `EnemyManager`

### Content (`.tres` files)

- `content/stats/player_default.tres`
- `content/stats/test_grunt.tres`
- `content/spells/basic_fireball.tres`
- `content/enemy_skills/melee_touch.tres`
- `content/enemies/test_grunt.tres`

### Scene

Update `scenes/arena/Arena.tscn` to spawn one `test_grunt` on load.

### Docs (in the same change as code)

- Update Current Status checkboxes in `docs/systems/combat.md`, `enemies.md`, `projectiles.md`, `skills.md`, `stats.md`.
- Update `docs/PROGRESS.md`: move Combat / Enemies / Projectiles / Skills / Stats to `In Progress` with today's date; update Notes; bump PROGRESS version and add changelog entry.
- Check off completed items in `docs/ROADMAP.md` M2 section **only when verified working**.

---

## Definition of Done

- [ ] Editor launches without errors.
- [ ] Main -> Arena loads.
- [ ] Player moves (existing) and casts fireball on left click aimed at cursor.
- [ ] Fireball travels, hits enemy, deals damage through `DamageManager`.
- [ ] Enemy takes damage, dies at 0 HP, emits `enemy_died`, logs to console.
- [ ] Enemy chases player and deals `melee_touch` damage on contact.
- [ ] Player has HP (console print is enough), can be killed.
- [ ] All damage numbers come from `.tres` files, not code.

---

## Anti-scope (explicitly NOT in M2)

Do NOT build any of the following:

- Horde spawner (M3)
- XP, leveling (M4)
- Level-up choice screen (M4 / M6)
- Talent trees (M7)
- Maps / biomes / spawn curves
- VFX, audio, screen shake, hit-stop, or animations beyond static sprites
- Pause menu, death screen, run summary
- Enemy variety, elites, bosses
- Modifier stacking, crit rolls, or dodge rolls — stub these APIs but do not wire them

---

## Order of implementation

1. `SpellData`, `StatsData`, `StatsBlock` (minimal)
2. `DamageEvent`, `DamageManager` autoload
3. `Projectile` + `ProjectileManager` autoload
4. `EnemyData`, `Enemy` scene/script, `EnemyManager` autoload
5. All `.tres` content files
6. Player left-click cast pipeline
7. Enemy chase + `melee_touch` AI
8. Arena spawns one `test_grunt`
9. Playtest the loop end-to-end
10. Update system docs and `PROGRESS.md`

---

## Workflow rules (from `.cursor/rules/`)

- Read `docs/systems/<name>.md` before editing `systems/<name>/`.
- If your implementation deviates from a system doc, STOP and either update the doc (with approval) or reshape the change.
- Follow the exact public APIs documented in each system doc unless you have approval to change them.
- Godot built-in placeholders only.
- All values data-driven via Resources.
- No cross-system data ownership violations.
- Docs update in the same change as the code.
- No new autoloads, plugins, or dependencies beyond what is listed here without approval.

---

## Ask before doing

- If two design docs contradict each other, ask.
- If the "every enemy needs >= 1 SpellData skill" rule feels awkward, do not compromise it — ask.
- If a naming or scene-path change is needed, ask.
- If you find yourself considering an inheritance hierarchy for enemies or spells, ask — composition is preferred (see [.cursor/rules/20-architecture.mdc](../../.cursor/rules/20-architecture.mdc)).
