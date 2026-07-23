class_name DroneSpawner
extends Node2D

## Señales
signal package_spawned(package: PackageBody)
signal spawn_blocked()

## Config
@export var spawn_interval: float = 5.0
@export var max_packages: int = 4
@export var drone_scene: PackedScene
@export var package_scene: PackedScene

## Separación mínima entre paquetes en el suelo (px)
const _PACKAGE_SIZE   := 36.0
## Radio de búsqueda para detectar paquetes cercanos al drop point
const _DETECT_RADIUS  := 20.0
## Número máximo de slots en fila que se buscan antes de desistir
const _MAX_SLOTS      := 8

## Internos
var _active_count: int = 0
var _drone_in_flight: bool = false
var _timer: float = 0.0

@onready var _spawn_origin: Marker2D = $SpawnOrigin
@onready var _drop_point: Marker2D   = $DropPoint

# ------------------------------------------------------------------ ciclo --

func _process(delta: float) -> void:
	_timer += delta
	if _timer >= spawn_interval:
		_timer = 0.0
		_try_spawn()

# ------------------------------------------------------------------ lógica --

func _try_spawn() -> void:
	if _drone_in_flight:
		return
	if _active_count >= max_packages:
		emit_signal("spawn_blocked")
		return
	_launch_drone()

func _launch_drone() -> void:
	var drop_pos := _find_free_drop_position()
	if drop_pos == Vector2.INF:
		emit_signal("spawn_blocked")
		return

	var drone: Drone = drone_scene.instantiate()
	add_child(drone)
	drone.init(
		_spawn_origin.global_position,
		_drop_point.global_position,   # el dron vuela hasta aquí
		drop_pos,                       # pero suelta la caja aquí
		package_scene
	)
	drone.package_delivered.connect(_on_package_delivered)
	drone.drone_finished.connect(_on_drone_finished)
	_drone_in_flight = true

## Busca posiciones en fila a la derecha del DropPoint hasta encontrar una libre.
## Devuelve Vector2.INF si no hay espacio.
func _find_free_drop_position() -> Vector2:
	var space: PhysicsDirectSpaceState2D = get_tree().current_scene.get_world_2d().direct_space_state

	for slot in range(_MAX_SLOTS):
		var candidate := _drop_point.global_position + Vector2(slot * _PACKAGE_SIZE, 0.0)

		var shape_params := PhysicsShapeQueryParameters2D.new()
		var circle := CircleShape2D.new()
		circle.radius = _DETECT_RADIUS
		shape_params.shape = circle
		shape_params.transform = Transform2D(0.0, candidate)
		shape_params.collision_mask = 4

		var results := space.intersect_shape(shape_params, 1)
		if results.is_empty():
			return candidate

	return Vector2.INF

# ------------------------------------------------------------------ callbacks --

func _on_package_delivered(package: PackageBody) -> void:
	_active_count += 1
	package.picked_up.connect(_on_package_picked_up)
	emit_signal("package_spawned", package)

func _on_drone_finished() -> void:
	_drone_in_flight = false

func _on_package_picked_up(_package: PackageBody) -> void:
	_active_count = max(0, _active_count - 1)
