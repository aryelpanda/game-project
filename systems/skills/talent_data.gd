## Data definition for a single Talent node in a Talent Tree.
## Effects are data-driven: permanent StatModifiers applied per rank and/or a
## permanent Spell unlock. Names and values are placeholders for M7 testing.
class_name TalentData
extends Resource

@export var id: StringName
@export var tree_id: StringName
@export var display_name: String = ""
@export var description: String = ""
@export var icon: Texture2D
@export var max_rank: int = 1
@export var cost_per_rank: int = 1

## Grid placement for the WotLK-style tree layout (0-based row / column).
@export var tier: int = 0
@export var column: int = 0

## Optional prerequisite Talent id. Used only to draw connector arrows in the
## MVP (free-spend has no gating). Empty means no prerequisite.
@export var requires: StringName = &""

## Permanent stat modifiers applied once per spent rank. Lifetime should be
## StatModifier.LIFETIME_PERMANENT.
@export var effect_modifiers: Array[StatModifier] = []

## Optional Spell permanently unlocked when this Talent has at least one rank.
@export var unlock_spell: SpellData
