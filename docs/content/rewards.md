# Level-Up Rewards Content Index

Version: 0.2

> Index of temporary run Spells and Buffs used in level-up choices. Design notes live here; gameplay values live in `.tres` files under `content/`.

## Where Content Lives

| Kind | Folder | Resource type |
| ---- | ------ | ------------- |
| Temporary Spells | `content/spells/*.tres` | `SpellData` |
| Temporary Buffs | `content/buffs/*.tres` | `BuffData` |
| Reward pools | `content/reward_pools/*.tres` | `RewardPoolData` |
| Run progression (XP curve + pool ref) | `content/run/*.tres` | `RunProgressionData` |

Player manual attack (`basic_fireball`) also lives in `content/spells/` but is **not** in the reward pool.

Enemy skills live in `content/enemy_skills/` and must never be added to reward pools.

## How to Add a New Level-Up Reward

1. Create one `.tres` file in `content/spells/` **or** `content/buffs/`.
2. Set a unique stable `id: StringName` (e.g. `&"orbiting_star"`).
3. Fill in display name, description, and gameplay values (damage, cooldown, modifiers).
4. Add a reference to the Resource in a `RewardPoolData` (e.g. [`content/reward_pools/m4_test_rewards.tres`](../../content/reward_pools/m4_test_rewards.tres)).
5. No code change is required unless the reward needs a **new spell behavior type** (see [`docs/systems/skills.md`](../systems/skills.md)).

## M4 Test Rewards

| ID | Type | File | Effect | Validation |
| -- | ---- | ---- | ------ | ---------- |
| `attack_power_boost` | Buff | [`content/buffs/attack_power_boost.tres`](../../content/buffs/attack_power_boost.tres) | +25% `attack_power` for left-click damage | Basic fireball damage 15 → ~18.75 |
| `orbiting_star` | Spell | [`content/spells/orbiting_star.tres`](../../content/spells/orbiting_star.tres) | Orbit aura, 15 contact damage | Enemies touching the star take damage |
| `big_fireball` | Spell | [`content/spells/big_fireball.tres`](../../content/spells/big_fireball.tres) | Auto projectile every 2s, random direction, 35 damage | Large fireballs spawn without player input |

**Reward pool:** [`content/reward_pools/m4_test_rewards.tres`](../../content/reward_pools/m4_test_rewards.tres)

**Progression config:** [`content/run/m4_default_progression.tres`](../../content/run/m4_default_progression.tres) — base 20 XP to level, +10 per level.

## Spell Types (M4)

| `spell_type` | Behavior |
| ------------ | -------- |
| `manual` | Player input only (basic left-click attack). |
| `auto_projectile` | Fires on cooldown via `RunSpellController`; no mana. |
| `orbit_aura` | Orbiting contact damage around the player. |

## M5 Planned — Reward Leveling (Five Minute Gauntlet)

When the same reward is picked again from the level-up pool:

| ID | Repeat-pick effect |
| -- | ------------------ |
| `attack_power_boost` | Stack another +25% `attack_power` |
| `big_fireball` | +1 fireball per cooldown volley |
| `orbiting_star` | +1 orbiting star |

Implementation deferred until M5 build starts. See [maps.md](maps.md) and [ROADMAP.md](../ROADMAP.md) M5.

## Changelog

- v0.2 - M5 reward leveling rules documented (planned, not implemented).
- v0.1 - M4 test rewards index and add-reward workflow.
