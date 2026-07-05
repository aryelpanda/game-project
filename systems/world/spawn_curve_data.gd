## Data-driven horde pacing. Phases are sorted by start_seconds at runtime.
class_name SpawnCurveData
extends Resource

@export var phases: Array[SpawnCurvePhase] = []
@export var spawn_rate_growth_per_minute: float = 0.0 ## Compounding spawn rate boost each interval (1.0 = double).
@export var spawn_rate_growth_interval_seconds: float = 60.0 ## How often spawn rate compounds (e.g. 30 = every 30s).


func get_phase_at(elapsed_seconds: float) -> SpawnCurvePhase:
	if phases.is_empty():
		return null

	var active: SpawnCurvePhase = phases[0]
	for phase in phases:
		if phase and phase.start_seconds <= elapsed_seconds:
			active = phase
	return active
