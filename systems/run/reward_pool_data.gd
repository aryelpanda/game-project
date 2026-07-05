## Defines which Spells and Buffs can appear as level-up reward choices.
class_name RewardPoolData
extends Resource

@export var id: StringName
@export var display_name: String = ""
@export var spells: Array[SpellData] = []
@export var buffs: Array[BuffData] = []
