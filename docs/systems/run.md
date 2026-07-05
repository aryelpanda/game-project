# Run System

Status: MVP

## Goal

Own the lifecycle of a single survival session: start the run, track time and kills, coordinate XP and level-ups, generate 3 random reward choices, checkpoint interrupted runs, end the run, calculate post-run rewards, and produce a permanent run history entry.

## Components

- RunManager
- Run state machine (NotStarted, Starting, Active, LevelUpChoice, Ended)
- Run timer
- Kill counter
- XP and in-run level tracking
- Level-up reward generator
- Temporary run power registry
- Active run checkpoint data
- Resume / forfeit interrupted run flow
- Run end summary
- Run stats tracking
- Run history entry output
- Post-run reward calculation placeholder

## Current Status

- [x] RunManager autoload
- [x] Run state machine (NotStarted, Starting, Active, LevelUpChoice, Ended)
- [x] Timer and kill counter
- [x] XP gain and level-up threshold calculation (`RunProgressionData`)
- [x] 3-choice reward generation (`RewardPoolData`)
- [x] Temporary reward cleanup at run end
- [x] Checkpoint export / restore (`to_checkpoint_dict` / `from_checkpoint_dict`; console log only in M3)
- [ ] Resume active run
- [ ] Forfeit active run
- [x] Run summary data (`RunSummary` Resource)
- [ ] Run history entry data
- [x] Basic damage tracking (total dealt / taken)
- [ ] Per-Spell damage / kill tracking
- [x] Chosen Spell / Buff tracking (IDs in RunManager)

## Design Rules

- Run owns session state. Player owns movement/health/mana; Enemies own behavior; UI displays run state.
- A new run starts only after Profile Main Screen -> Start Run -> Map Selection (full UI in M6). **M3 exception:** auto-start via `RunManager.start_run(&"test_arena", &"default")` from Main for testing.
- Run receives the selected `map_id` and `character_id`.
- Temporary Spells and Buffs gained from level-ups are cleared when the run ends.
- The Run system asks Skills/Buffs to apply rewards; it does not implement spell or buff behavior.
- Level-up rewards come from `RewardPoolData` Resources, not hardcoded arrays.
- Run end rewards are permanent only after the Run system hands them to Save / meta-progression.
- Exact post-run reward formula is TBD and must remain easy to replace.
- Run must expose checkpoint data for SaveManager.
- A checkpoint can restore temporary Spells, Buffs, XP, level, timer, kills, map, player state, and enemy/spawner state needed to resume.
- Normal run end deletes the active run checkpoint after permanent rewards are safely applied.
- Forfeit deletes the active run checkpoint and grants no run rewards in MVP.
- A resumed run must never grant post-run rewards twice.
- Every completed or forfeited run creates exactly one `RunHistoryEntry`.
- Run history is permanent profile data and is separate from `active_run.json`.
- The Run system tracks enough stats to explain what happened during the run, but does not become a full analytics system.
- Damage and kill stats by Spell are collected from Combat events.

## Public API

```gdscript
class_name RunManager

signal run_started(map_id: StringName)
signal run_ended(summary: RunSummary)
signal run_history_entry_created(entry: RunHistoryEntry)
signal run_resumed(map_id: StringName)
signal run_forfeited()
signal run_timer_changed(seconds: float)
signal kill_count_changed(kills: int)
signal level_up_available(options: Array)

func start_run(map_id: StringName, character_id: StringName) -> void
func resume_run(checkpoint: Dictionary) -> void
func forfeit_run() -> void
func end_run(reason: StringName) -> RunSummary
func register_enemy_kill(enemy_data: EnemyData) -> void
func register_spell_damage(spell_id: StringName, amount: float) -> void
func register_spell_kill(spell_id: StringName, enemy_data: EnemyData) -> void
func add_experience(amount: int) -> void
func choose_level_up_reward(reward_id: StringName) -> void
func current_run_level() -> int
func current_kill_count() -> int
func to_checkpoint_dict() -> Dictionary
func from_checkpoint_dict(data: Dictionary) -> void
func build_history_entry(summary: RunSummary) -> RunHistoryEntry
```

## Run History Data

`RunHistoryEntry` is created when a run ends or is forfeited.

Recommended fields:

- `id`
- `slot_id`
- `started_at`
- `ended_at`
- `map_id`
- `character_id`
- `duration_seconds`
- `end_reason` (`death`, `victory`, `forfeit`, `quit_resume_end`)
- `final_level`
- `total_kills`
- `total_damage_done`
- `damage_taken`
- `healing_received`
- `mana_spent`
- `xp_collected`
- `level_ups_gained`
- `rewards_earned`
- `chosen_spells`
- `chosen_buffs`
- `spell_stats`
- `enemy_kills_by_type`
- `bosses_killed`

`spell_stats` should include:

- `spell_id`
- `damage_done`
- `kills`
- `casts`
- `highest_hit`
- `dps_estimate`

MVP UI can display only the most important fields first: map, character, duration, end reason, final level, total kills, total damage, chosen powers, and top Spell.

## Dependencies

- Player (reads death signal, may grant XP to player-facing state)
- Enemies (kill events)
- Skills (applies temporary Spells and talent-granted Spells)
- Buffs (applies temporary Buffs)
- World (loads map / arena)
- UI (displays timer, XP, choices, summary)
- Save (stores active run checkpoints, receives permanent post-run rewards, and persists run history)

## Open Questions

- Does a run end only on player death, or also by timer, boss kill, or story objective?
- What is the XP curve per in-run level?
- What is the exact formula for post-run talent rewards?
- Are level-up rewards weighted by map, character, previous choices, or all available rewards?
- Which exact enemy/spawner details must be restored for a mid-run resume to feel fair?

## References

- [../VISION.md](../VISION.md)
- [../ROADMAP.md](../ROADMAP.md)
- [../GLOSSARY.md](../GLOSSARY.md)
