# Project Orientation

This is a long-term commercial Godot 4.x / GDScript game targeting Steam. Development is deliberately paced, production-quality, and documentation-driven.

## Read These First (in order)

1. [docs/VISION.md](docs/VISION.md) - what the game is and is not
2. [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) - system layout and responsibilities
3. [docs/SYSTEM_MAP.md](docs/SYSTEM_MAP.md) - index of every system and where its docs and code live
4. [docs/TECH_STACK.md](docs/TECH_STACK.md) - approved tools, formats, and technical constraints
5. [docs/ROADMAP.md](docs/ROADMAP.md) - what gets built next, in what order
6. [docs/PROGRESS.md](docs/PROGRESS.md) - current status of every system

## Enforcement

Behavioral rules for the AI live in [.cursor/rules/](.cursor/rules/) and auto-attach based on the file being edited. The human-readable specification is [docs/AI_RULES.md](docs/AI_RULES.md).

## Before Touching Code

- Locate the system in [docs/SYSTEM_MAP.md](docs/SYSTEM_MAP.md).
- Read the matching `docs/systems/<name>.md`.
- Follow the workflow in [.cursor/rules/10-workflow.mdc](.cursor/rules/10-workflow.mdc).

## Core Principles

- Maintainability > readability > performance > extensibility > stability.
- No autonomous redesign. Ask before guessing.
- Use the approved stack in [docs/TECH_STACK.md](docs/TECH_STACK.md). Do not add new tools, plugins, or services without approval.
- Data lives in Resources (`.tres`), not code. See [docs/CONTENT.md](docs/CONTENT.md).
- Docs stay in sync with code. See [.cursor/rules/80-docs-sync.mdc](.cursor/rules/80-docs-sync.mdc).
