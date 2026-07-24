class_name Drone
extends Node2D

## Señales
signal package_delivered(package: PackageBody)
signal drone_finished()

## Config
@export var speed: float = 200.0

## Internos
enum State { FLYING_IN, CHASING, DROPPING, FLYING_OUT, DONE }

var _state: State   = State.FLYING_IN
var _origin: Vector2  = Vector2.ZERO
var _target: Vector2  = Vector2.ZERO
var _drop_pos: Vector2 = Vector2.ZERO

var _package: PackageBody = null
var _drop_wait: float = 0.0
var _lifetime: float = 0.0
var _chase_player: bool = false
const _MAX_LIFETIME := 15.0
const _CHASE_DROP_DISTANCE := 20.0

func init(origin: Vector2, target: Vector2, drop_pos: Vector2, package_scene: PackedScene) -> void:
	_origin   = origin
	_target   = target
	_drop_pos = drop_pos
	global_position = origin

	_package = package_scene.instantiate() as PackageBody
	add_child(_package)
	_package.position = Vector2(0.0, 24.0)
	_package.z_index = 12
	_package.pick_up()

## Activa el modo persecución: el drone sigue al player en vez de ir a un punto fijo.
func set_chase_mode(enabled: bool) -> void:
	_chase_player = enabled

func is_carrying_package() -> bool:
	return _package != null

func _physics_process(delta: float) -> void:
	_lifetime += delta
	if _lifetime > _MAX_LIFETIME:
		_force_cleanup()
		return

	match _state:
		State.FLYING_IN:
			if _chase_player:
				# Volar hacia la pantalla primero, luego perseguir
				if _move_to(_target, delta):
					_state = State.CHASING
			else:
				if _move_to(_target, delta):
					_try_release_package()
					_state = State.DROPPING
					_drop_wait = 0.2

		State.CHASING:
			var player_pos := _get_player_position()
			if player_pos != Vector2.INF:
				# Perseguir al player (a su misma altura Y - 60 para estar encima)
				var chase_target := Vector2(player_pos.x, player_pos.y - 60.0)
				_move_to(chase_target, delta)
				# Si está suficientemente cerca, soltar
				if global_position.distance_to(chase_target) < _CHASE_DROP_DISTANCE:
					_drop_pos = player_pos
					_try_release_package()
					_state = State.DROPPING
					_drop_wait = 0.2

		State.DROPPING:
			_drop_wait -= delta
			if _drop_wait <= 0.0:
				_state = State.FLYING_OUT

		State.FLYING_OUT:
			if _move_to(_origin, delta):
				_state = State.DONE
				emit_signal("drone_finished")
				queue_free()

## Mueve hacia destino. Retorna true si llegó (o pasó de largo).
func _move_to(dest: Vector2, delta: float) -> bool:
	var distance := global_position.distance_to(dest)
	var step := speed * delta

	if step >= distance:
		global_position = dest
		return true

	var dir := (dest - global_position).normalized()
	global_position += dir * step
	return false

func _get_player_position() -> Vector2:
	var player := get_tree().current_scene.get_node_or_null("Player")
	if player:
		return player.global_position
	return Vector2.INF

func _try_release_package() -> void:
	if _package == null:
		return
	if not is_instance_valid(_package):
		_package = null
		return

	var scene := get_tree().current_scene
	if scene == null:
		_package = null
		return

	_package.reparent(scene)
	_package.global_position = _drop_pos
	_package.drop()
	_package.z_index = 0
	emit_signal("package_delivered", _package)
	_package = null

func _force_cleanup() -> void:
	if _package != null and is_instance_valid(_package):
		_package.queue_free()
	_package = null
	emit_signal("drone_finished")
	queue_free()
