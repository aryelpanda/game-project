# ROADMAP.md

Version: 0.16

> Milestones are ordered by **dependency**, not calendar. Do not skip ahead. Each milestone should be shippable-in-principle: it either compiles and runs cleanly, or it doesn't get merged.

Rules for using this file:

- Only ONE milestone is `In Progress` at a time.
- Check items off as they are completed.
- Do not invent new milestones without approval.
- When a milestone is fully checked, mark it Done and start the next.
- Each M0–M8 milestone is developed on branch `m{N}-{slug}` (e.g. `m5-data-driven-content`).
- Merge to `main` only when the milestone checklist is fully checked.
- Tag `main` as `m{N}-complete` after merge for roadmap rollback (see [TECH_STACK.md](TECH_STACK.md)).

Legend: `[ ]` = not done, `[x]` = done, `[~]` = in progress.

---

## M0 — Skeleton  `Status: Done`

Goal: an empty project that boots into a black screen with the folder structure and autoloads matching [ARCHITECTURE.md](ARCHITECTURE.md).

- [x] Godot 4.7 stable project created, version pinned in `project.godot`.
- [x] Approved stack from [TECH_STACK.md](TECH_STACK.md) reviewed before adding tools or plugins.
- [x] Folder layout: `systems/`, `content/`, `scenes/`, `ui/`, `assets/`, `debug/`.
- [x] Art source / runtime asset folders created: `art_source/`, `assets/`.
- [x] Autoloads registered: `Core`, `SaveManager`, `AudioManager`, `UIManager` (empty stubs).
- [x] Save Slot Select is planned as the first clickable player-facing screen.
- [x] Profile Main Screen is planned as the post-slot out-of-run hub.
- [x] Main scene loads and quits cleanly (verified in Godot editor).
- [x] `.gitignore` covers `.godot/`, `.import/`, `*.tmp`.
- [ ] Git LFS configured for large art/audio files if repository hosting supports it.
- [x] Version control initialized.

---

## M1 — Player Prototype  `Status: Done`

Goal: a controllable character in a top-down arena.

- [x] `systems/player/` created with matching `docs/systems/player.md` updated.
- [x] Movement (WASD or gamepad left stick).
- [x] Camera follows player.
- [x] Placeholder sprite / mesh.
- [x] Input mapping in project settings, not hardcoded.
- [x] Health and mana values visible in debug output or placeholder HUD.

---

## M2 — Combat Spike  `Status: Done`

Goal: one player attack, one enemy, damage lands, enemy dies. No polish.

- [x] `systems/combat/` — DamageManager, hit detection.
- [x] `systems/weapons/` or `systems/skills/` — one placeholder attack / spell.
- [x] `systems/enemies/` — one placeholder enemy that takes damage and dies.
- [x] `systems/projectiles/` — pooled projectile scene.
- [x] `docs/systems/combat.md`, `weapons.md`, `enemies.md`, `projectiles.md` updated with real content.

---

## M3 — Horde & Run Loop  `Status: Done`

Goal: the first rough survivor-style run starts, spawns hordes, tracks time/kills, and ends.

- [x] `systems/run/` — run lifecycle: start, active, ended.
- [x] Timer and kill counter.
- [x] Basic run stats collected: duration, kills, damage, XP, final level.
- [x] Basic map / arena loaded through World.
- [x] Basic Map Selection flow before starting a run (implemented in M6).
- [x] Enemy horde spawner that ramps over time.
- [x] Death ends the run and returns to summary placeholder.
- [x] Run can export checkpoint data for autosave (console stub; SaveManager wiring in M6/M7).
- [x] `docs/systems/run.md`, `world.md`, and `enemies.md` updated.

---

## M4 — XP & Level-Up Choices  `Status: Done`

Goal: killing enemies gives XP, levels the player, and offers 3 random temporary rewards.

