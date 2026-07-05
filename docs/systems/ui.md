# UI System

Status: In Progress

## Goal

Display save-slot selection, the profile main screen, survivor run state, and out-of-run progression. Collect input for slot selection, hub navigation, map selection, resume/forfeit decisions, level-up choices, menus, and talent spending. Never own gameplay state.

## Components

- Save Slot Select screen (first clickable screen)
- Resume / Forfeit interrupted run modal
- Profile Main Screen / hub
- Map Selection screen
- HUD (health, mana, XP bar, run level, timer, kills)
- Level-up choice screen (3 random Spell / Buff options)
- Run summary screen
- Run History screen
- Run History details screen
- Talent tree screen
- Inventory screen (later / de-prioritized until needed)
- Character Stats screen
- Settings screen
- Character Design screen (future, not MVP)
- Menus (main, pause, options)
- Tooltips
- Notifications / toasts
- UIManager (top-level stack)

## Current Status

- [x] UIManager autoload stub registered
- [ ] Save Slot Select screen
- [ ] Resume / Forfeit modal
- [ ] Profile Main Screen / hub
- [ ] Map Selection screen
- [ ] Autosave indicator
- [x] HUD scaffold (M3 timer/kills; M4 XP bar + level)
- [x] Level-up choice screen (M4 minimal overlay)
- [x] Run powers panel (M4 right-side active spell/buff list + debug grant-all)
- [ ] Run summary screen
- [ ] Run History screen
- [ ] Run History details screen
- [ ] Talent tree screen
- [ ] Inventory screen placeholder
- [ ] Character Stats screen placeholder
- [ ] Settings screen
- [ ] Pause menu
- [ ] Main menu
- [ ] Tooltip system
- [ ] Notification queue
- [x] Talent Tree screen MVP behavior documented
- [x] Character Stats screen behavior documented

## Design Rules

- UI never contains gameplay logic.
- UI DISPLAYS state; it does not OWN state.
- UI reads via signals or by querying the owning system.
- UI never mutates gameplay state directly — it emits input events, which gameplay systems respond to.
- Widget scenes are reusable and self-contained.
- Localizable strings go through Godot's translation system, not hardcoded.
- The first clickable player-facing screen after launch is Save Slot Select.
- After selecting a slot, the player enters the Profile Main Screen unless the selected slot has an active run checkpoint.
- If a selected slot has an active run checkpoint, UI must show Resume Run / Forfeit Run before entering the Profile Main Screen.
- The Profile Main Screen is the out-of-run hub. It shows the current selected character in the center and the available profile actions.
- Starting a run always goes through Profile Main Screen -> Start Run -> Map Selection -> Run.
- Back to Slot Select unloads the current profile UI and returns to Save Slot Select.
- Character Design is a future feature and should not block MVP.
- Delete slot and overwrite slot actions require confirmation dialogs.
- Autosave indicator is small and non-blocking; it must not interrupt gameplay.
- The level-up screen displays exactly 3 reward choices for MVP.
- Run summary displays time survived, enemies killed, run level reached, and post-run reward.
- Run History is read-only player-facing data.
- MVP Run History can be a simple latest-runs list with a details screen.
- Later sorting/filtering is allowed but not required for MVP.
- Talent Tree UI reads Talent data and progression state from Skills / Save-facing APIs.
- Talent Tree UI emits purchase, reset, and game-master toggle requests. It does not apply Buffs, unlock Spells, or mutate save data directly.
- Character Stats UI reads calculated values and modifier breakdowns from Stats. It does not calculate base, permanent, temporary, or final values itself.

## Run History Display

Run History list should show:

- Map
- Character
- Duration
- End reason
- Final level
- Total kills
- Total damage
- Top Spell

Run History details should show:

- Time played / survived
- Map
- Character
- Total kills
- Total damage done
- Damage taken
- Healing received
- Mana spent
- XP collected
- Level-ups gained
- Spells chosen
- Buffs chosen
- Damage and kills per Spell
- Enemies killed by type
- Rewards earned

## Profile Main Screen

The Profile Main Screen appears after a save slot is selected and any active run checkpoint is resolved.

It shows:

- Current selected character in the center.
- Current profile / slot state.
- Navigation options.

Initial options:

