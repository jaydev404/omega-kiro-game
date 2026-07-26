## SaveManager — fuente de verdad unica para todos los datos persistentes.
## Configurar como Autoload: Project Settings > Autoload > SaveManager
extends Node

const SAVE_PATH    := "user://save.json"
const SAVE_VERSION := 1

## ----------------------------------------------------------------
## Valores base parametrizables.
## Cambiar estas constantes ajusta los stats iniciales del jugador
## sin tocar ningun otro archivo.
## ----------------------------------------------------------------
const DEFAULT_MOVE_SPEED  := 150.0
const DEFAULT_MAX_CARRY   := 1
const DEFAULT_MAX_HEARTS  := 1
const DEFAULT_SPRINT_MULT := 1.6

## ---------------------------------------------------------------- datos en memoria

var coins: int = 0

var vel_level: int      = 0
var vel_purchases: int  = 0
var cant_level: int     = 0
var cant_purchases: int = 0
var hp_level: int       = 0
var has_revive: bool    = false   ## si compró el revive en la tienda

## Estado de uso del revive — se resetea al inicio de cada partida, no persiste
var revive_used: bool   = false

var base_move_speed: float        = DEFAULT_MOVE_SPEED
var base_max_carry: int           = DEFAULT_MAX_CARRY
var base_max_hearts: int          = DEFAULT_MAX_HEARTS
var base_sprint_multiplier: float = DEFAULT_SPRINT_MULT

## ---------------------------------------------------------------- ciclo de vida

func _ready() -> void:
	load_data()

## ---------------------------------------------------------------- publica

## Carga desde save.json. Usa defaults si no existe o esta corrupto.
func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		_reset_to_defaults()
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		_reset_to_defaults()
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:
		_reset_to_defaults()
		return
	_load_from_dict(parsed as Dictionary)

## Guarda el estado actual a save.json.
func save_data() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: no se pudo escribir " + SAVE_PATH)
		return
	file.store_string(JSON.stringify(_to_dict(), "\t"))
	file.close()

## Velocidad efectiva al inicio de partida (base + bonus de tienda).
func get_effective_move_speed() -> float:
	return base_move_speed + vel_level * 15.0

## Capacidad de carga efectiva (base + bonus de tienda).
func get_effective_max_carry() -> int:
	return base_max_carry + cant_level

## Corazones efectivos al inicio de partida.
func get_effective_max_hearts() -> int:
	return base_max_hearts + hp_level

## Agrega monedas y guarda.
func add_coins(amount: int) -> void:
	coins += amount
	save_data()

## Gasta monedas. Retorna false si no hay saldo suficiente.
func spend_coins(amount: int) -> bool:
	if coins < amount:
		return false
	coins -= amount
	save_data()
	return true

## Borra todos los datos (util para testing).
func reset_all() -> void:
	_reset_to_defaults()
	save_data()

## ---------------------------------------------------------------- privado

func _reset_to_defaults() -> void:
	coins          = 0
	vel_level      = 0
	vel_purchases  = 0
	cant_level     = 0
	cant_purchases = 0
	hp_level       = 0
	has_revive     = false
	base_move_speed        = DEFAULT_MOVE_SPEED
	base_max_carry         = DEFAULT_MAX_CARRY
	base_max_hearts        = DEFAULT_MAX_HEARTS
	base_sprint_multiplier = DEFAULT_SPRINT_MULT

func _to_dict() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"coins": coins,
		"upgrades": {
			"vel_level":      vel_level,
			"vel_purchases":  vel_purchases,
			"cant_level":     cant_level,
			"cant_purchases": cant_purchases,
			"hp_level":       hp_level,
			"has_revive":     has_revive
		},
		"base_stats": {
			"move_speed":        base_move_speed,
			"max_carry":         base_max_carry,
			"max_hearts":        base_max_hearts,
			"sprint_multiplier": base_sprint_multiplier
		}
	}

func _load_from_dict(data: Dictionary) -> void:
	coins = data.get("coins", 0)

	var upg: Dictionary = data.get("upgrades", {})
	vel_level      = upg.get("vel_level",      0)
	vel_purchases  = upg.get("vel_purchases",  0)
	cant_level     = upg.get("cant_level",     0)
	cant_purchases = upg.get("cant_purchases", 0)
	hp_level       = upg.get("hp_level",       0)
	has_revive     = upg.get("has_revive",     false)

	var stats: Dictionary = data.get("base_stats", {})
	base_move_speed        = stats.get("move_speed",        DEFAULT_MOVE_SPEED)
	base_max_carry         = stats.get("max_carry",         DEFAULT_MAX_CARRY)
	base_max_hearts        = stats.get("max_hearts",        DEFAULT_MAX_HEARTS)
	base_sprint_multiplier = stats.get("sprint_multiplier", DEFAULT_SPRINT_MULT)