- [x] Enemies award XP on death.
- [x] XP bar and current run level tracked.
- [x] Level-up pause / choice screen.
- [x] Generate 3 random reward options from a Resource-based reward pool.
- [x] Choosing 1 reward applies a temporary Spell or Buff.
- [x] Temporary level-up Spells do NOT use mana.
- [x] Temporary rewards are cleared when the run ends.

---

## M5 — Data-Driven Content  `Status: Done`

Goal: gameplay values move from code to Resources. First intentional map: **Five Minute Gauntlet** (see [content/maps.md](content/maps.md)).

### Already done (M2–M4 baseline)

- [x] `SpellData` Resource + test spells in `content/spells/*.tres`
- [x] `BuffData` Resource + test buffs in `content/buffs/*.tres`
- [x] `EnemyData` Resource + `test_grunt` in `content/enemies/*.tres`
- [x] `MapData` Resource + `test_arena` dev map
- [x] `RewardPoolData` + `m4_test_rewards` pool
- [x] `StatsData` used by Player and Enemy

### M5 implementation

- [x] First map gameplay design documented (Five Minute Gauntlet)
- [x] First map listed in [content/maps.md](content/maps.md) as **Implemented**
- [x] Implement `five_minute_gauntlet` map, spawn curve, and content `.tres` files
- [x] Run duration limit (`time_up` victory at 5:00)
- [x] Compounding spawn pressure (+35% spawn rate per minute)
- [x] Weighted enemy spawn (tank_grunt at 30% weight vs test_grunt)
- [x] New enemy: `tank_grunt` — blue square, 2× HP (80), melee skill
- [x] Spell/buff **leveling** on repeat level-up picks (stack buffs, upgrade spells)
- [x] Big Fireball: +1 projectile per level; Orbiting Star: +1 star per level
- [x] No hardcoded damage / health / cooldowns remain in code (audit pass)

---

## M6 — Run UI Pass  `Status: Done`

Goal: player can understand the run state and make level-up choices.

- [x] Save Slot Select screen with at least 5 slots.
- [x] Resume / Forfeit modal when selected slot has an active run checkpoint.
- [x] Profile Main Screen / hub showing selected character in the center.
- [x] Hub navigation: Start Run, Talent Tree, Inventory, Run History, Stats, Settings, Back to Slot Select.
- [x] Map Selection screen opened from Start Run.
- [x] Non-blocking autosave indicator.
- [x] HUD: health, mana, XP bar, run level, timer, kills.
- [x] Level-up choice screen with 3 random Spell / Buff cards.
- [x] Run summary screen (time survived, enemies killed, spells/buffs, per-spell damage).
- [x] Run History screen showing latest completed / forfeited runs.
- [x] Run History details screen showing map, time, character, kills, damage, chosen Spells/Buffs, and per-Spell stats.
- [x] Character Stats screen from the hub shows base stats and final values (permanent bonuses layer wired in M7).
- [x] In-run Character Stats screen shows base stats, temporary run bonuses, final current values, and temporary Buff sources.
- [x] Pause menu (Esc / gamepad Select; Resume / Character Stats / Leave to Hub / Forfeit).
- [~] Basic tooltips (uses Godot built-in `tooltip_text`; custom tooltip system deferred to feature-specific screens).
- [x] `systems/ui/` — reusable UI components (`UIStatBar`, `UIConfirmDialog`, `UIManager` screen/modal stack).
- [x] All numbers displayed come from the Stats / Combat / Save systems (UI does not own state).

---

## M7 — Talent Trees & Meta-Progression  `Status: Done`

Goal: runs produce permanent progress that can be spent in 3 talent trees.

