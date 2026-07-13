## Passive modifier definition. Applied at runtime via BuffContainer.
class_name BuffData
extends Resource

const LIFETIME_RUN_ONLY := &"run_only"
const LIFETIME_TIMED := &"timed"
const LIFETIME_PERMANENT := &"permanent"

@export var id: StringName
@export var display_name: String = ""
@export var description: String = ""
@export var level_up_effect_text: String = "" ## Green effect line on level-up screen (e.g. "+25% attack").
@export var lifetime: StringName = LIFETIME_RUN_ONLY
@export var duration: float = 0.0
@export var modifiers: Array[StatModifier] = []
