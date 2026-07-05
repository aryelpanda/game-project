# Combat System

Status: MVP

## Goal

Central authority for damage. Every damage transaction flows through Combat. No weapon or ability directly changes HP.

## Components

- DamageManager (calculates final damage)
- Hit detection helpers
- Critical hit rules
- Status effect application (delegates to Buffs)
- DamageEvent structure
- Damage result event for Run History tracking

## Current Status

- [x] `DamageEvent` Resource / class
- [x] DamageManager singleton
- [x] Basic damage calculation (raw -> mitigated)
- [ ] Critical hit hook
- [x] Hit detection helpers (`EntityCollision` touch distance for melee contact)
- [x] Integration with Stats for defense (armor stub)
- [x] Damage result signal includes Spell / source ID for Run History

## Design Rules

- Every ability derives its damage through Combat.
- Damage goes through DamageManager.
- No spell / weapon / ability directly modifies HP.
- Combat is independent from specific weapons.
- DamageEvent is a value object, never mutated after emission.
- Combat emits enough result data for Run to track total damage, damage per Spell, kills per Spell, highest hit, and DPS estimates.
- Damage result tracking is local gameplay telemetry only. It is not an external analytics system.
- `EntityCollision` provides physics layer constants, touch-distance queries, play-area clamping, hysteresis contact (`is_in_contact`), and weak player pushback (`apply_player_pushback`).

## Public API

```gdscript
class_name DamageEvent
extends Resource

var source: Node        # runtime only; not @export (Resource cannot export Node)
var target: Node        # runtime only; not @export (Resource cannot export Node)
@export var base_damage: float
@export var damage_type: StringName  # e.g. "physical", "fire"
@export var spell_id: StringName      # optional, used for run history
@export var source_id: StringName     # stable source ID when spell_id is not enough
@export var is_critical: bool
@export var status_effects: Array[BuffData]
```

```gdscript
class_name DamageManager  # autoload or namespace

signal damage_applied(event: DamageEvent, final_damage: float)
signal target_killed(event: DamageEvent)

func apply(event: DamageEvent) -> float  # returns final damage dealt
func roll_critical(source: Node) -> bool
```

```gdscript
class_name EntityCollision
extends RefCounted

static func touch_distance(body_a: CollisionObject2D, body_b: CollisionObject2D) -> float
static func is_in_contact(body_a: CollisionObject2D, body_b: CollisionObject2D, was_in_contact: bool) -> bool
static func is_within_touch(body_a: CollisionObject2D, body_b: CollisionObject2D, extra_tolerance: float = 2.0) -> bool
static func clamp_body_to_play_area(body: CollisionObject2D, area: Rect2) -> void
static func compute_projectile_spawn_position(
	player: CharacterBody2D,
	direction: Vector2,
	projectile_radius: float,
	extra_padding: float = 2.0
) -> Vector2
static func apply_player_pushback(player: CharacterBody2D, move_direction: Vector2) -> void
```

## Dependencies

- Stats (reads attacker offense, defender defense)
- Buffs (applies status effects)
- VFX (spawns hit effects — emitted as signal, VFX subscribes)
- Audio (hit SFX — emitted as signal)
- Run (tracks damage, kills, per-Spell history stats)

## Open Questions

- Damage types and resistance system — flat table or Resource-driven?
- Are there damage-over-time ticks? Owned by Buffs, but Combat provides the tick.

## References

- [../ARCHITECTURE.md](../ARCHITECTURE.md#combat-system)
- [../GLOSSARY.md](../GLOSSARY.md)
