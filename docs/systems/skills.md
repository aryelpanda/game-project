# Skills System

Status: MVP

## Goal

Own Spells and Talent Trees. This system separates temporary in-run powers from permanent meta-progression. `SpellData` is the shared Resource shape for any active ability that goes through Combat, including enemy skills; content pools remain separate.

## Components

- `SpellData` Resource
- Temporary run Spell registry
- Talent-granted Spell registry
- Cooldown tracking
- Mana cost rules
- `TalentTreeData` and `TalentData` Resources
- Talent unlock and upgrade flow
- Passive talent hooks (Buff registration)

## Current Status

- [x] `SpellData` Resource
- [x] `TalentTreeData` / `TalentData` Resources — M7
- [x] Runtime temporary spell registry (`RunSpellController` on Player)
- [x] Temporary run reward application (via RunManager → Player)
- [x] Talent unlock / upgrade API (`TalentManager` autoload) — M7
- [x] Spell leveling on repeat level-up picks (`upgrade_spell`, `get_spell_level`)
- [x] Passive Talent -> permanent Stat modifier registration (`apply_to_player`) — M7
- [x] Talent-granted Spell unlocks applied at run start — M7
- [x] First-pass Talent Tree design documented for testing

## Design Rules

- Spells remain independent of specific weapons.
- Active Spells go through Combat like every other damage source.
- Level-up Spells are temporary, cost no mana, auto-fire on cooldown (except `manual` type), and are cleared at Run end.
- Talent-granted Spells are permanent unlocks, have cooldowns, and may cost mana.
- Passive Talents register themselves as sources of Buffs / Stat modifiers on the player.
- `SpellData` is the shared Resource shape used by both player Spells and enemy skills.
- Player Spell data lives in `content/spells/*.tres`. Enemy skill data lives in `content/enemy_skills/*.tres`. These pools **never mix**.
- Enemy skills never appear in the player level-up reward pool. Player Spells never appear on enemies.
- The `is_talent_granted` field on `SpellData` is always `false` for enemy skills.
- Enemy skills are owned and managed by the Enemies system, not the Skills system. Skills only defines the shared data shape.
- Talent data lives in `content/talents/*.tres`.
- Talent unlock conditions are defined in data, not hardcoded.
- The first implementation uses free spending across all 3 trees for testing.
- Later, the player chooses one main magic school and may need to spend a TBD number of points in that school before investing in the others.
- Talent currency is earned during a run and spent after the run. The exact resource name and earning formula are TBD.
- Reset and game-master controls are temporary testing tools, not final progression rules.

## Talent Tree MVP Design

The first talent-tree pass has 3 placeholder magic schools with 10 test talents each. These talents exist to validate spending, permanent passive Buffs, saved ranks, unlocked talent-granted Spells, reset, and game-master testing controls. Names, values, and final structure are intentionally replaceable.

For the first implementation:

- The player can spend points in any tree.
- Each talent costs 1 point per rank unless the data says otherwise later.
- Talents can grant a permanent passive Buff, unlock a Spell, or both.
- A talent purchase autosaves permanent progression once Save exists.
- The reset button refunds all spent talent points and removes all talent-granted Buffs / Spells for testing.
- The game-master toggle makes the Talent Tree screen behave as if the player has unlimited points while enabled.

Future main-school behavior:

- The player chooses one main tree.
- Secondary trees remain locked or limited until a TBD number of points has been spent in the main tree.
- The chosen main tree, threshold, and secondary-tree rules must be data-driven.

## Test Talent Trees

These are placeholder trees for early testing only. Final talent names, themes, icons, values, layout, and unlock rules will be designed later.

### Ember Tree

| ID | Talent | Test Effect |
| -- | ------ | ----------- |
| `ember_spark` | Spark Training | +5% damage. |
| `ember_warmth` | Warmth | +5 max health. |
| `ember_quick_cast` | Quick Cast | +3% cooldown reduction. |
| `ember_flame_orb` | Flame Orb | Unlocks the test Spell `flame_orb`. |
| `ember_burning_focus` | Burning Focus | +5% damage to burn-themed Spells later. |
| `ember_wide_blast` | Wide Blast | +5% area size. |
| `ember_inner_fire` | Inner Fire | +0.5 mana regen. |
| `ember_double_spark` | Double Spark | +1 projectile count for compatible Spells. |
| `ember_cinder_skin` | Cinder Skin | +2 armor. |
| `ember_meteor_seed` | Meteor Seed | Unlocks the test Spell `meteor_seed`. |

### Frost Tree

| ID | Talent | Test Effect |
| -- | ------ | ----------- |
| `frost_clear_mind` | Clear Mind | +5 max mana. |
| `frost_steady_steps` | Steady Steps | +3% move speed. |
| `frost_cool_flow` | Cool Flow | +3% cooldown reduction. |
| `frost_ice_lance` | Ice Lance | Unlocks the test Spell `ice_lance`. |
| `frost_resilience` | Resilience | +10 max health. |
| `frost_glacial_armor` | Glacial Armor | +3 armor. |
| `frost_long_chill` | Long Chill | +5% duration. |
| `frost_mana_spring` | Mana Spring | +0.5 mana regen. |
| `frost_wide_freeze` | Wide Freeze | +5% area size. |
| `frost_crystal_nova` | Crystal Nova | Unlocks the test Spell `crystal_nova`. |

### Arcane Tree

