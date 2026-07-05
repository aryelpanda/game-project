# Buffs System

Status: MVP

## Goal

Track modifiers on an entity. Buffs can be temporary run rewards, timed status effects, or permanent talent effects.

## Components

- `BuffData` Resource
- Active buff instances with durations
- Buff lifetime type (run-only, timed, permanent)
- Buff stacking rules
- Tick behavior (damage-over-time, regen)
- Buff application and removal

## Current Status

- [x] `BuffData` Resource
- [x] Buff container per Actor (`BuffContainer` on Player)
- [x] Lifetime type support (`run_only` for level-up rewards)
- [ ] Duration timers
- [ ] Stacking policies
- [ ] Tick pipeline
- [x] Stats integration (modifier source via `StatModifier`)
- [x] Permanent talent passive design documented

## Design Rules

- Buffs are one of the main sources of Stat modifiers.
- A Buff's lifetime is explicit: `RUN_ONLY`, `TIMED`, or `PERMANENT`.
- Level-up Buffs are `RUN_ONLY` and are removed when the Run ends.
- Talent Buffs are `PERMANENT` and persist through Save.
- Every buff has a stacking policy: `NONE`, `REFRESH`, `STACK_MAGNITUDE`, `STACK_DURATION`.
- Ticks flow through the Combat system for damage-over-time — Buffs never call `take_damage` directly.
- Temporary run Buffs are not saved after the Run ends. Mid-run saving is not supported unless approved later.
- Permanent talent Buffs are reconstructed from saved Talent choices.
- Removing a buff removes ALL its modifier contributions from Stats.
- Talent passives should be represented as permanent Buffs whenever they modify Stats.
- Talent reset removes every Buff source created by unlocked Talents, then rebuilds Stats from the remaining sources.
- Buffs that modify Stats must expose display names and source IDs so the Character Stats screen can explain passive and temporary bonuses.

## Talent Passive Buffs

Talent-granted passive effects are permanent profile progression, but Buffs do not own the player's talent choices. Skills owns purchased Talent ranks, Save persists them, and Buffs provides the modifier container used by Stats.

Expected flow:

1. Skills unlocks or ranks up a Talent.
2. If the Talent has `passive_buff`, Skills asks the player's `BuffContainer` to apply it with a Talent source ID.
3. Buffs forwards its `StatModifier` entries to Stats.
4. Save stores the Talent rank, not the live Buff instance.
5. On profile load, Skills reconstructs permanent talent Buffs from saved Talent ranks.

For the first test trees, permanent Buffs can cover simple stat modifiers such as damage, max health, max mana, mana regen, cooldown reduction, area size, projectile count, projectile speed, XP gain, pickup radius, and armor.

## Stats Screen Display Sources

Buffs should provide enough metadata for Stats/UI to show where each modifier came from:

- Permanent passive Buffs from Talents.
- Permanent equipment Buffs or modifiers, later.
- Run-only Buffs from level-up skills.
- Run-only Buffs from temporary items found during a run.
- Timed status effects, if they affect visible character stats.

Out of run, the Character Stats screen should show permanent passive Buff sources only. During a run, it should also show run-only and timed Buff sources separately so the player can understand which bonuses will disappear after the run ends.

## Public API

```gdscript
class_name BuffData
extends Resource

@export var id: StringName
@export var display_name: String
@export var lifetime: StringName     # "run_only", "timed", "permanent"
@export var duration: float          # 0 or negative = permanent
@export var stacking: StringName     # "none", "refresh", "stack_magnitude", "stack_duration"
@export var modifiers: Array[StatModifier]
@export var tick_interval: float = 0.0
@export var tick_damage: DamageEvent  # optional
@export var icon: Texture2D
@export var description: String
```

```gdscript
class_name BuffContainer

signal buff_applied(buff: Buff)
signal buff_expired(buff: Buff)

func apply(data: BuffData, source: Node) -> void
func remove(id: StringName) -> void
func has(id: StringName) -> bool
```

## Dependencies

- Stats (pushes modifiers)
- Combat (tick damage)
- Run (clears run-only Buffs at run end)
- Skills (Talent Buffs)
- Save

## Open Questions

- Diminishing returns for repeated crowd control?
- Immunity system — per-buff-ID cooldown after expiry?
- Are level-up Buffs allowed to stack infinitely, or do they upgrade existing Buffs?

## References

- [../ARCHITECTURE.md](../ARCHITECTURE.md#buff-system)
