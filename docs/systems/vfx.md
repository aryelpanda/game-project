# VFX System

Status: Not Started

## Goal

Provide visual feedback: particles, screen shake, hit flashes, explosions. Effects are cosmetic and MUST NOT affect gameplay.

## Components

- VFXManager (autoload)
- Particle scene pool
- Screen shake controller
- Hit flash / damage numbers
- Trail / afterimage effects

## Current Status

- [ ] VFXManager autoload
- [ ] Particle scene pooling
- [ ] Screen shake with additive channels
- [ ] Damage number popups
- [ ] Hit flash shader / material

## Design Rules

- Effects NEVER modify gameplay.
- VFX is triggered by signals from Combat, Weapons, Enemies, Loot.
- Pool VFX scenes. Never instantiate in hot paths.
- Screen shake magnitudes are configurable (per-effect and global slider) and additive across simultaneous sources.
- Effects respect a global "reduce motion" accessibility flag.

## Public API

```gdscript
class_name VFXManager  # autoload

func spawn(effect_scene: PackedScene, position: Vector2, rotation: float = 0.0) -> void
func shake(magnitude: float, duration: float, source: StringName = &"") -> void
func damage_number(position: Vector2, value: float, is_critical: bool = false) -> void
```

## Dependencies

- Combat (hit / crit effects)
- Weapons (muzzle flash)
- Enemies (death effects)
- Loot (pickup sparkle)

## Open Questions

- Damage numbers — always on, always off, or a toggle in options?
- Effect quality settings for low-end hardware?

## References

- [../ARCHITECTURE.md](../ARCHITECTURE.md#visual-effects)
