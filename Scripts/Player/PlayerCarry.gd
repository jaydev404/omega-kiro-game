class_name PlayerCarry
extends Node

# -- Señales --
signal package_picked_up(package: PackageBody)
signal package_dropped(package: PackageBody)

## Config
@export var drop_check_radius: float = 10.0
@export var stack_offset: float = 12.0
@export var drop_distance_extra: float = 12.0

@onready var _carry_point: Marker2D = $"../CarryPoint"
@onready var _interaction: PlayerInteraction = $"../PlayerInteraction"
@onready var _visual: PlayerVisual = $"../Visual"
@onready var _controller: PlayerController = get_parent() as PlayerController

## Radio para detectar si hay algo bloqueando la posición de drop
const _DROP_CHECK_RADIUS := 10.0

## Distancia vertical entre paquetes apilados
const _STACK_OFFSET := 12.0

## Paquetes cargados (array, se apilan)
var _carried_packages: Array[PackageBody] = []

func _ready() -> void:
	_interaction.interact_pressed.connect(_on_interact_pressed)

# ------------------------------------------------------------------ público --

func is_carrying() -> bool:
	return not _carried_packages.is_empty()

func get_carried_package() -> PackageBody:
	if _carried_packages.is_empty():
		return null
	# Retorna el de arriba (último agregado)
	return _carried_packages[-1]

func get_carry_count() -> int:
	return _carried_packages.size()

# ------------------------------------------------------------------ interno --

func _on_interact_pressed(interactable: Node) -> void:
	if interactable is DeliveryZone and is_carrying():
		_deliver(interactable as DeliveryZone)
	elif interactable is PackageBody and not (interactable as PackageBody).is_carried():
		_try_pick_up(interactable as PackageBody)
	elif is_carrying():
		_try_drop()

func _try_pick_up(package: PackageBody) -> void:
	# Verificar si puede cargar más
	if _carried_packages.size() >= _controller.max_carry:
		return
	_pick_up(package)

func _pick_up(package: PackageBody) -> void:
	package.pick_up()
	package.reparent(_carry_point)
	# Apilar: cada paquete va más arriba
	package.position = Vector2(0, -_carried_packages.size() * stack_offset)
	_carried_packages.append(package)
	_visual.set_carrying(true)
	emit_signal("package_picked_up", package)

func _try_drop() -> void:
	var drop_pos := _controller.global_position + _controller._facing * (_controller.carry_distance + drop_distance_extra)
	if _is_drop_blocked(drop_pos):
		return
	_drop_at(drop_pos)

func _drop_at(drop_pos: Vector2) -> void:
	# Suelta el paquete de arriba (último)
	var package: PackageBody = _carried_packages.pop_back()
	var scene_root := get_tree().current_scene
	package.reparent(scene_root)
	package.global_position = drop_pos
	package.velocity = Vector2.ZERO
	package.drop()

	if _carried_packages.is_empty():
		_visual.set_carrying(false)

	emit_signal("package_dropped", package)

func _deliver(zone: DeliveryZone) -> void:
	# Entrega el paquete de arriba (último)
	var package: PackageBody = _carried_packages[-1]

	if not zone.accepts(package):
		return

	_carried_packages.pop_back()
	package.reparent(get_tree().current_scene)
	zone.receive(package)

	if _carried_packages.is_empty():
		_visual.set_carrying(false)

	emit_signal("package_dropped", package)

## Verifica si hay un objeto o cuerpo estático bloqueando la posición de drop
func _is_drop_blocked(pos: Vector2) -> bool:
	var space: PhysicsDirectSpaceState2D = _controller.get_world_2d().direct_space_state
	var shape_params := PhysicsShapeQueryParameters2D.new()
	var circle := CircleShape2D.new()
	circle.radius = drop_check_radius
	shape_params.shape = circle
	shape_params.transform = Transform2D(0.0, pos)
	shape_params.collision_mask = 5
	shape_params.exclude = [_controller.get_rid()]
	var results := space.intersect_shape(shape_params, 1)
	return not results.is_empty()
