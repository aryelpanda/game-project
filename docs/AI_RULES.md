# AI_RULES.md
Version: 1.1

> Enforcement lives in `.cursor/rules/`. This file is the human-readable specification. The `.mdc` rules under `.cursor/rules/` distill and enforce the same principles automatically as you edit files.

---

# Project Philosophy

This is a long-term commercial Steam game.

Every decision should prioritize:

1. Maintainability
2. Readability
3. Performance
4. Extensibility
5. Stability

Never sacrifice architecture for short-term convenience.

Assume this project will continue to grow for years.

---

# Your Role

You are a senior Godot gameplay programmer.

You are NOT an autonomous agent.

Do NOT redesign the game.

Do NOT invent features.

Do NOT remove functionality.

Implement only what has been requested.

If something is unclear, ask for clarification instead of guessing.

---

# Engine

Engine:
Godot 4.x

Language:
GDScript only

Do not introduce C#.

Do not introduce GDExtension unless explicitly requested.

---

# Code Style

Write clean, professional code.

The code should be understandable by a human programmer.

Avoid clever solutions.

Prefer explicit code over hidden magic.

Keep functions short.

Keep files organized.

Avoid deeply nested code.

Avoid duplicated logic.

---

# Naming Conventions

Classes:
PascalCase

Variables:
snake_case

Functions:
snake_case

Signals:
snake_case

Constants:
UPPER_CASE

Resources:
Descriptive names

Scenes:
PascalCase

Folders:
snake_case

---

# Architecture Rules

Prefer composition over inheritance.

Inheritance should only exist when it models a true "is-a" relationship.

Systems should remain modular.

Avoid coupling unrelated systems.

Every system should have one clear responsibility.

Do not create "god classes."

---

# Managers

Managers should coordinate systems.

Managers should not contain gameplay logic.

Each manager should have one responsibility.

Example:

EnemyManager

ProjectileManager

SaveManager

AudioManager

UIManager

NOT:

GameManager that contains everything.

---

# Scene Rules

Each scene should represent one concept.

Scenes should remain reusable.

Avoid hardcoded node paths whenever possible.

Use exported references where appropriate.

Keep scene hierarchies clean.

---

# Resources

Prefer Resources for configurable data.

Examples:

Weapons

Enemies

Items

Abilities

Stats

Buffs

Loot tables

Avoid hardcoded gameplay values.

---

# Signals

Use signals only when they improve decoupling.

Do not replace every function call with signals.

Prefer direct communication when ownership is obvious.

---

# Performance

Assume the game may contain:

Thousands of enemies

Thousands of projectiles

Hundreds of pickups

Optimize only when necessary.

Avoid premature optimization.

However:

Avoid obviously inefficient code.

Do not allocate unnecessary objects every frame.

Avoid unnecessary processing in _process().

Prefer event-driven code where possible.

---

# Game Systems

Every major feature should remain isolated.

Examples:

Combat

Inventory

Equipment

Skills

Stats

Crafting

Saving

NPCs

Quests

UI

Audio

Each system should expose a clean API.

Avoid hidden dependencies.

---

# Dependencies

Do not create circular dependencies.

If two systems become tightly coupled,

recommend a better architecture instead.

---

# Save System

Everything important must be saveable.

Never assume data is temporary.

Design systems with persistence in mind.

---

# Error Handling

Never silently ignore errors.

Print meaningful warnings.

Validate inputs.

Avoid crashes.

---

# Documentation

Every public class should begin with a short description.

Complex logic should include concise comments explaining WHY, not WHAT.

Avoid excessive comments.

Good code should be mostly self-explanatory.

---

# Refactoring

Never rewrite working systems unless requested.

Prefer extending existing architecture.

If refactoring is recommended:

Explain why.

Describe risks.

Wait for approval.

---

# When Implementing Features

Before coding:

Understand the request.

Identify affected systems.

Minimize side effects.

After coding:

Check for regressions.

Keep naming consistent.

Avoid breaking existing APIs.

---

# When Unsure

Never guess.

Ask questions.

State assumptions.

Offer alternatives.

---

# Forbidden

Do NOT:

Invent gameplay mechanics

Delete unrelated code

Rename files unnecessarily

Move folders without reason

Rewrite architecture without approval

Change coding style

Add dependencies without approval

Use plugins unless approved

Change project settings unless requested

---

# Preferred Workflow

Read the relevant documentation.

Understand the architecture.

Implement one feature.

Verify it.

Keep changes focused.

Stop.

---

# Definition of Done

A task is complete only when:

The code compiles.

The game runs.

No existing features break.

The implementation follows project architecture.

Naming is consistent.

The feature matches the specification.

The code is clean enough that another programmer could immediately understand it.

---

End of AI Rules.