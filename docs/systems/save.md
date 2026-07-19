# Save System

Status: In Progress

## Goal

Persist all player progression safely with fixed save slots and autosave-only behavior. The first clickable player-facing screen is Save Slot Select. After a slot is selected, the player enters the Profile Main Screen unless an interrupted run requires a Resume / Forfeit decision. Mid-run state is stored as a resumable checkpoint.

## Components

- SaveManager (autoload)
- 5 fixed save slots minimum
- Save slot metadata for the slot select screen
- Serialization format
- Versioning
- Save-collector protocol (each system exposes `to_save_dict` / `from_save_dict`)
- Permanent meta-progression
- Permanent run history
- Talent choices
- Unlocked maps / characters / Spells
- Active run checkpoint (`active_run.json`)
- Run history archive (`run_history.json`)
- Backup of last known good save
- Autosave indicator hooks

## Current Status

- [x] SaveManager autoload
- [x] 5-slot management (create, list, select, delete) — M6
- [x] Slot metadata (`SaveMetadata`) — M6
- [x] File format: JSON via `FileAccess`, one folder per slot — M6
- [x] Version field on every payload — M6
- [x] Registry of saveable systems (`register_saveable` / `unregister_saveable` API)
- [ ] Talent tree save data (M7)
- [ ] Meta-currency / post-run reward save data (M7)
- [x] Run history save data (`run_history.json`, cap 100) — M6
- [~] Map unlock save data (default pool per profile; runtime unlocks in M7)
- [x] Active run checkpoint save / load (`active_run.json`) — M6
- [x] Resume / Forfeit interrupted run flow — M6
- [x] Autosave-only flow — M6 (checkpoint every 30s + on level-up; profile on run end)
- [x] Atomic writes and `.bak` backup for `profile.json` — M6
- [x] Talent progression save shape documented

## Design Rules

- Every gameplay system MUST expose saveable data. See [../.cursor/rules/70-save-system.mdc](../../.cursor/rules/70-save-system.mdc).
- Never assume state is temporary.
- Save files are versioned. A missing field is not an error; it uses a default.
- Do not save node paths or object references. Use stable string IDs.
- Save writes are atomic (write to temp, rename on success).
- Save permanent meta-progression: talent choices, unlocked maps, unlocked characters, unlocked talent-granted Spells, currencies.
- Do not save temporary level-up Spells or run-only Buffs as permanent progression.
- Temporary run powers may be restored from `active_run.json` if the player resumes an interrupted run.
- Temporary run powers are deleted on normal run end or forfeit.
- No manual save button during gameplay. Progression uses autosave only.
- Delete slot and overwrite slot actions require confirmation.
- If a save fails to load, show a clear error and do not delete it automatically.
- Keep one `.bak` copy of the last known good save per slot.
- A resumed run must never grant post-run rewards twice.
- Run history is permanent profile data and records completed or forfeited runs.
- Keep the latest 100 run history entries per slot for MVP to prevent unbounded save growth.
- Run history is read-only to the player; it is not edited manually.
- Old profiles without run history load with an empty history list.
- Talent choices are saved as stable Talent IDs and ranks, never Resource paths.
- Talent-granted Spells are saved by stable Spell IDs or reconstructed from saved Talents.
- The first talent implementation allows free spending across all 3 trees.
- The future selected main magic school and secondary-tree threshold must be saved when those rules are added.
- The temporary talent reset button is a testing action that refunds spent points and removes saved Talent ranks.
- The temporary game-master toggle is a test-only UI/dev state and should not be treated as earned permanent progression.

## Talent Progression Data

Permanent profile data for Talent Trees should include:

- `talent_currency`: integer amount of the post-run resource available to spend. The final resource name and earning formula are TBD.
- `spent_talents`: dictionary keyed by stable Talent ID, with integer rank values.
- `unlocked_talent_spells`: array of stable Spell IDs if not reconstructed directly from `spent_talents`.
- `selected_main_tree`: stable tree ID, later. Empty or missing means no main tree selected yet.
- `game_master_enabled`: optional testing flag for local development only. Do not rely on this for shipped progression.

Example conceptual shape:

```json
{
  "talent_currency": 12,
  "spent_talents": {
    "ember_spark": 1,
    "frost_ice_lance": 1,
    "arcane_focus": 2
  },
  "unlocked_talent_spells": [
    "ice_lance"
  ],
  "selected_main_tree": ""
}
```

Reset-for-testing behavior:

- Refund all spent Talent points back into `talent_currency`.
- Clear `spent_talents`.
- Clear or rebuild `unlocked_talent_spells`.
- Ask Skills/Buffs/Stats to remove and rebuild talent-granted permanent effects.
- Autosave the resulting profile once Save is implemented.

## Save Slot Flow

The first clickable screen after launching the game is Save Slot Select.

Each slot displays metadata:

