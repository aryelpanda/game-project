## Projectile motion, collision, and optional animated visual.
class_name ProjectileData
extends Resource

## Approximate content diameter of authoring textures (used to scale sprite to radius).
const DEFAULT_SPRITE_CONTENT_SIZE := 520.0

@export var speed: float = 400.0
@export var lifetime: float = 3.0
@export var pierce_count: int = 0
@export var collision_mask: int = 2
@export var radius: float = 8.0
@export var sprite_frames: SpriteFrames
@export var animation_name: StringName = &"spin"
## How large the sprite appears relative to hitbox diameter (1.0 = sprite diameter matches 2*radius).
@export var visual_size_multiplier: float = 2.0
@export var sprite_content_size: float = DEFAULT_SPRITE_CONTENT_SIZE
