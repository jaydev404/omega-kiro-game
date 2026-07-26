class_name Drone
extends Node2D

## Señales
signal package_delivered(package: PackageBody)
signal drone_finished()

## Config
@export var speed: float = 120.0

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
var _chase_delay: float = 0.0
var _chase_time: float = 0.0  ## tiempo total persiguiendo
var _drop_marker: DropMarker = null
const _MAX_LIFETIME := 15.0
const _CHASE_DROP_DISTANCE := 20.0
const _CHASE_DROP_DELAY := 0.6  ## Tiempo que espera antes de soltar (da tiempo a esquivar)
const _CHASE_TIMEOUT := 2.0  ## Si no alcanza en 2s, suelta igualmente

func init(origin: Vector2, target: Vector2, drop_pos: Vector2, package_scene: PackedScene) -> void:
	_origin   = origin
	_target   = target
	_drop_pos = drop_pos
	global_position = origin

	_package = package_scene.instantiate() as PackageBody
	add_child(_package)
	_package.position = Vector2(0.0, 12.0)
	_package.z_index = 12
	_package.pick_up()

	# Crear marcador de caída en la posición de drop
	if not _chase_player:
		_spawn_drop_marker()

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
			_chase_time += delta
			var player_pos := _get_player_position()
			if player_pos != Vector2.INF:
				var chase_target := Vector2(player_pos.x, player_pos.y - 30.0)
				_move_to(chase_target, delta)
				# Actualizar posición del marcador al player
				if _drop_marker and is_instance_valid(_drop_marker):
					_drop_marker.global_position = player_pos
				# Timeout: si no alcanza en 2s, suelta donde esté el player
				if _chase_time >= _CHASE_TIMEOUT:
					_drop_pos = player_pos
					if _drop_marker == null:
						_spawn_drop_marker()
					_try_release_package()
					_state = State.DROPPING
					_drop_wait = 0.2
				# Si está suficientemente cerca, iniciar delay antes de soltar
				elif global_position.distance_to(chase_target) < _CHASE_DROP_DISTANCE:
					if _drop_marker == null:
						_drop_pos = player_pos
						_spawn_drop_marker()
					_chase_delay += delta
					if _chase_delay >= _CHASE_DROP_DELAY:
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

	_remove_drop_marker()

	_package.reparent(scene)
	_package.global_position = _drop_pos
	_package.drop()
	_package.z_index = 0
	emit_signal("package_delivered", _package)
	_package = null

func _force_cleanup() -> void:
	_remove_drop_marker()
	if _package != null and is_instance_valid(_package):
		_package.queue_free()
	_package = null
	emit_signal("drone_finished")
	queue_free()

func _spawn_drop_marker() -> void:
	var scene := get_tree().current_scene
	if scene == null:
		return
	_drop_marker = DropMarker.new()
	_drop_marker.global_position = _drop_pos
	scene.add_child(_drop_marker)

func _remove_drop_marker() -> void:
	if _drop_marker and is_instance_valid(_drop_marker):
		_drop_marker.queue_free()
	_drop_marker = null
