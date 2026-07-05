# Equipment System

Status: Not Started

## Goal

Manage which items are currently equipped and translate them into stat modifiers on the wearer.

## Components

- Equipment slots (head, chest, main-hand, off-hand, etc. — TBD)
- Equip / unequip validation
- Stat modifier push to Stats System
- Set bonuses (optional)

## Current Status

- [ ] Slot definition
- [ ] Equip / unequip flow
- [ ] Validation (right item type for slot)
- [ ] Modifier application via Stats
- [ ] Save integration

## Design Rules

- Equipment communicates with the Stats System — it does NOT store computed stats.
- Equipping an item registers its modifiers with Stats; unequipping removes them.
- Slots are typed. Attempting to equip an item to an incompatible slot is a no-op returning `false`, never an error.
- Two-handed / dual-slot rules are explicit in slot definitions.

## Public API

```gdscript
class_name Equipment

signal equipped(slot: StringName, item: ItemData)
signal unequipped(slot: StringName, item: ItemData)

func equip(item: ItemData, slot: StringName = &"") -> bool
func unequip(slot: StringName) -> ItemData
func get_equipped(slot: StringName) -> ItemData
```

## Dependencies

- Items (schema)
- Stats (pushes modifiers)
- Inventory (source of items)
- Save

## Open Questions

- Slot layout — how many, which names?
- Set bonuses at MVP or post-launch?
- Cosmetic vs functional slots?

## References

- [../ARCHITECTURE.md](../ARCHITECTURE.md#equipment-system)
