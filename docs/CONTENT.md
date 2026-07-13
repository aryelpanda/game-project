# CONTENT.md

Version: 0.6

> How gameplay content is stored, where it lives, and when to use each format. Enforcement rule: [.cursor/rules/50-resources.mdc](../.cursor/rules/50-resources.mdc).

## Philosophy

- **Markdown** = design, architecture, and rules.
- **Resources (`.tres`) / JSON / YAML** = game content.
- **Code (`.gd`)** = behavior only.

Content should never be hardcoded in scripts. If a value shapes gameplay (damage, speed, cost, drop chance), it lives in a Resource.

## Format Choice

| Content Kind                             | Format             | Why                                                                            |
| ---------------------------------------- | ------------------ | ------------------------------------------------------------------------------ |
| Single, editor-authored gameplay entity  | `.tres` (Resource) | Editor UI, typed fields, references other Resources, previewable.              |
| Small structured lists (10-100 entries)  | `.tres` per entry  | Diff-friendly, easy to find, version-controllable.                             |
| Large tabular content (500+ rows)        | JSON or CSV        | Bulk editing outside Godot, easier for spreadsheets.                           |
| Localization strings                     | Godot CSV / PO     | Godot native i18n workflow.                                                    |
| Static level layout                      | `.tscn` scenes     | Editor-authored, engine-native.                                                |

## Folder Layout

Content lives under a top-level `content/` folder, sibling to `systems/`.

```text
content/
├── maps/               # MapData Resources: arena, enemy pool, spawn curve refs
├── spawn_curves/       # SpawnCurveData Resources: horde pacing over time
├── enemies/            # EnemyData Resources
├── enemy_skills/       # SpellData Resources used by enemies (separate pool from player spells)
├── spells/             # SpellData / AbilityData Resources (player pool)
├── buffs/              # BuffData Resources
├── reward_pools/       # Level-up 3-choice reward pools
├── run/                # RunProgressionData: XP curve + reward pool reference
├── talents/            # TalentTreeData / TalentData Resources
├── stats/              # Base stat presets
├── projectiles/        # ProjectileData Resources
├── weapons/            # WeaponData Resources, if weapons are used later
├── items/              # ItemData Resources, de-prioritized for early MVP
├── loot/               # LootTable Resources, optional for non-XP drops
└── data/               # Bulk JSON / CSV where a Resource-per-row is overkill
```

Gameplay design notes live under `docs/content/`.

## Art vs Content

- **`content/`** — gameplay Resources (damage, cooldowns, spawn curves, ids). Typed `.tres` data.
- **`assets/`** — runtime art/audio Godot loads (PNG frames, `SpriteFrames`, fonts, music). See [`assets/README.md`](../assets/README.md).
- **`art_source/`** — editable source files only; never referenced by game code.

A spell `.tres` in `content/spells/` may point at `res://assets/spells/<family>/…` for visuals. Do not put PNGs inside `content/`.

```text
docs/content/
├── map_design_template.md   # Template for AI-assisted map gameplay design
└── maps.md                  # Index of map gameplay designs
```

## Resource Definition Pattern

Resource scripts define the data shape. They live in the owning system's folder.

```gdscript
class_name SpellData
extends Resource

@export var display_name: String
@export var damage: float = 10.0
@export var cooldown: float = 0.5
@export var mana_cost: float = 0.0
@export var is_talent_granted: bool = false
@export var projectile_data: ProjectileData
@export var icon: Texture2D
```

Content authored in the editor as `.tres`:

```text
content/spells/fire_orb.tres
```

Consumed by code:

```gdscript
@export var spell_data: SpellData

func attack() -> void:
    if not spell_data:
        push_warning("Spell has no data")
        return
    Combat.apply_damage(spell_data.damage)
```

## Naming Conventions

- File names: `snake_case.tres` (e.g. `iron_sword.tres`).
- Resource script names: `PascalCase` matching `class_name` (e.g. `WeaponData`).
- Do NOT put the type in the file name unless disambiguation is needed (`iron_sword.tres`, not `iron_sword_weapon_data.tres`).
- One entity per file. No "kitchen sink" Resources.

## Survivor-Specific Content

