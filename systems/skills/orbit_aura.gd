## Orbiting damage aura for auto-run Spells. Child of player; pooled nodes stay local.
class_name OrbitAura
extends Area2D

var _spell: SpellData
var _source: Node2D
var _angle: float = 0.0
var _radius: float = 64.0
var _hit_cooldowns: Dictionary = {}


func configure(spell: SpellData, source: Node2D, start_angle: float) -> void:
	_spell = spell
	_source = source
	_angle = start_angle
	_radius = spell.orbit_radius if spell else 64.0
	_hit_cooldowns.clear()
	monitoring = true
	show()


func reset_for_pool() -> void:
	_spell = null
	_source = null
	_angle = 0.0
	_hit_cooldowns.clear()
	set_deferred("monitoring", false)
	hide()


func _physics_process(delta: float) -> void:
	if not _spell or not _source or not is_instance_valid(_source):
		return

	_angle += _spell.orbit_speed * delta
	position = Vector2.from_angle(_angle) * _radius


func _on_body_entered(body: Node2D) -> void:
	_try_hit(body)


func _on_body_exited(body: Node2D) -> void:
	if body:
		_hit_cooldowns.erase(body.get_instance_id())


func _try_hit(body: Node2D) -> void:
	if not _spell or not _source or not body:
		return

	if body == _source:
		return

	if not body.is_in_group("enemy"):
		return

	if body.has_method("is_dead") and body.is_dead():
		return

	var body_id := body.get_instance_id()
	var now := Time.get_ticks_msec() / 1000.0
	if _hit_cooldowns.get(body_id, 0.0) > now:
		return

	_hit_cooldowns[body_id] = now + _spell.orbit_hit_cooldown

	var payload := DamageEvent.new()
	payload.source = _source
	payload.target = body
	payload.base_damage = _spell.base_damage
	payload.damage_type = _spell.damage_type
	payload.spell_id = _spell.id
	DamageManager.apply(payload)
