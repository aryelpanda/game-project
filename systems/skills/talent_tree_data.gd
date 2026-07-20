## Data definition for one Talent Tree (a magic school) holding its Talents.
class_name TalentTreeData
extends Resource

@export var id: StringName
@export var display_name: String = ""
@export var theme_color: Color = Color(0.6, 0.6, 0.65)
@export var icon: Texture2D
@export var talents: Array[TalentData] = []
