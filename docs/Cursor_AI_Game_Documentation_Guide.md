# Organizing Game Documentation for Cursor AI

## Organize by System, Not by Individual Features

Do **not** create one Markdown file per spell or item. That quickly
becomes unmanageable.

Instead, organize documentation by **major systems**, and only split
files when a system grows too large.

## Level 1: One File per Major System

``` text
docs/
└── systems/
    ├── combat.md
    ├── inventory.md
    ├── enemies.md
    ├── player.md
    ├── world.md
    └── ui.md
```

`combat.md` should describe the combat architecture, not every spell.

Example:

``` md
# Combat System

## Goal
Action-based combat with abilities.

## Components
- Damage System
- Status Effects
- Abilities
- Mana
- Cooldowns
- Projectiles

## Current Status
✅ Basic attacks
❌ Magic
❌ Status effects

## Design Rules
- Every ability derives from Ability.
- Damage goes through DamageManager.
- No spell directly changes HP.
```

## Level 2: Split When a Section Becomes Large

``` text
systems/
    combat/
        overview.md
        damage.md
        status_effects.md
        abilities.md
```

`abilities.md` should describe the framework:

``` md
# Ability System

Each ability has:
- Name
- Mana cost
- Cooldown
- Animation
- Cast time
- Range
- Damage
- Effects

All abilities inherit from AbilityBase.
```

## Level 3: Keep Collections Together

If your game has 150 spells, don't create 150 Markdown files.

Instead:

``` text
combat/
    overview.md
    abilities.md
    spell_list.md
```

Example:

``` md
# Offensive Spells

## Fireball
Damage: 30
Mana: 15
Cooldown: 3s
Projectile
Explosion Radius: 2m

---

## Ice Spike
Damage: 18
Slows enemy by 40%
Cooldown: 2s

---

## Chain Lightning
Hits up to 5 enemies
Damage decreases each jump
```

## Level 4: Split Only When Necessary

Only create separate files when a category becomes very complex.

``` text
combat/
    bosses/
        dragon_boss.md
        lich_boss.md

    abilities/
        summoning.md
        elemental.md
        necromancy.md
```

Example: - Elemental.md contains 60 spells. - Necromancy.md contains 40
spells.

This is a good reason to split.

## Think Like a Programmer

If your code looks like:

``` text
Ability
    Fireball
    IceSpike
    Meteor
```

Then your documentation should usually be:

``` text
abilities.md
```

Not:

``` text
fireball.md
icespike.md
meteor.md
```

Unless each spell has pages of unique mechanics.

## Recommended Folder Structure

``` text
docs/
│
├── vision.md
├── roadmap.md
├── architecture.md
├── progress.md
│
└── systems/
    ├── combat/
    │   ├── overview.md
    │   ├── abilities.md
    │   ├── damage.md
    │   ├── status_effects.md
    │   ├── ai.md
    │   └── balancing.md
    │
    ├── inventory/
    │   ├── overview.md
    │   ├── items.md
    │   └── equipment.md
    │
    ├── world/
    ├── ui/
    ├── quests/
    └── crafting/
```

## Final Recommendation

Keep Markdown focused on **architecture, rules, and design decisions**.

Store large collections of content---such as spells, items, enemies, and
quests---in structured formats like JSON, YAML, or engine-specific
resource files.

Cursor AI is much better at generating and maintaining structured data
than editing hundreds of tiny Markdown documents.

As a rule of thumb:

-   **Markdown** = design, architecture, implementation rules.
-   **JSON/YAML/Resources** = game content.
-   **Code** = implementation.

This approach scales well from a small prototype to a large RPG.
