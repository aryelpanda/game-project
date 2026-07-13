# Projectiles System

Status: MVP

## Goal

Generic projectile motion, collision, lifetime, and pooling. Projectiles are agnostic of their owner and payload.

## Components

- `ProjectileData` Resource
- Base Projectile scene / script
- ProjectileManager (pooling)
- Impact events
- Lifetime handling

## Current Status

- [x] `ProjectileData` Resource
- [x] Base Projectile scene
- [x] ProjectileManager autoload with pooling
- [x] Collision -> impact event
- [x] Lifetime timeout
- [x] Circular sphere-style visual sized from `ProjectileData.radius`
- [x] Optional `SpriteFrames` animation on projectiles (Craftpix fireball test)

## Design Rules

- Projectiles remain generic. Damage and effects come from the DamageEvent they carry, not from projectile subclasses.
- Optional `sprite_frames` on `ProjectileData` drive an `AnimatedSprite2D`. When unset, a circular placeholder is drawn.
- Sprite scale is derived from `radius`, `visual_size_multiplier`, and `sprite_content_size`.
- Always pool projectiles. Never instantiate in hot loops.
- Projectiles do not know about specific weapons — they are configured with a payload at spawn time.
- Collision layers are set from ProjectileData, not hardcoded per scene.
- Pooled projectiles stay under `ProjectileManager` (autoload `Node2D`, `z_index = 10`). Never reparent nodes — reparenting during scene load or physics flush causes engine errors.
- Pool despawn must use `call_deferred` when triggered from physics or collision callbacks such as `body_entered`. Use `_pending_despawn` to ignore duplicate hits until despawn runs.
- On spawn, deferred monitoring enable plus overlap scan and motion sweep so close enemies are hit even when the projectile starts near or inside their hull. Only the source body is excluded from hits — no global hit grace period.

## Public API

```gdscript
class_name ProjectileData
extends Resource

@export var speed: float
@export var lifetime: float
@export var pierce_count: int = 0
@export var collision_mask: int
@export var radius: float  # collision hitbox radius
@export var sprite_frames: SpriteFrames  # optional AnimatedSprite2D frames
@export var animation_name: StringName = &"spin"
@export var visual_size_multiplier: float = 2.0
@export var sprite_content_size: float = 520.0
```

```gdscript
class_name ProjectileManager  # autoload

func spawn(data: ProjectileData, position: Vector2, direction: Vector2, payload: DamageEvent) -> Projectile
func despawn(projectile: Projectile) -> void
```

## Dependencies

- Combat (delivers DamageEvents to hit targets)
- VFX (impact effects)
- Weapons (spawns projectiles)

## Open Questions

- Homing / seeking behaviors — Resource flag or subclass?
- Piercing vs bouncing rules interaction.
- Pool size defaults.

## References

- [../ARCHITECTURE.md](../ARCHITECTURE.md#projectile-system)