- [x] Post-run reward calculation placeholder (flat `TALENT_POINTS_PER_RUN` on completed runs; time/kills/story formula deferred to M9).
- [x] 3 talent tree data structures, initially with 10 placeholder test Talents per tree (Ember, Frost, Arcane).
- [x] Talent screen UI (WotLK-style tiered grid, rank badges, arrows, tooltips — visual style only).
- [x] First pass allows free spending across all 3 trees.
- [~] Later main-school selection and secondary-tree spending threshold remain TBD (deferred by design).
- [x] Talents can grant permanent passive Buffs (permanent StatModifiers applied at run start).
- [x] Talents can unlock Spells for future runs (mana cost deferred; M7 test spells are free).
- [x] Temporary testing controls: Talent reset button and game-master infinite-points toggle.
- [x] Save / load permanent talent choices and unlocked spells (`talents` section of profile.json).
- [x] Save / load latest 100 Run History entries per slot (M6).
- [x] Autosave permanent progression after talent purchase, unlocks, settings changes, and run rewards.
- [x] Active run checkpoint autosaves every 10 seconds and after level-up choices (M6).
- [x] Forfeiting interrupted runs deletes active run checkpoint and grants no rewards for MVP (M6).

---

## M8 — Vertical Slice  `Status: Not Started`

Goal: one polished map demonstrating the full loop and intended feel.

- [ ] One area / level with intentional design.
- [ ] 3+ enemy types.
- [ ] 6+ temporary level-up Spells / Buffs.
- [ ] A small but functional 3-tree talent setup.
- [ ] Run History entry after every completed / forfeited run.
- [ ] Boss or set-piece.
- [ ] Audio: basic music + core SFX.
- [ ] VFX: hits, deaths, pickups.
- [ ] A stranger can play for 10 minutes without a tutorial.

---

## M9 — Full Buildout, Story, Polish & Balance  `Status: Not Started`

The longest phase of the project. Starts once M8 is polished 

**Rules that apply only to M9 (different from M0-M8):**

- The four workstreams below (M9.A, M9.B, M9.C, M9.D) are **not strict sequential gates**.
- M9 is **exempt from the "only one milestone In Progress at a time" rule**. Work jumps between workstreams freely and each is iterated on many times until satisfied.
- Checklists inside each workstream are **directional targets, not exhaustive contracts**. Items may be added, deferred, or reworded during iteration without a formal roadmap update.
- Exact content counts (how many maps, enemies, bosses, spells, talents) are intentionally left TBD and decided during iteration.
- The overall M9 phase is Done only when the developer explicitly declares the game ready to move into M10.

### M9.A — Full Content Buildout  `(ongoing, iterative)`

Directional targets. Iterate freely; add or defer items as the game evolves.

- [ ] Build out all planned maps from [content/map_design_template.md](content/map_design_template.md), keeping [content/maps.md](content/maps.md) updated.
- [ ] Build out enemy roster as `EnemyData` `.tres` (basics, elites, mini-bosses).
- [ ] Build out bosses as data + scenes.
- [ ] Build out playable characters (base stats, starting kit, identity).
- [ ] Build out temporary Spells (level-up pool) as `SpellData` `.tres`.
- [ ] Build out Buffs as `BuffData` `.tres`.
- [ ] Expand the 3 Talent Trees beyond M7's placeholders toward the intended launch shape.
- [ ] Build out spawn curves and reward pools per map / character.

### M9.B — Story & Lore Pass  `(ongoing, iterative)`

Lightweight story delivered through flavor text, not a Narrative system.

- [ ] Lore snippets on maps (via `MapData`).
- [ ] Boss intro lines / titles on encounter.
- [ ] Character backstories in the hub / character select.
- [ ] Talent flavor text on nodes.
- [ ] Spell and Buff flavor text on `.tres`.
- [ ] Run summary flavor lines (short blurbs, not cutscenes).
- [ ] Optional `docs/content/story.md` if a shared storyline reference becomes useful.

### M9.C — Feel & Polish Pass  `(ongoing, iterative)`

Moment-to-moment gameplay feel. Launch-wide audio/VFX passes stay in M11.

- [ ] Player animations (idle, move, cast, hit, death).
- [ ] Enemy animations across the roster.
- [ ] Attack feel: hit-stop, knockback, screen shake tuning, hit flashes per Spell.
- [ ] Projectile feel: trails, impacts, muzzles.
- [ ] Death and pickup feedback.
- [ ] Level-up choice screen presentation.
- [ ] Run progression pacing (early / mid / late-run intensity).
- [ ] Camera behavior (follow smoothing, dead zones).

