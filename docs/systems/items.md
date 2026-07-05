# Items System

Status: Not Started

## Goal

Define items as pure data. Items are the schema layer for anything that can exist in an Inventory.

## Components

- `ItemData` Resource (base)
- Item categories (subclasses or category enum)
- Item metadata (icon, description, rarity, stack size)

## Current Status

- [ ] Base `ItemData` Resource
- [ ] Category taxonomy defined
- [ ] Stackability rules
- [ ] First items authored as `.tres`

## Design Rules

- Items contain DATA, not gameplay logic.
- Weapons and consumables reference `ItemData` and add their behavior in their own systems.
- Every item has a stable string ID for save compatibility.
- Icons and localized strings live in the Resource, not in code.

## Public API

```gdscript
class_name ItemData
extends Resource

@export var id: StringName          # stable, save-safe ID
@export var display_name: String
@export var description: String
@export var icon: Texture2D
@export var category: StringName    # "weapon", "consumable", "material", ...
@export var stack_size: int = 1
@export var rarity: int = 0
```

## Dependencies

- None outbound. Consumed by Inventory, Equipment, Loot, Crafting.

## Open Questions

- Are quest items a category or a flag?
- Rarity: enum (Common/Uncommon/...) or numeric tier?
- Stat modifiers on items — do they live here or in a separate ItemStats Resource?

## References

- [../ARCHITECTURE.md](../ARCHITECTURE.md#item-system)
- [../CONTENT.md](../CONTENT.md)
