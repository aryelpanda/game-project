## Central authority for applying damage. Every HP change goes through here.
extends Node

signal damage_applied(event: DamageEvent, final_damage: float)
signal target_killed(event: DamageEvent)


func apply(event: DamageEvent) -> float:
	if not event:
		push_warning("DamageManager.apply called with null event")
		return 0.0

	if not event.target:
		push_warning("DamageEvent has no target")
		return 0.0

	var final_damage := _calculate_final_damage(event)
	_log_damage(event, final_damage)
	var delivery := _copy_for_delivery(event, final_damage)

	if not delivery.target:
		push_warning("DamageEvent delivery lost target reference")
		return 0.0

	if delivery.target.has_method("take_damage"):
		delivery.target.take_damage(delivery)

	damage_applied.emit(delivery, final_damage)

	if delivery.target.has_method("is_dead") and delivery.target.is_dead():
		target_killed.emit(delivery)

	return final_damage


func roll_critical(_source: Node) -> bool:
	# TODO: Wire critical_chance from Stats in a later milestone.
	return false


func _calculate_final_damage(event: DamageEvent) -> float:
	var damage := maxf(event.base_damage, 0.0)

	if not event.target:
		return damage

	if event.target.has_method("get_stats"):
		var target_stats: StatsBlock = event.target.get_stats()
		if target_stats:
			var armor := target_stats.get_stat(&"armor")
			damage = maxf(damage - armor, 0.0)

	return damage


func _copy_for_delivery(event: DamageEvent, final_damage: float) -> DamageEvent:
	# Resource.duplicate() does not preserve runtime Node refs on non-export fields.
	var delivery := event.duplicate()
	delivery.source = event.source
	delivery.target = event.target
	delivery.base_damage = final_damage
	return delivery


func _log_damage(event: DamageEvent, final_damage: float) -> void:
	var attack_id: StringName = event.spell_id
	if attack_id == &"":
		attack_id = event.source_id
	if attack_id == &"":
		attack_id = &"unknown"

	var source_label := _describe_actor(event.source)
	var target_label := _describe_actor(event.target)
	print(
		"[DamageManager] Attack '%s' (%s) | %s -> %s | %.1f damage"
		% [attack_id, event.damage_type, source_label, target_label, final_damage]
	)


func _describe_actor(node: Node) -> String:
	if not node:
		return "?"

	if node.is_in_group("player"):
		return "Player"

	if node.is_in_group("enemy"):
		if "data" in node and node.data:
			return "Enemy(%s)" % node.data.display_name
		return "Enemy"

	return node.name
