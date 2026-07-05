# TECH_STACK.md

Version: 0.3

> Source of truth for tools, formats, and technical constraints. Keep the stack small until the core loop / vertical slice proves the game.

## Project Type

- **Game:** downloadable Steam game.
- **Genre:** 2D top-down pixel-art survivor-like.
- **Engine:** Godot 4.x.
- **Language:** GDScript only.
- **Primary platform:** Windows on Steam.
- **Steam features:** no achievements, shared achievements, leaderboards, or online services planned right now.

## Core Runtime Stack

| Area | Choice | Notes |
| ---- | ------ | ----- |
| Engine | Godot 4.7 stable | Pinned in `project.godot` (`config/features`). Update this row whenever the editor version changes. |
| Language | GDScript | No C#, no GDExtension unless explicitly approved later. |
| Rendering | Godot 2D | Pixel-art top-down gameplay. |
| Data | Godot Resources (`.tres`) | Spells, buffs, enemies, talents, maps, stats, reward pools, spawn curves. |
| Scenes | `.tscn` | Player, enemies, projectiles, UI, maps, VFX. |
| Saves | Local files via Godot `FileAccess` | Steam Cloud can be added later if desired. |

## Art Stack

Every character, enemy, spell, buff, talent, skill, and map can have associated art. Keep source art and game-ready exports separate.

| Area | Choice | Notes |
| ---- | ------ | ----- |
| Pixel art source | Aseprite | Recommended for sprites, animations, icons, and effects. |
| Export format | PNG / PNG sprite sheets | Imported by Godot. |
| Animation | Godot `AnimatedSprite2D` / `SpriteFrames` | Use sprite sheets or frame sequences based on asset size. |
| Tiles / maps | Godot `TileMapLayer` + Godot tilesets | Avoid external map tools unless Godot becomes limiting. |
| Source art folder | `art_source/` | Store `.aseprite` and other editable source files. |
| Runtime art folder | `assets/` and/or `content/` | Store exported PNGs used by Godot. |

## Placeholder & Art Timing Policy

Use Godot built-in placeholders for all gameplay development from M2 through M8. This keeps the git history clean, forces the code to stay data-driven, and prevents third-party licensing entanglements.

Approved placeholder tools:

- `PlaceholderTexture2D` for sprites.
- `ColorRect`, `Polygon2D`, `Line2D` for shapes and outlines.
- Tinted rectangles / circles for enemies, projectiles, and pickups.
- Different colors and sizes to visually differentiate content types during testing.

Not allowed before M9:

- Downloaded third-party art packs (Kenney, itch.io, OpenGameArt, etc.), even CC0.
- AI-generated sprites.
- Custom Aseprite art.

Real Aseprite art work begins in M9.A (content buildout) and M9.C (feel & polish), as defined in [ROADMAP.md](ROADMAP.md).

## Audio Stack

| Area | Choice | Notes |
| ---- | ------ | ----- |
| Music | OGG | Good compression for Steam builds. |
| SFX | WAV or OGG | WAV for short source-quality SFX, OGG for larger compressed sounds. |
| Editing | Audacity / Reaper / FL Studio / LMMS | Use whichever tool is preferred. |
| Runtime | Godot AudioStreamPlayer nodes | Managed through the Audio system. |

## Version Control

| Area | Choice | Notes |
| ---- | ------ | ----- |
| Source control | Git | Required for production safety. |
| Remote | GitHub (`aryelpanda/game-project`) | HTTPS push; full commit history stored on GitHub. |
| Large binaries | Git LFS | Use for `.png`, `.aseprite`, `.wav`, `.ogg`, `.psd`, large exported art/audio. |
| Ignored folders | `.godot/`, `.import/`, temporary exports | Keep generated files out of version control. |

### Workflow

1. **Commit** — each commit is a restorable snapshot with a message describing the change.
2. **Push** — uploads commits to GitHub; nothing is lost from history unless force-pushed.
3. **Revert** — use `git revert <hash>` to undo a commit safely, or `git checkout <hash> -- <file>` to restore a single file.

One logical change per commit when possible. Tag milestones (e.g. `v0.3-m3-horde`) for important versions. See `.cursor/rules/90-git-commits.mdc` for AI commit/push policy.

## Steam Stack

For MVP and vertical slice:

- No Steamworks plugin required.
- No backend server.
- No database.
- No leaderboards.
- No achievements.

Later, near release:

- SteamPipe for uploading builds.
- Steamworks / GodotSteam only if needed for achievements, cloud saves, overlay, stats, or leaderboards.
- Store assets: capsule art, screenshots, trailer, description, tags.

## Not Needed Right Now

Do NOT add these unless a real requirement appears:

- C#.
- GDExtension.
- Backend server.
- Online accounts.
- Database.
- Multiplayer stack.
- Analytics SDK.
- External map editor like Tiled.
- Steamworks integration before the game needs Steam-specific features.

## Rule of Thumb

Use:

```text
Godot 4.x + GDScript + .tres Resources + Aseprite + Git LFS + Godot TileMap + OGG/WAV audio
```

That is enough to build the full game. Add tools only when the project has a clear production need.

## Changelog

- v0.3 - added Placeholder & Art Timing Policy: Godot built-in placeholders only through M8; real art starts in M9.A / M9.C.
- v0.2 - pinned engine to Godot 4.7 stable after M0 skeleton verified booting.
- v0.1 - initial stack recommendation.
