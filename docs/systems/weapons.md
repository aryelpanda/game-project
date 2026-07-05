# Weapons System

Status: Not Started

## Goal

Define weapons, execute attacks, manage cooldowns and scaling. Weapons produce DamageEvents; they do not calculate final damage.

## Components

- `WeaponData` Resource
- Weapon script / scene
- Cooldown handling
- Attack execution (melee, ranged via Projectiles)
- Upgrade / scaling hooks

## Current Status

- [ ] `WeaponData` Resource type
- [ ] Base Weapon script
- [ ] First weapon defined as `.tres`
- [ ] Cooldown timer
- [ ] Attack triggers Combat
- [ ] Ranged path uses Projectiles

## Design Rules

- Weapons use the Combat System for damage. They do not compute final damage themselves.
- Weapon parameters live in `WeaponData` Resources (`content/weapons/*.tres`).
- No hardcoded damage / cooldown / range in scripts.
- Weapons are equippable — they interact with Equipment via well-defined slots.
- Weapon upgrades are a separate concern (Skills / progression), not baked into WeaponData at author time.

## Public API

```gdscript
class_name WeaponData
extends Resource

@export var display_name: String
@export var damage: float
@export var cooldown: float
@export var range: float
@export var projectile_data: ProjectileData  # optional (ranged)
@export var icon: Texture2D
```

```gdscript
class_name Weapon

signal attack_started()
signal attack_landed(target: Node)

@export var data: WeaponData

func can_attack() -> bool
func attack(direction: Vector2) -> void
```

## Dependencies

- Combat (emits DamageEvents)
- Projectiles (for ranged attacks)
- Stats (weapon scaling)
- Equipment (equipped weapon slots)

## Open Questions

- Do weapons have durability?
- Dual-wielding? Multi-weapon sets?

## References

- [../ARCHITECTURE.md](../ARCHITECTURE.md#weapon-system)
