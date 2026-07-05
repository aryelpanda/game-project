# Map Gameplay Design Template

Version: 0.1

> Use this template before creating any `MapData` Resource. This document is for gameplay and balancing only, not visual art direction.

## How To Use

1. Copy this template into a new section in [maps.md](maps.md), or use it as the structure for a focused map design note if the map becomes complex.
2. Fill the design in Markdown first.
3. Convert approved values into Resources:
   - `content/maps/<map_id>.tres`
   - `content/spawn_curves/<map_id>_spawn_curve.tres`
   - reward pools / enemy pools as needed
4. Update [../systems/world.md](../systems/world.md) and [../CONTENT.md](../CONTENT.md) only if the map requires new data fields or rules.

## AI Prompt Block

Use this prompt with Cursor when creating a new map design:

```text
Create a new map gameplay design using docs/content/map_design_template.md.
Map goal: <short goal>
Difficulty tier: <tier>
Primary gameplay twist: <twist>
Reference map for balance: <existing map id or none>
Do not create art direction. Focus on gameplay, spawn pressure, rewards, and balancing.
```

---

## 1. Map Identity

- **Map ID:** `todo_map_id`
- **Display Name:** TODO
- **Difficulty Tier:** TODO (`tutorial`, `tier_1`, `tier_2`, `tier_3`, `endgame`)
- **Expected Run Duration:** TODO minutes
- **Unlock Requirement:** TODO
- **MapData Resource:** `content/maps/todo_map_id.tres`
- **SpawnCurve Resource:** `content/spawn_curves/todo_map_id_spawn_curve.tres`

## 2. Gameplay Fantasy

Short description of what this map should feel like mechanically.

Examples:

- Constant weak horde pressure.
- Slow enemies but dangerous elites.
- Fast enemies with low health.
- Tight arena where positioning matters.

**Draft:**

> TODO

## 3. Primary Gameplay Twist

What makes this map different from other maps?

- TODO

## 4. Run Rules

- **Win Condition:** TODO (`survive_timer`, `boss_kill`, `objective`, `endless`)
- **Lose Condition:** Player death
- **Timer Length:** TODO seconds
- **Recommended Player Power:** TODO
- **Starting Spawn Pressure:** TODO
- **Peak Spawn Pressure:** TODO

## 5. Enemy Pool

| Enemy ID | Role | Appears At | Weight | Notes |
| -------- | ---- | ---------- | ------ | ----- |
| TODO | Basic horde | 0:00 | TODO | TODO |
| TODO | Pressure enemy | TODO | TODO | TODO |
| TODO | Elite | TODO | TODO | TODO |

## 6. Spawn Curve Phases

| Phase | Time Range | Goal | Spawn Behavior |
| ----- | ---------- | ---- | -------------- |
| Opening | 0:00-TODO | Teach map rhythm | TODO |
| Ramp | TODO-TODO | Increase pressure | TODO |
| Spike | TODO-TODO | Force build test | TODO |
| End | TODO-TODO | Final pressure | TODO |

## 7. Elites & Bosses

| Time | Type | Enemy ID | Purpose | Notes |
| ---- | ---- | -------- | ------- | ----- |
| TODO | Elite | TODO | TODO | TODO |
| TODO | Boss | TODO | TODO | TODO |

## 8. XP & Rewards

- **XP Multiplier:** TODO
- **Gold / Meta Reward Multiplier:** TODO
- **Reward Pool:** `content/reward_pools/todo_map_id_rewards.tres`
- **Common Reward Bias:** TODO
- **Rare Reward Bias:** TODO

## 9. Spell & Buff Pool Rules

Use this only if the map changes reward availability or weights.

| Reward ID | Type | Weight Change | Reason |
| --------- | ---- | ------------- | ------ |
| TODO | Spell | TODO | TODO |
| TODO | Buff | TODO | TODO |

## 10. Environmental Gameplay Rules

Gameplay-only rules. Do not describe art here.

Examples:

- Safe center, dangerous edges.
- Shrinking playable area.
- Periodic hazard waves.
- Bonus XP zones.
- Slow zones.

**Rules:**

- TODO

## 11. Map Selection Metadata

Shown before starting a run.

- **Preview Icon:** TODO
- **Difficulty Label:** TODO
- **Short Description:** TODO
- **Recommended For:** TODO
- **Warning Text:** TODO

## 12. Balancing Targets

| Metric | Target |
| ------ | ------ |
| Average run duration for correct difficulty | TODO |
| Expected final player level | TODO |
| Expected kills | TODO |
| Expected total damage | TODO |
| Expected deaths for first-time players | TODO |
| Expected meta reward | TODO |

## 13. Implementation Checklist

- [ ] Map design added to [maps.md](maps.md).
- [ ] `MapData` Resource created.
- [ ] Spawn curve Resource created.
- [ ] Enemy pool references existing `EnemyData`.
- [ ] Reward pool references existing Spell / Buff Resources.
- [ ] Unlock requirement uses stable IDs.
- [ ] Map appears in Map Selection.
- [ ] Run History records map ID correctly.
- [ ] Balance notes added after first test.

## 14. Open Questions

- TODO

## Changelog

- v0.1 - initial template
