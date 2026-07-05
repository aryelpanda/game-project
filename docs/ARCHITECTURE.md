# ARCHITECTURE.md

Version: 1.4

---

# Purpose

This document defines the overall architecture of the game.

It describes how systems are organized, how they communicate, and the responsibilities of each major subsystem.

This is the source of truth for the project's technical architecture.

---

# Architectural Principles

The project follows these principles:

- Modular systems
- Low coupling
- High cohesion
- Data-driven design
- Composition over inheritance
- Single Responsibility Principle
- Clean separation between gameplay, UI, and data
- Reusable components
- Maintainable codebase

---

# High-Level Architecture

The game is divided into independent systems.

```
Game

├── Core
├── Run
├── Player
├── Enemies
├── Combat
├── Weapons
├── Projectiles
├── Items
├── Inventory
├── Equipment
├── Skills
├── Stats
├── Buffs
├── Loot
├── World
├── Save System
├── UI
├── Audio
├── Visual Effects
└── Debug
```

Each system owns its own logic.

Systems should communicate through well-defined APIs.

---

# Core System

Responsibilities:

- Game initialization
- Game state
- Scene transitions
- Global configuration
- Time management

The Core System should not contain gameplay logic.

---

# Run System

Responsibilities:

- Run lifecycle (start, active, ended)
- Run checkpoint export / restore
- Run timer
- Kill count
- Run stats tracking
- Run History entry generation
- In-run XP and level-up flow coordination
- Generating 3 random reward choices
- Applying temporary run rewards
- Run end summary and post-run reward calculation

The Run System coordinates a session. New runs start only after UI flow: Save Slot Select -> Profile Main Screen -> Start Run -> Map Selection. Run does not own player movement, enemy behavior, UI rendering, or permanent save data. It exposes checkpoint data to the Save System so interrupted runs can be resumed or forfeited, and creates `RunHistoryEntry` records when runs end.

---

# Player System

Responsible for:

- Movement
- Input
- Health
- Mana
- Experience
- Level
- Character statistics
- Equipment interface
- Animation

The Player System should not manage enemies or UI.

---

# Enemy System

Responsible for:

- Enemy spawning
- Enemy behavior
- Enemy state
- Enemy death
- Enemy drops

Enemies should not directly modify player systems.

---

# Combat System

Responsible for:

- Damage calculation
- Hit detection
- Critical hits
- Status effects
- Damage events
- Damage result events for Run History

Combat should be independent from specific weapons. Combat emits damage and kill results so Run can track per-Spell history stats.

---

# Weapon System

Responsible for:

- Weapon behavior
- Cooldowns
- Attack execution
- Scaling
- Upgrades

Weapons should use the Combat System rather than calculating damage themselves.

---

# Projectile System

Responsible for:

- Projectile movement
- Lifetime
- Collision
- Pooling
- Impact events

Projectiles should remain generic.

---

# Item System

Responsible for:

- Item definitions
- Item categories
- Item metadata

Items should contain data, not gameplay logic.

---

# Inventory System

Responsible for:

- Inventory slots
- Item storage
- Stack management
- Item movement
- Sorting
- Filtering

Inventory should not calculate player stats.

---

# Equipment System

Responsible for:

- Equipped items
- Equipment slots
- Equipment validation
- Stat bonuses

Equipment communicates with the Stats System.

---

# Stats System

Responsible for:

- Base stats
- Derived stats
- Modifiers
- Multipliers

All gameplay systems read from the Stats System.

No gameplay system owns permanent stats.

---

# Skills System

Responsible for:

- Temporary run Spells
- Talent-granted Spells
- Talent Trees
- Talent upgrades
- Cooldowns

Skills should remain independent of specific weapons. Talent-granted Spells may use mana; temporary level-up Spells do not.

---

# Buff System

Responsible for:

- Temporary modifiers
- Permanent modifiers
- Status effects
- Duration tracking

---

# Loot System

Responsible for:

- Loot tables
- Drop chances
- Rewards
- Currency

---

# Save System

Responsible for:

- Save Slot Select data
- 5 fixed save slots minimum
- Autosave-only progression
- Saving and loading permanent profile data
- Run History storage
- Active run checkpointing
- Resume / forfeit interrupted run flow
- Serialization
- Version compatibility
- Atomic writes and backup files

Every gameplay system must expose saveable data. Permanent progression, Run History, and active run checkpoints are stored separately.

---

# UI System

Responsible for:

- Save Slot Select
- Resume / Forfeit interrupted run modal
- Profile Main Screen / out-of-run hub
- Map Selection
- HUD
- Run History
- Talent Tree screen
- Inventory screen
- Character Stats screen
- Settings screen
- Menus
- Inventory interface
- Tooltips
- Notifications

UI should never contain gameplay logic.

UI displays game state.

It does not own game state.

Primary navigation flow:

```text
Launch
↓
Save Slot Select
↓
Profile Main Screen
↓
Start Run
↓
Map Selection
↓
Run
```

---

# Audio System

Responsible for:

- Music
- Sound effects
- Volume settings
- Audio buses

---

# Visual Effects

Responsible for:

- Particles
- Screen shake
- Hit flashes
- Explosions

Effects should never modify gameplay.

---

# Debug System

Responsible for:

- Debug commands
- Developer tools
- Performance metrics
- Spawn testing

Debug tools must never ship in release builds.

---

# Communication Rules

Systems should communicate through clear interfaces.

Avoid direct dependencies whenever possible.

Avoid circular dependencies.

No system should directly manipulate another system's internal data.

---

# Data Flow

```
Input

↓

Player

↓

Combat

↓

Enemies

↓

Experience

↓

Run Level-Up

↓

Temporary Spells / Buffs

↓

Stats

↓

Combat

Run End

↓

Talent Trees
```

Data should flow in predictable directions.

---

# Data-Driven Design

Gameplay values should be stored as Resources whenever practical.

Examples:

- Weapons
- Enemies
- Items
- Spells
- Skills / Talent Trees
- Buffs
- Loot Tables
- Maps
- Spawn Curves

Avoid hardcoded gameplay values.

---

# Scene Philosophy

Scenes should represent reusable objects.

Examples:

- Player
- Enemy
- Projectile
- Chest
- NPC
- Weapon Pickup

Avoid overly large scenes.

---

# Managers

Managers coordinate systems.

Managers do not implement gameplay.

Each manager has one responsibility.

Examples:

- EnemyManager
- ProjectileManager
- AudioManager
- SaveManager

Avoid creating a GameManager that owns every system.

---

# Future Expansion

The architecture should support adding:

- New weapons
- New enemy types
- New maps
- New bosses
- New items
- New skills
- New spells
- New buffs
- New talent trees
- Multiplayer (optional)
- Mod support (optional)

without requiring major architectural changes.

---

# Architecture Goals

The project should remain:

- Easy to understand
- Easy to extend
- Easy to debug
- Easy to optimize
- Easy for AI assistants to work on

Every new feature should fit naturally into the existing architecture.

If a feature does not fit, the architecture should be reviewed before implementation.