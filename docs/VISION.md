# VISION.md

Version: 0.2

> This is the single most important document in the project. Everything downstream (roadmap, systems, content, marketing) depends on it. Fill in each section deliberately. Update the version when you make substantive changes.

---

## 1. Elevator Pitch

*One or two sentences a stranger could repeat back after hearing them once.*

Guiding questions:

- What does the player do?
- What makes it different from the nearest 2 competitors?
- Why would someone choose this over those competitors?

**Draft:**

> A survivor-like action game where the player stands against endless enemy hordes, levels up during each run, chooses random spells and buffs, and uses post-run progress to unlock permanent talent-tree power.

---

## 2. Genre & Sub-Genre

Guiding questions:

- Primary genre (e.g. ARPG, roguelike, bullet-heaven, metroidvania, survivors-like, deckbuilder)?
- Any sub-genre or twist?
- Perspective (2D top-down, 2D side-scroller, 2.5D, 3D)?

**Draft:**

- Primary genre: Survival action / survivor-like.
- Sub-genre / twist: Vampire Survivors-style roguelite with temporary run builds and permanent talent-tree progression.
- Perspective: Top-down arena view, with the player kept near the center of the screen.

---

## 3. Core Loop

*The 15-to-90 second loop the player repeats hundreds of times.*

Guiding questions:

- What action does the player take most often?
- What immediate feedback follows?
- What longer-term reward accumulates from the loop?

**Draft:**

```text
Player survives in an arena while hordes rush toward them
  -> kills enemies and collects experience
  -> levels up and chooses 1 of 3 random spells or buffs
  -> becomes stronger for the current run
  -> run ends by death / completion / future objective
  -> player earns meta-progression for permanent talent trees
  -> starts the next run stronger or with new options
```

Run powers are temporary unless explicitly granted by permanent talents.

---

## 4. Player Fantasy

*What does the player feel like they are while playing?*

Examples: "a wandering necromancer building an army", "a swarm-clearing power fantasy", "a careful survivor managing scarce resources".

**Draft:**

> The player should feel like a fragile survivor who grows into a screen-clearing force during each run, then returns between runs to make permanent choices that shape future sessions.

---

## 5. Design Pillars (3-5)

*Non-negotiable qualities. Every design decision is checked against these.*

Examples:

- "Every run tells a different story."
- "The player always understands why they died."
- "No decision is punished retroactively."

**Draft:**

1. **Readable chaos:** the screen can become intense, but the player should understand threats, rewards, and deaths.
2. **Fast build decisions:** every level-up choice should feel meaningful within seconds.
3. **Temporary run power:** random spells and buffs create different builds each session and are lost when the run ends.
4. **Permanent growth:** talent trees give long-term goals without replacing player skill.
5. **Data-driven expansion:** new enemies, spells, buffs, maps, and talents should be added through Resources whenever possible.

---

## 6. Target Platform & Scope

- **Primary platform:** Steam (Windows).
- **Secondary platforms:** TODO: decide later (Steam Deck / Proton support is likely desirable).
- **Estimated scope:** Session-based replayable game; exact launch content count TBD.
- **Solo / small team:** Assume small-team scope unless updated.
- **Target development budget in months:** TODO.

---

## 7. Inspirations

*3-5 games. For each, one sentence on what you are taking and what you are deliberately NOT taking.*

| Game              | Take                                               | Do NOT Take                                      |
| ----------------- | -------------------------------------------------- | ------------------------------------------------ |
| Vampire Survivors | Horde pressure, XP gems, fast level-up choices.    | Blind copying exact weapons, pacing, or economy. |
| Hades / roguelites | Clear between-run growth and build identity.      | Heavy narrative scope unless explicitly planned.  |
| ARPGs             | Passive talent-tree satisfaction and stat growth.  | Inventory-heavy loot complexity in early MVP.     |

---

## 8. Non-Goals

*Things this game explicitly will NOT try to be. These are as important as the goals.*

Examples: "Not a competitive multiplayer game.", "No procedurally generated narrative.", "No microtransactions."

**Draft:**

- Not a traditional inventory-heavy RPG at MVP.
- Not multiplayer at launch unless explicitly approved later.
- Not a detailed spell/enemy design document yet; those belong in system docs and Resources later.
- Not a game where all progression happens inside one run; meta-progression matters.

---

## 9. Success Criteria

*How do you know the game is done and shipped-worthy?*

Guiding questions:

- Minimum content quantity for launch (levels, enemies, bosses, weapons)?
- Quality bar (screenshots people share, review score target)?
- What does the vertical slice look like?

**Draft:**

- Content minimums: TODO, but vertical slice should include 1 map, 1 character, several enemy types, several temporary spells/buffs, and a small talent tree.
- Quality bar: a new player understands movement, enemy threat, XP collection, level-up choices, and run rewards without external explanation.
- Vertical slice definition: a 10-minute playable run with hordes, XP, level-up choices, temporary power growth, death/end summary, and post-run talent spending.

---

## 10. Open Questions

*Things you have not decided yet. Move them to a decision once resolved.*

- Exact condition for ending a run: death only, timer completion, boss kill, objective, or combination?
- Exact formula for post-run talent rewards.
- Number and theme of the 3 talent trees.
- Whether player attacks automatically, manually, or both.
- Whether maps are static arenas, procedural variants, or handcrafted stages.

---

## Changelog

- v0.2 - added survivor-like game concept, run loop, temporary powers, and meta-progression.
- v0.1 - initial template
