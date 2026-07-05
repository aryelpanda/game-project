# Player–Enemy Collision Implementation Prompt

Version: 0.2

> Paste into a fresh AI session to implement solid player–enemy contact (touch, no overlap). Locked decisions below — do not re-open without approval.
>
> **Superseded (player blocking):** player-priority push and map bounds are defined in [map_bounds_and_player_push.md](map_bounds_and_player_push.md). Player `collision_mask = 0` there replaces `collision_mask = 2` below.

---

## Persona

Senior Godot 4.7 / GDScript gameplay programmer. Implement only what is specified.

## Read first

1. [AGENTS.md](../../AGENTS.md)
2. [docs/systems/enemies.md](../systems/enemies.md)
3. [docs/systems/player.md](../systems/player.md)
4. [docs/systems/combat.md](../systems/combat.md)
5. `systems/player/Player.tscn`, `systems/enemies/Enemy.tscn`, `systems/enemies/enemy.gd`

---

## Goal

Enemies chase the player but **stop at contact** — no sprite overlap. Player cannot walk through enemies. **Enemies may still overlap each other** (survivor-like horde stacking).

---

## Locked decisions

- Physics layers: 1 = player, 2 = enemy (existing in `project.godot`).
- Enemy `collision_mask = 1` (blocks player only).
- Player `collision_mask = 2` (blocks enemies only).
- No enemy–enemy collision.
- Do not change projectile collision or reparent pooled nodes.
- Melee touch range comes from `EntityCollision` helper (collision shape extents), not hardcoded floats in `.gd`.

---

## Deliverables

| File | Change |
| ---- | ------ |
| `systems/combat/entity_collision.gd` | `class_name EntityCollision` — layer bits, `touch_distance(a, b)`, `is_within_touch(a, b)` |
| `systems/player/Player.tscn` | `collision_mask = 2` |
| `systems/enemies/Enemy.tscn` | `collision_mask = 1` |
| `systems/enemies/enemy.gd` | Melee check via `EntityCollision.is_within_touch(self, player)` |

**Docs:** update design rules in `enemies.md`, `player.md`, `combat.md`.

---

## Definition of Done

- [ ] Enemies stop at player edge; no overlap.
- [ ] Player cannot pass through enemies.
- [ ] Enemies can stack on each other.
- [ ] `melee_touch` still fires at contact.
- [ ] No new console errors during horde + fireball play.

---

## Anti-scope

Enemy–enemy separation, knockback, new autoloads, VFX, projectile changes.
