# Stats System

Status: In Progress

## Goal

Single source of truth for all numeric gameplay attributes on an entity. Survivor-style scaling depends heavily on temporary and permanent stat modifiers.

## Components

- Base stats (from character data or `StatsData` Resource)
- Derived stats (computed from bases)
- Modifiers (flat, multiplicative, additive percentage)
- Modifier sources (temporary run Buffs, permanent Talent Buffs, Spells, future equipment)
- Survivor stat catalog

## Current Status

- [x] `StatsData` Resource for base values
- [x] StatsBlock runtime class
- [x] Modifier system with sources (`StatModifier`, flat + percent_add)
- [ ] Source lifetime support (run-only vs permanent) — partial via modifier lifetime field
- [x] Recompute pipeline (on modifier add/remove)
- [x] Signals for change notifications (`stat_changed`)
- [x] Character stat layers and Stats screen display model documented

## Design Rules

- All gameplay systems READ from Stats.
- No gameplay system OWNS permanent stat state — only Stats does.
- Modifiers are attributed to a source (Buff ID, Talent ID, Spell ID). Removing the source removes its modifiers.
- Sources must declare lifetime: run-only, timed, or permanent.
- Recompute only when dirty. Avoid recomputing every frame.
- Derived stat formulas live in one place and are documented here.
- Character stats are calculated from base values plus modifier layers.
- Base stats are character identity data and will be designed / balanced later.
- Permanent modifiers can come from Talent passives, equipped items, and future profile systems.
- Temporary run modifiers can come from run-level skills, run-only Buffs, and temporary items found during a run.
- Temporary run modifiers are cleared when the run ends, returning the character to the normal out-of-run state.

## Character Stat Layers

Stats must keep these layers conceptually separate so UI can explain where a final value came from:

| Layer | Lifetime | Examples | Saved Permanently? |
| ----- | -------- | -------- | ------------------ |
| Base | Character / profile baseline | Starting health, mana, attack power | Yes, by stable character / StatsData ID later |
| Permanent modifiers | Out-of-run progression | Talent passives, equipped item bonuses, future account progression | Yes, by source data such as Talent ranks or equipped items |
| Temporary run modifiers | Current run only | Level-up skills, run-only Buffs, temporary run items | No after run end |
| Final current value | Calculated result | What Combat, Player, Skills, and UI read | Recomputed, not saved directly |

Conceptual calculation:

```text
final_stat = base_stat + permanent_flat + temporary_flat
final_stat *= permanent_percent_or_multiplier
final_stat *= temporary_percent_or_multiplier
```

The exact order of operations, caps, floors, and percentage handling are still TBD. Once code exists, these formulas must live in one Stats-owned place.

## Enemy Stat Layers

Enemies use the same `StatsBlock` runtime class as the player, but their layer model is simpler:

| Layer | Lifetime | Examples | Saved Permanently? |
| ----- | -------- | -------- | ------------------ |
| Base | Enemy identity (from `EnemyData.stats`) | Max health, move speed, damage, crit chance, mana | Yes, by `EnemyData` |
| Spawn / elite modifiers | Enemy lifetime | "Elite pack: +50% health", "Rare: +20% damage" | No |
| In-combat debuffs | Debuff duration | Chill, curse, burn, armor shred applied by player Spells / Buffs | No |
| Final current value | Calculated result | What Combat and enemy AI read | Recomputed, not saved |

Enemies have no talent layer, no run-reward layer, and no permanent progression layer. Only the sources and lifetimes differ from the player - the underlying `StatsBlock`, modifier attribution, and recompute pipeline are identical.

## Initial Character Stat List

These are broad placeholder RPG / survivor stats for testing and UI design. Exact starting values, formulas, caps, and final names will be designed and tuned later. The catalog is shared between the player and enemies, though some entries (`xp_gain`, `pickup_radius`) are player-only in practice.

| Stat | Category | Purpose |
| ---- | -------- | ------- |
| `max_health` | Core resource | Player / enemy maximum health. |
| `health_regen` | Core resource | Health restored over time. |
| `max_mana` | Core resource | Player / enemy mana pool for Spells and enemy skills. |
| `mana_regen` | Core resource | Mana restored over time. |
| `attack_power` | Offense | Baseline attack strength for weapon-like or generic attacks. |
| `spell_power` | Offense | Baseline strength for Spells and magic scaling. |
| `damage_multiplier` | Offense | Generic multiplier for outgoing damage. |
| `critical_chance` | Offense | Chance for compatible damage to critically hit. |
| `critical_damage` | Offense | Extra damage dealt by critical hits. |
| `armor` | Defense | Reduces incoming damage. |
| `damage_reduction` | Defense | Generic incoming damage reduction. |
| `dodge_chance` | Defense | Chance to avoid compatible incoming hits. |
| `move_speed` | Mobility | Player / enemy movement speed. |
| `pickup_radius` | Collection | Range for collecting XP or future drops. |
| `cooldown_reduction` | Spell scaling | Reduces Spell cooldowns. |
| `area_size` | Spell scaling | Increases area-of-effect sizes. |
| `duration` | Spell scaling | Increases duration of temporary effects / projectiles. |
| `projectile_count` | Spell scaling | Adds projectiles to compatible Spells. |
| `projectile_speed` | Spell scaling | Changes projectile travel speed. |
| `xp_gain` | Progression | Increases XP gained during a run. |

## Stats Screen Data

The Stats system should expose enough breakdown data for UI to show both normal character stats and current run stats.

Out of run, the Character Stats screen should show:

- Base value.
- Permanent bonus total.
- Final normal value.
- Permanent passive Buffs / Talent / Equipment sources contributing to each value.

During a run, the Character Stats screen should also show:

- Temporary run bonus total.
- Final current run value.
- Temporary sources, such as chosen run skills, run-only Buffs, and temporary run items.

UI should never calculate these totals itself. It should ask Stats for a display-ready breakdown or query Stats-owned values and source lists.

## Public API

```gdscript
class_name StatsBlock

signal stat_changed(stat: StringName, new_value: float)

func get_stat(stat: StringName) -> float
func get_base_stat(stat: StringName) -> float
func get_stat_breakdown(stat: StringName) -> Dictionary
func add_modifier(source: StringName, mod: StatModifier) -> void
func remove_modifiers_from(source: StringName) -> void
```

```gdscript
class_name StatModifier
extends Resource

@export var stat: StringName
@export var type: StringName    # "flat", "percent_add", "multiplier"
@export var value: float
@export var lifetime: StringName # "permanent", "run_only", "timed"
@export var display_name: String
```

## Dependencies

- None outbound. Everyone depends on Stats.

## Open Questions

- Order of operations for flat / percent / multiplier stacking.
- Cap and floor handling for derived stats.
- Which stats apply globally versus only to specific Spell tags?

## References

- [../ARCHITECTURE.md](../ARCHITECTURE.md#stats-system)