| ID | Talent | Test Effect |
| -- | ------ | ----------- |
| `arcane_focus` | Arcane Focus | +5 max mana. |
| `arcane_swift_mind` | Swift Mind | +3% cooldown reduction. |
| `arcane_reach` | Reach | +5% pickup radius. |
| `arcane_magic_missile` | Magic Missile | Unlocks the test Spell `magic_missile`. |
| `arcane_overcharge` | Overcharge | +5% damage. |
| `arcane_channeling` | Channeling | +1 mana regen. |
| `arcane_split_cast` | Split Cast | +1 projectile count for compatible Spells. |
| `arcane_fast_projectiles` | Fast Projectiles | +5% projectile speed. |
| `arcane_learning` | Learning | +5% XP gain. |
| `arcane_starfall` | Starfall | Unlocks the test Spell `starfall`. |

## Public API

```gdscript
class_name SpellData
extends Resource

const TYPE_MANUAL := &"manual"
const TYPE_AUTO_PROJECTILE := &"auto_projectile"
const TYPE_ORBIT_AURA := &"orbit_aura"

@export var id: StringName
@export var display_name: String
@export var description: String
@export var level_up_effect_text: String  # green effect line on level-up UI
@export var spell_type: StringName  # manual, auto_projectile, orbit_aura
@export var cooldown: float
@export var mana_cost: float
@export var is_talent_granted: bool
@export var base_damage: float
@export var damage_type: StringName
@export var projectile_data: ProjectileData
@export var orbit_radius: float
@export var orbit_speed: float
@export var orbit_count: int
@export var orbit_hit_cooldown: float
```

```gdscript
class_name RunSpellController
extends Node2D

signal spell_granted(spell: SpellData)
signal spell_removed(spell_id: StringName)
signal powers_changed()

func grant_spell(spell: SpellData) -> void
func remove_spell(spell_id: StringName) -> void
func clear_all() -> void
func get_active_spells() -> Array[SpellData]
func has_spell(spell_id: StringName) -> bool
```

Talent data resources (M7):

```gdscript
class_name TalentData
extends Resource

@export var id: StringName
@export var tree_id: StringName
@export var display_name: String
@export var description: String
@export var icon: Texture2D           # optional; colored placeholder if null
@export var max_rank: int
@export var cost_per_rank: int
@export var tier: int                 # grid row (WotLK-style layout)
@export var column: int               # grid column
@export var requires: StringName      # prerequisite id (arrows only in MVP)
@export var effect_modifiers: Array[StatModifier]  # permanent, per rank
@export var unlock_spell: SpellData   # optional permanent Spell unlock
```

```gdscript
class_name TalentTreeData
extends Resource

@export var id: StringName
@export var display_name: String
@export var theme_color: Color
@export var icon: Texture2D
@export var talents: Array[TalentData]
```

`TalentManager` autoload (M7) owns permanent progression and is registered as
the `&"talents"` SaveManager saveable:

```gdscript
# TalentManager  # autoload

signal talent_points_changed(points: int)
signal talent_rank_changed(talent_id: StringName, rank: int)
signal talents_reset()
signal talents_loaded()

func get_trees() -> Array[TalentTreeData]
func get_talent(talent_id: StringName) -> TalentData
func get_rank(talent_id: StringName) -> int
func available_points() -> int
func spent_points(tree_id: StringName = &"") -> int
func add_points(amount: int) -> void            # run rewards
func can_unlock(talent_id: StringName) -> bool
func unlock_talent(talent_id: StringName) -> bool
func refund_talent(talent_id: StringName) -> bool
func reset_talents() -> void
func is_game_master() -> bool
func set_game_master_enabled(enabled: bool) -> void
func apply_to_player(player: Node) -> void       # called from Player._ready()
func get_permanent_preview() -> StatsBlock       # for Character Stats screen
func to_save_dict() -> Dictionary
func from_save_dict(data: Dictionary) -> void
func reset_runtime() -> void                     # on slot unload / new profile
```

Mutations (unlock / refund / reset / GM toggle / add_points) autosave the
profile via `SaveManager.save_current_profile()` when a slot is loaded.
Talent effects are applied to the freshly spawned player at `Player._ready()`
(before starting health / mana are derived): each spent rank adds the talent's
`effect_modifiers` to the player `StatsBlock` under a `talent:<id>` source, and
`unlock_spell` talents are granted to the run spell controller.

## Dependencies

- Run (temporary level-up rewards)
- Combat (active Spells)
- Buffs (passive Talents and temporary Buff rewards)
- Stats (scaling, resource costs)
- Save

## Open Questions

- Final respec rules and cost. The first implementation has a free testing reset button.
- Post-run talent currency source / formula. M7 uses a flat `3` points per completed run (`RunManager.TALENT_POINTS_PER_RUN`); a real formula is deferred to M9 balance.
- Which talent-granted Spells cost mana, and how much? M7 test spells use `mana_cost = 0`; mana enforcement for talent Spells is deferred.
- Placeholder stat keys (`cooldown_reduction`, `area_size`, `mana_regen`, `armor`, `projectile_count`, `duration`, `pickup_radius`, `projectile_speed`, `xp_gain`) are stored on the StatsBlock now but not yet consumed by gameplay; wired in M9.
- Main-school point threshold before secondary-tree spending (deferred; MVP is free-spend).

Resolved in M7:

- Themes: Ember (fire), Frost (ice), Arcane (purple) placeholder schools.
- Layout: WoW WotLK-style tiered grid (tier rows / columns) with decorative prerequisite arrows. Visual style only — no tier-gating in the free-spend MVP.

## References

- [../ARCHITECTURE.md](../ARCHITECTURE.md#skills-system)
- [../GLOSSARY.md](../GLOSSARY.md)