### M9.D — Balance & Difficulty  `(ongoing, iterative)`

End-to-end tuning across the full content set.

- [ ] Difficulty curves per map (spawn curves, enemy stats).
- [ ] Boss difficulty.
- [ ] Talent tree power budget (no dominant tree, no dead nodes).
- [ ] Spell / Buff power balance across the reward pool.
- [ ] Character balance.
- [ ] XP curve and per-level power gain.
- [ ] Informal internal playtesting notes (external testers stay in M11).

---

## M10 — Steam Integration  `Status: Not Started`

Goal: shippable on Steam.

- [ ] Steamworks SDK integration (GodotSteam or equivalent - requires approval, not currently in dependencies).
- [ ] Achievements (design + implementation).
- [ ] Cloud saves.
- [ ] Steam Input configured.
- [ ] Store page assets (screenshots, capsule art, trailer plan).
- [ ] Launch checklist (age rating, tax forms, build depots).

---

## M11 — Polish & Launch  `Status: Not Started`

Goal: 1.0 release.

- [ ] Full audio pass.
- [ ] Full VFX pass.
- [ ] Final exported pixel-art assets organized according to [TECH_STACK.md](TECH_STACK.md).
- [ ] Options menu (video, audio, controls, accessibility).
- [ ] Localization scaffold (even if only English at launch).
- [ ] Playtesting rounds and iteration.
- [ ] Performance pass with real content loads.
- [ ] Release trailer.

---

## Post-Launch (Optional, Not Committed)

- Multiplayer.
- Mod support.
- DLC / expansion content.
- Console ports.
- Character Design feature, unless pulled into a future approved milestone.

---

## Changelog

- v0.16 - M7 Talent Trees & Meta-Progression completed: TalentManager autoload, TalentData/TalentTreeData, 3 trees (Ember/Frost/Arcane) with permanent modifiers and 6 spell unlocks, WotLK-style Talent Tree UI, talent progression saved in profile.json, flat post-run talent points. Active milestone advanced to M8.
- v0.15 - M6 Run UI Pass completed: Save Slot Select, Resume/Forfeit modal, Profile Hub, Map Select, Run History (list + details), Character Stats (out-of-run + in-run), Pause Menu, Autosave Indicator, HUD vitals, thin 5-slot SaveManager runtime with atomic JSON writes.
- v0.14 - M5 Data-Driven Content completed: Five Minute Gauntlet map, timed victory, compounding spawn, weighted enemies, spell/buff leveling.
- v0.13 - M5 design approved: Five Minute Gauntlet first map spec, spell/buff leveling, tank enemy. Implementation not started.
- v0.12 - added milestone branching rules (branch per M#, tag on merge for rollback).
- v0.11 - M4 XP & Level-Up Choices completed: RunProgressionData, reward pools, BuffData, level-up UI, RunPowersPanel, three test rewards.
- v0.10 - M3 Horde & Run Loop completed: RunManager, World/MapData, HordeSpawner, run HUD/summary, checkpoint export stub. Map Selection UI deferred to M6.
- v0.8 - restructured M9 into four parallel iterative workstreams (M9.A Content, M9.B Story & Lore, M9.C Feel & Polish, M9.D Balance). M9 explicitly exempt from "one milestone In Progress at a time" rule. Checklists are directional, not exhaustive. M11 unchanged.
- v0.7 - added map gameplay template workflow.
- v0.6 - added Profile Main Screen / hub and Map Selection flow.
- v0.5 - added Run History milestones and per-run stat tracking.
- v0.4 - added save-slot, autosave, active run checkpoint, and resume/forfeit roadmap requirements.
- v0.3 - linked TECH_STACK.md and added stack/art pipeline setup tasks.
- v0.2 - revised milestones around survivor-style run loop, XP, 3-choice rewards, and talent meta-progression.
- v0.1 - initial template
