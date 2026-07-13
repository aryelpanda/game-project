# Assets (runtime art)

Godot-ready art and audio that the game loads at runtime.
Gameplay numbers stay in `content/`. Editable source files stay in `art_source/`.

```text
art_source/  → export →  assets/  ← referenced by ←  content/*.tres
```

## Layout

```text
assets/
├── characters/player/     # Player sprites / anims
├── enemies/<enemy_id>/    # Per-enemy art
├── spells/<spell_family>/ # Spell / projectile art (e.g. fireball/)
├── buffs/<buff_id>/       # Buff icons / FX
├── ui/icons|hud|fonts/    # Interface art
├── maps/tilesets|backgrounds/
├── vfx/impacts|auras/     # Shared FX not tied to one spell/enemy
├── audio/sfx|music/
└── third_party/           # Full vendor packs while evaluating only
```

## Rules

1. **Snake_case ids** matching content where possible (`test_grunt`, `orbiting_star`, `fireball`).
2. **One family folder** for shared visuals. Basic vs Big Fireball share `spells/fireball/`; size comes from `ProjectileData`, not duplicate PNGs.
3. **Frames** live in `frames/` as `<name>_01.png`, `<name>_02.png`, …
4. **SpriteFrames** `.tres` lives next to that folder (e.g. `fireball_frames.tres`).
5. **Third-party:** extract only what you use into the domain folder and keep `LICENSE.txt`. Do not ship long-term references into `third_party/`.
6. **No spaces** in file names.
7. Until M9, prefer placeholders unless an explicit exception is approved (see `docs/TECH_STACK.md`).

## Add a new spell visual

1. Create `assets/spells/<spell_family>/frames/`.
2. Drop exported PNGs, add `SpriteFrames` resource.
3. Point `ProjectileData.sprite_frames` (or other fields) from the spell’s `.tres` in `content/spells/`.
4. Keep Aseprite / AI sources under `art_source/spells/<spell_family>/`.
