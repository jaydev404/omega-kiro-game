class_name PlayerXP
extends Node

## Señales
signal xp_changed(current_xp: int, xp_needed: int)
signal leveled_up(new_level: int)

## Config
@export var xp_per_delivery: int = 10
@export var base_xp_to_level: int = 30  ## XP base para nivel 1
@export var xp_growth: float = 1.5  ## Multiplicador por nivel

## Internos
var _current_xp: int = 0
var _current_level: int = 0
var _xp_to_next_level: int = 0

func _ready() -> void:
	_xp_to_next_level = base_xp_to_level
	emit_signal("xp_changed", _current_xp, _xp_to_next_level)

## Agrega XP y verifica level up.
func add_xp(amount: int) -> void:
	_current_xp += amount
	while _current_xp >= _xp_to_next_level:
		_current_xp -= _xp_to_next_level
		_level_up()
	emit_signal("xp_changed", _current_xp, _xp_to_next_level)

func get_current_xp() -> int:
	return _current_xp

func get_xp_to_next() -> int:
	return _xp_to_next_level

func get_level() -> int:
	return _current_level

## Retorna el progreso como float 0.0 a 1.0
func get_progress() -> float:
	if _xp_to_next_level <= 0:
		return 0.0
	return float(_current_xp) / float(_xp_to_next_level)

func _level_up() -> void:
	_current_level += 1
	_xp_to_next_level = int(base_xp_to_level * pow(xp_growth, _current_level))
	emit_signal("leveled_up", _current_level)
