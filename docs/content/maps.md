# Maps Gameplay Index

Version: 0.2

> Index of gameplay designs for maps. Use [map_design_template.md](map_design_template.md) before creating any `MapData` Resource.

## Rules

- This file tracks map gameplay intent, not visual art.
- Do not create one Markdown file per map unless the map becomes complex enough to need it.
- Actual runtime data belongs in `content/maps/*.tres` and `content/spawn_curves/*.tres`.
- Every map uses stable IDs for enemies, rewards, unlocks, and resources.
- If a map changes required data fields, update [../systems/world.md](../systems/world.md) and [../CONTENT.md](../CONTENT.md).

## Map List

| Map ID | Display Name | Tier | Status | Resource | Notes |
| ------ | ------------ | ---- | ------ | -------- | ----- |
| test_arena | Test Arena | tutorial | Implemented | `content/maps/test_arena.tres` | Single `test_grunt` horde, ramping spawn curve, death ends run. M3 dev map. |

## Map Status Legend

| Status | Meaning |
| ------ | ------- |
| Not Designed | No approved gameplay design yet. |
| Designed | Markdown design exists, no Resource yet. |
| Implemented | `MapData` and spawn curve Resources exist. |
| Tested | Played in-game and basic issues fixed. |
| Balanced | Difficulty and rewards are close to target. |
| Locked | Do not change without approval. |

## Adding a Map

1. Add a row to **Map List**.
2. Fill a gameplay design using [map_design_template.md](map_design_template.md).
3. Create or update the matching `MapData` Resource.
4. Create or update the matching spawn curve Resource.
5. Test the map and add balancing notes.

## Changelog

- v0.2 - added `test_arena` M3 dev map entry.
- v0.1 - initial map gameplay index
