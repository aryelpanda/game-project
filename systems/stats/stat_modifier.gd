## Single stat modifier applied by Buffs, Talents, or equipment.
class_name StatModifier
extends Resource

const TYPE_FLAT := &"flat"
const TYPE_PERCENT_ADD := &"percent_add"

const LIFETIME_PERMANENT := &"permanent"
const LIFETIME_RUN_ONLY := &"run_only"
const LIFETIME_TIMED := &"timed"

@export var stat: StringName
@export var type: StringName = TYPE_FLAT
@export var value: float = 0.0
@export var lifetime: StringName = LIFETIME_RUN_ONLY
@export var display_name: String = ""
