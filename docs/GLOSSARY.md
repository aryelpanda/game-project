# GLOSSARY.md

Version: 0.2

> Canonical terminology for the project. Every doc, code identifier, and UI string uses the terms defined here. When you introduce a new domain word, add it to this file in the same change.

## Rule

If two words could mean the same thing, only ONE of them is canonical. The other is either removed or explicitly marked as a synonym here.

## Terms

| Term              | Definition                                                                                                        | Canonical? | Notes / Synonyms                                                                       |
| ----------------- | ----------------------------------------------------------------------------------------------------------------- | ---------- | -------------------------------------------------------------------------------------- |
| **Ability**       | Internal umbrella term for active and passive gameplay powers.                                                    | Yes        | Includes Spells, Buffs, and Talent effects.                                            |
| **Skill**         | Reserved mostly for implementation if needed. Prefer Spell, Buff, or Talent in player-facing docs.                | Maybe      | Do not use as a vague synonym for every power.                                         |
| **Spell**         | Player-facing active ability. Can be temporary run power or permanent talent-granted power.                       | Yes        | Talent-granted Spells use mana; level-up Spells do not.                                |
| **Weapon**        | An equippable item that produces attacks. Uses `WeaponData` Resource.                                             | Yes        |                                                                                        |
| **Attack**        | A single instance of a Weapon or Ability being executed.                                                          | Yes        | NOT "swing", NOT "shot" — use "attack" in code and docs.                               |
| **Projectile**    | A moving object spawned by an Attack that can collide and apply effects.                                          | Yes        |                                                                                        |
| **Damage Event**  | The structured data passed from an attacker to the Combat System describing a hit. Never "damage packet".         | Yes        |                                                                                        |
| **Buff**          | Passive power or modifier. Can be temporary for a Run, timed, or permanent through Talents.                       | Yes        | Also see Status Effect.                                                                |
| **Status Effect** | A Buff that has visible player-facing state (burning, frozen, stunned).                                           | Yes        | Implemented as a Buff internally.                                                      |
| **Modifier**      | A raw value applied to a Stat (flat or multiplicative). Buffs contain Modifiers.                                  | Yes        |                                                                                        |
| **Stat**          | A single named value on an entity (e.g. `max_health`, `move_speed`). Owned by the Stats System.                   | Yes        |                                                                                        |
| **Item**          | Any object that can exist in an inventory. Uses `ItemData` Resource.                                              | Yes        |                                                                                        |
| **Loot**          | Items or currency produced by an event (kill, chest). Determined by Loot Tables.                                  | Yes        |                                                                                        |
| **Loot Table**    | A Resource defining possible drops with weights and chances.                                                      | Yes        |                                                                                        |
| **Enemy**         | A hostile entity controlled by AI. Never "monster" or "mob" in code or docs.                                      | Yes        |                                                                                        |
| **NPC**           | A non-hostile entity the player can interact with.                                                                | Yes        |                                                                                        |
| **Actor**         | Any entity that has health and can be damaged. Player and Enemy are both Actors.                                  | Yes        |                                                                                        |
| **Area**          | A gameplay region (a level, a room, a zone).                                                                      | Yes        | NOT "map", "level", or "stage" interchangeably.                                        |
| **Run**           | A single survival session on one Map. Temporary Spells and Buffs are lost when the Run ends.                      | Yes        | Also called session in casual notes; use Run in docs and code.                         |
| **Map**           | A playable arena used for a Run, with its own enemy pools, spawn curves, and environment rules.                   | Yes        | Prefer Map for player-facing docs; Area can remain internal if useful.                 |
| **Experience**    | Progress collected during a Run from killing enemies. Used to gain in-run Levels.                                | Yes        | Short form: XP.                                                                        |
| **Level Up**      | In-run event where the player chooses 1 of 3 random temporary Spell or Buff options.                              | Yes        | Level-up rewards are lost at Run end unless explicitly converted by future systems.     |
| **Run Reward**    | Reward calculated after a Run ends, based on progress such as survival time, story progress, or enemies killed.   | Yes        | Exact formula TBD.                                                                     |
| **Meta-Progression** | Permanent account / character progress earned between Runs.                                                   | Yes        | Mainly spent in Talent Trees.                                                          |
| **Talent**        | Permanent upgrade selected outside a Run. Can grant passive Buffs or unlock mana-using Spells for future Runs.   | Yes        |                                                                                        |
| **Talent Tree**   | One of three permanent progression trees for the player character.                                                | Yes        | Exact themes TBD.                                                                      |
| **Temporary Power** | Any Spell or Buff gained during a Run and lost when the Run ends.                                               | Yes        |                                                                                        |
| **Permanent Power** | Any Talent-based upgrade that persists between Runs.                                                           | Yes        |                                                                                        |
| **Save Slot**     | A distinct persisted game state the player can load.                                                              | Yes        |                                                                                        |
| **HUD**           | Diegetic and non-diegetic in-game overlays (health bar, ammo, minimap).                                           | Yes        |                                                                                        |
| **Menu**          | Any full-screen UI (main menu, pause menu, inventory).                                                            | Yes        |                                                                                        |

## Reserved Words (Do NOT use)

Do not introduce these unless there's a very specific reason:

- **Manager** as a suffix for anything that contains gameplay logic. Managers coordinate only.
- **God class** — any class trying to own multiple systems.
- **GameManager** — forbidden by [ARCHITECTURE.md](ARCHITECTURE.md).
- **Session** as a formal system name — use **Run** instead.

## Adding a Term

1. Add a row above with a clear one-line definition.
2. If it replaces or overlaps with an existing term, mark one as canonical and the other as a synonym or delete it.
3. Update any docs that used the old inconsistent term.

## Changelog

- v0.2 - confirmed survivor-like terminology and added Run, Spell, Talent, and Meta-Progression terms.
- v0.1 - initial vocabulary
