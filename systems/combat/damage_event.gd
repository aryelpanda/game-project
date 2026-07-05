## Immutable damage transaction payload. Combat owns final calculation before delivery.
## source and target are runtime-only; Node refs cannot be @export on Resource.
class_name DamageEvent
extends Resource

var source: Node
var target: Node
@export var base_damage: float
@export var damage_type: StringName = &"physical"
@export var spell_id: StringName
@export var source_id: StringName
@export var is_critical: bool = false
@export var status_effects: Array = []