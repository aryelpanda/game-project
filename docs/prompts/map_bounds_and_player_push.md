# Map Bounds + Player-Push Collision Prompt

Version: 0.1

> Paste into a fresh AI session to clamp the player inside the map and give the player collision priority over enemies. Supersedes the player-blocking rule in [entity_player_collision.md](entity_player_collision.md).

---

## Persona

Senior Godot 4.7 / GDScript gameplay programmer. Implement only what is specified.

## Read first

1. [AGENTS.md](../../AGENTS.md)
2. [docs/systems/world.md](../systems/world.md)
3. [docs/systems/player.md](../systems/player.md)
4. [docs/systems/enemies.md](../systems/enemies.md)
5. [docs/systems/combat.md](../systems/combat.md)
6. `systems/combat/entity_collision.gd`, `systems/world/map_data.gd`, `systems/player/player.gd`, `Player.tscn`, `Arena.tscn`

---

## Goal

- Player **cannot leave** the map play area.
- When the player walks into enemies, **enemies are pushed aside** — player keeps moving, never stuck.
- Enemies still **cannot overlap** the player (no sprite overlap). Enemy chase + `melee_touch` unchanged.

---

## Locked decisions

- Play bounds from `MapData.play_area_rect` — not hardcoded in player script.
- Player `collision_mask = 0` (not blocked by enemies).
- Enemy `collision_mask = 1` unchanged (enemies stop at player when chasing).
- Push = position separation only after player move — no knockback, no enemy-enemy push.
- Do not reparent pooled nodes; do not change projectile collision.

---

## Deliverables

| File | Change |
| ---- | ------ |
| `systems/world/map_data.gd` | Add `@export var play_area_rect: Rect2` |
| `content/maps/test_arena.tres` | `Rect2(-1000, -1000, 2000, 2000)` matching arena background |
| `systems/combat/entity_collision.gd` | `clamp_body_to_play_area`, `push_overlapping_enemies` |
| `systems/player/player.gd` | After `move_and_slide`: clamp to map rect, push overlapping enemies |
| `systems/player/Player.tscn` | `collision_mask = 0` |

**Docs:** update design rules in `world.md`, `player.md`, `enemies.md`, `combat.md`.

---

## Definition of Done

- [ ] Player cannot walk past arena edges.
- [ ] Player walks into horde; enemies slide aside; player never stuck.
- [ ] Enemies still stop at player when chasing; no overlap on player sprite.
- [ ] `melee_touch` still fires at contact.
- [ ] No new console errors.

---

## Anti-scope

StaticBody2D wall scenes, enemy map clamping, knockback/VFX, new autoloads, new physics layers.