- **Start Run** -> opens Map Selection.
- **Talent Tree** -> opens permanent progression.
- **Inventory** -> later / de-prioritized until needed.
- **Run History** -> opens completed / forfeited run records.
- **Stats** -> opens profile / character stats and permanent passive Buffs.
- **Settings** -> opens options.
- **Back to Slot Select** -> returns to Save Slot Select.
- **Character Design** -> future feature, not MVP.

## Map Selection

Map Selection is opened from **Start Run** on the Profile Main Screen.

It shows unlocked maps from Save / World data and returns the selected `map_id` to Run.

## Talent Tree Screen

The first Talent Tree screen is a testing-focused MVP for permanent progression. It should be clear and replaceable rather than visually final.

It shows:

- Current available Talent points.
- 3 magic-school trees: Ember, Frost, and Arcane as placeholder names.
- 10 test talents per tree.
- Each Talent's name, rank, cost, short effect text, and whether it unlocks a Spell.
- Purchase / rank-up action for each Talent.
- A reset button for testing.
- A game-master toggle that makes spending behave as if the player has unlimited points.

First-pass rules:

- Spending is allowed in any tree.
- No main-school selection is enforced yet.
- Disabled states should explain why a Talent cannot be purchased once prerequisites or costs exist.
- Reset and game-master controls are temporary testing controls and should be visually marked as debug/test features later.

Expected UI-to-system flow:

1. UI requests the current Talent state from Skills.
2. Player selects a Talent.
3. UI emits a purchase request with the Talent ID.
4. Skills validates cost/rules, updates progression, applies Buffs/unlocks Spells, and triggers autosave when Save exists.
5. UI refreshes from the updated Skills state.

## Character Stats Screen

The Character Stats screen is opened from the Profile Main Screen's **Stats** button and should also be accessible during a run, likely from the HUD or pause menu once those screens exist.

Out of run, it shows the character's normal state:

- Current health and mana where relevant.
- Base stat value.
- Permanent bonus total.
- Final normal value.
- Permanent passive Buffs and sources, such as Talents and equipped items later.

During a run, it shows both normal and run-modified state:

- Base stat value.
- Permanent bonus total.
- Temporary run bonus total.
- Final current run value.
- Temporary sources from chosen run skills, run-only Buffs, and temporary run items.

The screen should make it clear which bonuses are permanent and which will disappear when the run ends. Out of run, temporary columns may be hidden or displayed as zero. During a run, temporary modifiers should be grouped separately from permanent passive buffs.

Example row layout:

| Stat | Base | Permanent | Temporary Run | Final |
| ---- | ---- | --------- | ------------- | ----- |
| Attack Power | TBD | +TBD | +TBD | TBD |
| Max Health | TBD | +TBD | +TBD | TBD |

Exact numbers and starting values are intentionally TBD until character balance is designed.

## Public API

```gdscript
class_name UIManager  # autoload

func push_screen(scene: PackedScene) -> Control
func pop_screen() -> void
func show_toast(message: String, duration: float = 3.0) -> void
func show_tooltip(anchor: Control, item: ItemData) -> void
func show_save_slot_select(slots: Array[SaveMetadata]) -> void
func show_resume_or_forfeit(slot: int) -> void
func show_profile_main_screen(slot: int) -> void
func show_map_selection(maps: Array[MapData]) -> void
func show_autosave_indicator(active: bool) -> void
func show_level_up_choices(options: Array) -> void
func show_run_summary(summary: RunSummary) -> void
func show_run_history(entries: Array[RunHistoryEntry]) -> void
func show_run_history_details(entry: RunHistoryEntry) -> void
func show_talent_tree(character_id: StringName) -> void
func show_inventory() -> void
func show_character_stats(character_id: StringName) -> void
func show_run_character_stats(character_id: StringName) -> void
func show_settings() -> void
func return_to_slot_select() -> void
```

## Dependencies

- Reads from: Save, World, Player, Run, Stats, Skills, Buffs.
- Emits: slot selected, new slot requested, delete slot requested, resume selected, forfeit selected, start run selected, map selected, back to slot select selected, level-up choice selected, talent selected, spell cast input, menu commands.

## Open Questions

- Diegetic HUD (in-world) vs classic overlay?
- Controller-first navigation vs mouse-first?
- Accessibility features scope (colorblind modes, text scaling, remapping)?
- Does level-up pause the run fully, slow time, or keep enemies moving?

## References

- [../ARCHITECTURE.md](../ARCHITECTURE.md#ui-system)
