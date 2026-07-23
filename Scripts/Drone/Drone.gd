class_name Drone
extends Node2D

## Señales
signal package_delivered(package: PackageBody)
signal drone_finished()

## Config
@export var speed: float = 200.0

## Internos
enum State { FLYING_IN, DROPPING, FLYING_OUT, DONE }

var _state: State   = State.FLYING_IN
var _origin: Vector2  = Vector2.ZERO
var _target: Vector2  = Vector2.ZERO
var _drop_pos: Vector2 = Vector2.ZERO  # posición final donde se suelta la caja

var _package: PackageBody = null

func init(origin: Vector2, target: Vector2, drop_pos: Vector2, package_scene: PackedScene) -> void:
	_origin   = origin
	_target   = target
	_drop_pos = drop_pos
	global_position = origin

	# Instanciar el paquete como hijo del dron para que viaje con él
	_package = package_scene.instantiate() as PackageBody
	add_child(_package)
	_package.position = Vector2(0.0, 24.0)  # cuelga 24px debajo del dron
	_package.z_index = 12                    # sobre el dron y sobre el camión
	_package.pick_up()                       # desactiva colisión mientras viaja

## Usado por DroneVisual para decidir si dibujar el cable
func is_carrying_package() -> bool:
	return _package != null

func _physics_process(delta: float) -> void:
	match _state:
		State.FLYING_IN:
			_move_toward(_target, delta)
			if global_position.distance_to(_target) < 2.0:
				global_position = _target
				_state = State.DROPPING
				_release_package()

		State.FLYING_OUT:
			_move_toward(_origin, delta)
			if global_position.distance_to(_origin) < 2.0:
				_state = State.DONE
				emit_signal("drone_finished")
				queue_free()

func _move_toward(dest: Vector2, delta: float) -> void:
	var dir := (dest - global_position).normalized()
	global_position += dir * speed * delta

func _release_package() -> void:
	# Mover el paquete a la posición libre calculada por DroneSpawner
	var scene := get_tree().current_scene
	_package.reparent(scene)
	_package.global_position = _drop_pos
	_package.drop()              # reactiva colisión
	_package.z_index = 0

	emit_signal("package_delivered", _package)
	_package = null

	await get_tree().create_timer(0.25).timeout
	_state = State.FLYING_OUT
