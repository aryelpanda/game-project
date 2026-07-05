## Data-driven horde pacing. Phases are sorted by start_seconds at runtime.
class_name SpawnCurveData
extends Resource

@export var phases: Array[SpawnCurvePhase] = []


func get_phase_at(elapsed_seconds: float) -> SpawnCurvePhase:
	if phases.is_empty():
		return null

	var active: SpawnCurvePhase = phases[0]
	for phase in phases:
		if phase and phase.start_seconds <= elapsed_seconds:
			active = phase
	return active