- Slot number
- Character name or placeholder
- Total play time
- Last played timestamp
- Highest unlocked map / current progression summary
- Whether an active run checkpoint exists
- Corrupt / unreadable marker if needed

Selecting a slot:

1. If the slot is empty, create a new profile.
2. If the slot has no active run checkpoint, load the profile and enter the Profile Main Screen.
3. If the slot has `active_run.json`, show **Resume Run** / **Forfeit Run** before entering the profile.

Forfeiting a run deletes `active_run.json`. MVP rule: forfeited runs grant no run rewards.

Returning to Save Slot Select unloads the current profile UI state. Any permanent progression changes must already be autosaved before leaving the profile.

## Autosave Policy

Permanent progression saves immediately after:

- Talent purchase / upgrade
- Map unlock
- Character unlock
- Talent-granted Spell unlock
- Run reward applied
- Settings changed

Active run checkpoints save:

- Every 10 seconds during an active run (`RunManager.CHECKPOINT_INTERVAL_SECONDS`)
- The moment a level-up card set is presented (level-up + spells given)
- The moment the player picks a level-up card (after reward is applied)
- On Leave-to-Hub (Pause Menu)
- After boss / major event, later if those exist

Do not save every few seconds by default. Event-based autosave plus a 30-second timer avoids unnecessary disk writes and reduces stutter risk.

## File Layout

Conceptual local layout:

```text
user://saves/
  slot_1/
    profile.json
    profile.json.bak
    active_run.json
    active_run.json.bak
    metadata.json
  slot_2/
    profile.json
    active_run.json
    metadata.json
```

`profile.json` stores permanent progression.

`active_run.json` stores only the current interrupted run checkpoint.

`run_history.json` stores permanent completed / forfeited run summaries.

`metadata.json` stores fast-to-read data for the Save Slot Select screen.

Optional layout with run history:

```text
user://saves/
  slot_1/
    profile.json
    profile.json.bak
    active_run.json
    active_run.json.bak
    run_history.json
    run_history.json.bak
    metadata.json
```

## Run History Storage

Run history is appended when a run ends or is forfeited.

Rules:

- Add exactly one `RunHistoryEntry` per ended / forfeited run.
- Forfeited runs are recorded with `end_reason = "forfeit"` and no rewards for MVP.
- Keep latest 100 entries per slot.
- Store stable IDs for maps, characters, enemies, Spells, Buffs, and rewards.
- Do not store node paths or live object references.
- If history fails to save, do not corrupt `profile.json`; report the error clearly.

## Public API

```gdscript
class_name SaveManager  # autoload

signal current_slot_changed(slot: int)
signal save_started(slot: int)
signal save_completed(slot: int)
signal load_completed(slot: int)
signal autosave_started(slot: int)
signal autosave_completed(slot: int)
signal save_failed(slot: int, reason: String)
signal slot_list_changed()
signal run_history_updated(slot: int)

# Slot management
func slot_count() -> int
func list_slots() -> Array[SaveMetadata]
func get_slot_metadata(slot: int) -> SaveMetadata
func slot_exists(slot: int) -> bool
func create_slot(slot: int, character_name: String) -> bool
func select_slot(slot: int) -> bool
func unload_current_slot() -> void
func delete_slot(slot: int) -> bool
func current_slot() -> int
func has_current_slot() -> bool
func current_metadata() -> SaveMetadata

# Profile
func save_current_profile() -> bool

# Active run checkpoint
func has_active_run(slot: int = -1) -> bool
func save_active_run(checkpoint: Dictionary) -> bool
func load_active_run(slot: int = -1) -> Dictionary
func clear_active_run(slot: int = -1) -> bool

# Run history
func get_run_history(slot: int = -1) -> Array[RunHistoryEntry]
func append_run_history(entry: RunHistoryEntry) -> bool

# Saveable registry (for future systems)
func register_saveable(id: StringName, obj: Object) -> void
func unregister_saveable(id: StringName) -> void
```

Registered objects must implement:

```gdscript
func to_save_dict() -> Dictionary
func from_save_dict(data: Dictionary) -> void
```

## Dependencies

- All gameplay systems (as saveable clients).
- Core (game state on load).
- Run (hands over permanent post-run rewards and RunHistoryEntry records)
- Skills (talent choices and unlocked Spells)
- World (unlocked maps)
- UI (Save Slot Select, Resume / Forfeit modal, autosave indicator)

## Open Questions

- Cloud saves (Steam Cloud) — plan for it now, integrate in M9.
- Save file encryption / obfuscation?
- What exact reward currency buys Talent upgrades?
- Should forfeited runs grant partial rewards later, or always no rewards?
- Should players be allowed to clear run history separately from deleting a save slot?

## References

- [../ARCHITECTURE.md](../ARCHITECTURE.md#save-system)
- [.cursor/rules/70-save-system.mdc](../../.cursor/rules/70-save-system.mdc)
