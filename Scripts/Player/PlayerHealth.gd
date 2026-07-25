class_name PlayerHealth
extends Node

## Señales
signal health_changed(current_fragments: int, max_fragments: int, hearts: int, max_hearts: int)
signal damaged(amount: int)
signal healed(amount: int)
signal died()
signal invulnerability_started()
signal invulnerability_ended()

## Config
@export var max_hearts: int = 1  ## Corazones iniciales
@export var fragments_per_heart: int = 4  ## Fragmentos por corazón (frames del sprite)
@export var invulnerability_duration: float = 2.0
@export var blink_speed: float = 10.0

## Internos
var _current_fragments: int = 0
var _max_fragments: int = 0
var _is_invulnerable: bool = false
var _invuln_timer: float = 0.0
var _is_dead: bool = false

@onready var _visual: Node2D = get_parent().get_node_or_null("Visual")

func _ready() -> void:
	_max_fragments = max_hearts * fragments_per_heart
	_current_fragments = _max_fragments
	_emit_health_changed()

func _process(delta: float) -> void:
	if _is_invulnerable:
		_invuln_timer -= delta
		if _visual:
			_visual.modulate.a = 0.3 + 0.7 * abs(sin(_invuln_timer * blink_speed))
		if _invuln_timer <= 0.0:
			_end_invulnerability()

# ------------------------------------------------------------------ público --

func get_current_fragments() -> int:
	return _current_fragments

func get_max_fragments() -> int:
	return _max_fragments

func get_current_hearts() -> int:
	return ceili(float(_current_fragments) / fragments_per_heart)

func get_max_hearts() -> int:
	return max_hearts

func is_invulnerable() -> bool:
	return _is_invulnerable

func is_dead() -> bool:
	return _is_dead

## Recibe daño en fragmentos. Retorna true si el daño fue aplicado.
func take_damage(amount: int = 1) -> bool:
	if _is_dead:
		return false
	if _is_invulnerable:
		return false

	# Escudo absorbe el golpe
	var controller := get_parent() as PlayerController
	if controller and controller.has_shield:
		controller.has_shield = false
		_start_invulnerability()
		return false

	_current_fragments = max(0, _current_fragments - amount)
	emit_signal("damaged", amount)
	_emit_health_changed()

	if _current_fragments <= 0:
		_die()
	else:
		_start_invulnerability()

	return true

## Cura fragmentos.
func heal(amount: int = 1) -> void:
	if _is_dead:
		return
	var old := _current_fragments
	_current_fragments = min(_max_fragments, _current_fragments + amount)
	if _current_fragments > old:
		emit_signal("healed", _current_fragments - old)
		_emit_health_changed()

## Agrega un corazón completo al máximo y cura al máximo.
func add_max_heart(amount: int = 1) -> void:
	max_hearts += amount
	_max_fragments = max_hearts * fragments_per_heart
	_current_fragments = _max_fragments
	_emit_health_changed()

# ------------------------------------------------------------------ interno --

func _start_invulnerability() -> void:
	_is_invulnerable = true
	_invuln_timer = invulnerability_duration
	emit_signal("invulnerability_started")

func _end_invulnerability() -> void:
	_is_invulnerable = false
	_invuln_timer = 0.0
	if _visual:
		_visual.modulate.a = 1.0
	emit_signal("invulnerability_ended")

func _die() -> void:
	_is_dead = true
	emit_signal("died")

func _emit_health_changed() -> void:
	emit_signal("health_changed", _current_fragments, _max_fragments, get_current_hearts(), max_hearts)
