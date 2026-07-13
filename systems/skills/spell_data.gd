## Shared active-ability data for player Spells and enemy skills.
class_name SpellData
extends Resource

const TYPE_MANUAL := &"manual"
const TYPE_AUTO_PROJECTILE := &"auto_projectile"
const TYPE_ORBIT_AURA := &"orbit_aura"

@export var id: StringName
@export var display_name: String = ""
@export var description: String = ""
@export var level_up_effect_text: String = "" ## Green effect line on level-up screen (e.g. "+1 star").
@export var spell_type: StringName = TYPE_MANUAL
@export var cooldown: float = 1.0
@export var mana_cost: float = 0.0
@export var is_talent_granted: bool = false
@export var base_damage: float = 0.0
@export var damage_type: StringName = &"physical"
@export var projectile_data: ProjectileData
@export var orbit_radius: float = 64.0
@export var orbit_speed: float = 2.5
@export var orbit_count: int = 1
@export var orbit_hit_cooldown: float = 0.5