| Content              | Location                         | Notes |
| -------------------- | -------------------------------- | ----- |
| Maps / arenas        | `content/maps/*.tres`            | Defines arena scene, enemy pool, spawn curve, environment rules. |
| Spawn curves         | `content/spawn_curves/*.tres`    | Controls horde intensity over run time. |
| Enemies              | `content/enemies/*.tres`         | Enemy stats, behavior type, XP value, references to enemy skills. |
| Enemy skills         | `content/enemy_skills/*.tres`    | `SpellData` used by enemies. Separate pool from player spells; never appears in the level-up reward pool. |
| Temporary Spells     | `content/spells/*.tres`          | Can appear in level-up choices. No mana cost unless talent-granted. |
| Temporary Buffs      | `content/buffs/*.tres`           | Can appear in level-up choices and are lost at run end. |
| Reward pools         | `content/reward_pools/*.tres`    | Defines which Spells / Buffs can appear as 3 random choices. |
| Talent trees         | `content/talents/*.tres`         | Permanent meta-progression, split into 3 trees. |
| Stats presets        | `content/stats/*.tres`           | Player, enemy, and scaling presets. |
| Run progression      | `content/run/*.tres`             | XP thresholds and reward pool reference for a run. |

## Level-Up Reward Workflow

Temporary Spells and Buffs for level-up choices are indexed in [content/rewards.md](content/rewards.md).

Quick steps:

1. Author `content/spells/<name>.tres` or `content/buffs/<name>.tres` with a unique `id`.
2. Add the Resource to a `content/reward_pools/*.tres` pool.
3. Ensure the active `RunProgressionData` (e.g. `content/run/m4_default_progression.tres`) references that pool.
4. Playtest via in-run level-up or the debug **Grant All Test Rewards** button (M4).

Do not hardcode reward lists in scripts. `RunManager` loads options from Resources only.

## Map Gameplay Design Workflow

Maps are designed in Markdown first, then converted into Resources.

Use:

- [content/map_design_template.md](content/map_design_template.md) for the reusable design template.
- [content/maps.md](content/maps.md) as the index of designed maps.
- `content/maps/*.tres` for final `MapData` Resources.
- `content/spawn_curves/*.tres` for runtime spawn pacing.

Markdown answers **why the map plays differently**.

Resources store **the actual values the game loads**.

Do not hardcode map-specific gameplay in scripts.

## When to Split Into a Bulk Format

If a category grows past ~100 entries and editor authoring becomes painful, migrate to JSON or CSV. Rules:

1. Migration is a milestone-scale decision. Ask before doing it.
2. Loader lives in the owning system (e.g. `systems/items/item_loader.gd`).
3. Runtime shape stays the same — the loader converts JSON rows into typed Resources at load, so consumers do not care about the source format.

## What Does NOT Live In Content

- Behavior / logic (goes in `.gd` under `systems/`).
- Level geometry (goes in `.tscn` under `scenes/` or `world/`).
- Localized user-facing strings (Godot's translation system).
- Save game state (owned by the Save system).

## Save Interaction

- Static Resource data is NOT saved (base Spell, Buff, Enemy, Map, and Talent definitions live in `content/`).
- Instance state IS saved only when it is meant to persist.
- Temporary run rewards are cleared when the run ends and are not saved as permanent progress.
- Permanent Talent choices, unlocked maps, unlocked characters, and meta-currency are saved.
- Save data references content by stable string ID, never by file path.

## Version Control

- `.tres` files are text-based - review them in diffs.
- Do not commit binary imports (`.import/` is gitignored).
- Prefer many small Resource files over one big one to reduce merge conflicts.

## Changelog

- v0.6 - clarified `content/` vs `assets/` vs `art_source/`; art layout documented in `assets/README.md`.
- v0.5 - added `content/run/` folder, level-up reward workflow, and link to `docs/content/rewards.md`.
- v0.4 - added enemy_skills content folder and table row for enemy-only SpellData pool.
- v0.3 - added map gameplay design workflow and docs/content map template references.
- v0.2 - added survivor-specific content folders for maps, spawn curves, spells, reward pools, and talents.
- v0.1 - initial policy
