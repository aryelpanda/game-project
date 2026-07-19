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

- [x] UIManager screen stack + modal layer + toast (M6)
- [x] Save Slot Select screen (M6)
- [x] Resume / Forfeit modal (M6)
- [x] Profile Main Screen / hub (M6)
- [x] Map Selection screen (M6)
- [x] Autosave indicator (M6 non-blocking fade)
- [x] HUD: timer, kills, run level, XP bar, HP, mana (M6 adds vitals + Stats button)
- [x] Level-up choice screen (M4 minimal overlay; green effect line per reward)
- [x] Run powers panel (M4 right-side active spell/buff list + test grant-all / end-run buttons)
- [x] Run summary screen (time, kills, spells/buffs with levels, per-spell damage; M6 adds "Return to Hub" button)
- [x] Run History screen (M6)
- [x] Run History details screen (M6)
- [~] Talent tree screen (M6 placeholder; full behavior in M7)
- [~] Inventory screen placeholder (M6)
- [x] Character Stats screen (M6 out-of-run and in-run modes)
- [~] Settings screen (M6 stub; full options in M11)
- [x] Pause menu (M6: Esc / gamepad Select; Resume / Stats / Leave / Forfeit)
- [ ] Main menu (folded into Save Slot Select for MVP)
- [~] Tooltip system (M6 uses Godot built-in `tooltip_text`; custom system deferred)
- [~] Notification queue (M6: simple toast via UIManager)
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
- Level-up cards show: type + name, description, then a left-aligned green `level_up_effect_text` line (e.g. `+25% attack`, `+1 star`). Author this on every reward `.tres`.
- Run summary displays time survived, enemies killed, run level reached, chosen spells/buffs with levels, per-spell damage, and post-run reward.
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

signal screen_pushed(screen: Control)
signal screen_popped(screen: Control)

# Screen stack (fullscreen). Pushing hides the previous screen.
func push_screen(scene: PackedScene) -> Control
func replace_screen(scene: PackedScene) -> Control
func pop_screen() -> void
func clear_screens() -> void
func current_screen() -> Control

# Modals (drawn above screens; do NOT hide the screen behind).
func push_modal(scene: PackedScene) -> Control
func pop_modal() -> void
func clear_modals() -> void

# Notifications.
func show_toast(message: String, duration: float = 3.0) -> void
```

Screens live on a persistent `CanvasLayer` (layer 100) as a child of the `UIManager` autoload, so they survive `change_scene_to_file` calls. Modals live on a separate always-processing layer (layer 110). Each concrete screen script (Save Slot Select, Profile Hub, Map Select, Run History, Character Stats, Settings, Pause Menu, Resume/Forfeit modal) owns its own layout and reads state directly from the owning system (Save, Run, Player).

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
