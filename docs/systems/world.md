# World System

Status: MVP

## Goal

Own playable Maps / arenas used by Runs. A Map defines its arena scene, selection metadata, spawn points, enemy pool, spawn curves, and environmental rules.

## Components

- Map / arena definition (scene + `MapData` Resource)
- Map selection metadata (display name, icon, preview, difficulty, unlock state)
- Spawn points
- Enemy pool references
- Spawn curve references
- Environmental hazards
- Map transitions / selection
- Run-local world state

## Current Status

- [x] Map scene template (Arena reused for `test_arena`)
- [x] `MapData` Resource
- [x] Map gameplay design for `five_minute_gauntlet` ([../content/maps.md](../content/maps.md))
- [ ] Map Selection metadata exposed to UI (M6)
- [x] Spawner integration (`HordeSpawner` reads MapData)
- [x] Spawn curve integration (`SpawnCurveData` + `SpawnCurvePhase`)
- [x] Map load flow via World autoload (RunManager calls `World.load_map`)
- [x] Run-local world reset (scene reload on restart)
- [ ] Save integration

## Design Rules

- Maps are `.tscn` scenes plus `MapData` Resources.
- Before creating a `MapData` Resource, fill the gameplay design template in [../content/map_design_template.md](../content/map_design_template.md).
- Add each approved map design to [../content/maps.md](../content/maps.md).
- Maps expose lightweight selection data before loading the full map scene.
- Map content data (enemy pool, spawn curves, spawn points, hazards) lives in Resources.
- The World system exposes queries ("where can I spawn an enemy?"), not commands to other systems.
- Run-local map state is cleared when a Run ends.
- Persistent map unlocks belong to Save / meta-progression, not World.
- Loading a new Map unloads the previous one cleanly. No orphan nodes, no leaked signals.
- Each map defines a `play_area_rect` on `MapData`. The player hull is clamped inside this rect during a run.

## Public API

```gdscript
class_name World  # possibly an autoload

signal map_loaded(map_id: StringName)
signal map_unloaded(map_id: StringName)

func load_map(map_id: StringName, spawn_point: StringName = &"default") -> void
func current_map() -> StringName
func list_available_maps() -> Array[MapData]
func get_spawn_point(name: StringName) -> Vector2
func get_spawn_curve() -> SpawnCurveData
func get_enemy_pool() -> Array[EnemyData]
```

## Expected MapData Fields

These fields should be derived from the map gameplay template:

- `id`
- `display_name`
- `difficulty_tier`
- `run_duration_seconds`
- `scene`
- `preview_icon`
- `preview_description`
- `unlock_requirement`
- `enemy_pool`
- `spawn_curve` (`SpawnCurveData.spawn_rate_growth_per_minute` + `spawn_rate_growth_interval_seconds` compound spawn pressure)
- `spawn_min_distance` / `spawn_max_distance` (extra margin beyond visible viewport edge for off-screen horde spawns)
- `play_area_rect` (world-space bounds; player collision hull must stay inside)
- `reward_pool`
- `xp_multiplier`
- `meta_reward_multiplier`
- `environment_rules`
- `allowed_spell_pool`
- `allowed_buff_pool`

## Dependencies

- Core (scene transitions)
- UI (Map Selection reads available map metadata)
- Run (loads selected map at run start, resets map at run end)
- Enemies (spawn positions and enemy pools)
- Save (unlocked maps only)

## Open Questions

- Map format: static arenas first; procedural variants later?
- Do maps have objectives or only survival timer / death?
- Are spawn curves authored per map or shared across maps?
- Which MapData fields should become separate Resources once maps become more complex?

## References

- [../ARCHITECTURE.md](../ARCHITECTURE.md)
