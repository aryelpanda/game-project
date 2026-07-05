# Inventory System

Status: Not Started

## Goal

Store, organize, and move items owned by an entity (usually the player). Inventory holds items — it does not compute stats.

## Components

- Inventory container
- Slots
- Stack management
- Item movement (drag / drop, swap)
- Sorting and filtering

## Current Status

- [ ] Inventory Resource / class
- [ ] Slot model
- [ ] Add / remove / move / swap operations
- [ ] Stack merging and splitting
- [ ] Signals for UI to subscribe to
- [ ] Save integration

## Design Rules

- Inventory does NOT calculate player stats. Equipment does that by reading equipped items and pushing modifiers to Stats.
- Inventory operations are transactional — they either fully succeed or leave state unchanged.
- No UI logic in Inventory. UI observes via signals.
- Inventory is fully saveable and identifies items by their stable string ID.

## Public API

```gdscript
class_name Inventory

signal item_added(slot: int, stack: ItemStack)
signal item_removed(slot: int, stack: ItemStack)
signal inventory_changed()

func add(item: ItemData, count: int = 1) -> int  # returns count actually added
func remove(slot: int, count: int = 1) -> ItemStack
func move(from_slot: int, to_slot: int) -> bool
func sort() -> void
```

## Dependencies

- Items (schema)
- Save (persistence)
- UI (reads and displays)

## Open Questions

- Fixed grid vs weight-based capacity?
- Tabs / categories, or one bag?
- Auto-loot to inventory or manual pickup?

## References

- [../ARCHITECTURE.md](../ARCHITECTURE.md#inventory-system)
