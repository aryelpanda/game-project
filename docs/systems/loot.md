# Loot System

Status: Not Started

## Goal

Decide what an event produces (item drops, currency) using loot tables. Owned by data, not code.

## Components

- `LootTable` Resource
- Drop entry with weight / chance / count range
- Currency drops
- Loot rolling and spawning
- Integration hooks for enemies and chests

## Current Status

- [ ] `LootTable` Resource
- [ ] `LootEntry` sub-Resource
- [ ] Roll function
- [ ] Currency handling
- [ ] Drop spawn (world pickup)

## Design Rules

- Loot tables are Resources. No hardcoded drop chances in code.
- Rolls use a seedable RNG so runs can be reproducible for testing.
- A single event can roll multiple entries (multi-drop tables).
- Currency is a first-class drop, not a special-cased item.

## Public API

```gdscript
class_name LootTable
extends Resource

@export var entries: Array[LootEntry]
@export var rolls: int = 1
@export var guaranteed_currency_min: int = 0
@export var guaranteed_currency_max: int = 0

func roll(rng: RandomNumberGenerator) -> Array[ItemStack]
```

```gdscript
class_name LootEntry
extends Resource

@export var item: ItemData
@export var weight: float
@export var count_min: int = 1
@export var count_max: int = 1
```

## Dependencies

- Items (references ItemData)
- World (drops spawn as world pickups)
- Save (drop state persists if left on ground)

## Open Questions

- Do drops despawn over time?
- Magnet / auto-collect radius?
- Rarity coloring / rules?

## References

- [../ARCHITECTURE.md](../ARCHITECTURE.md#loot-system)
