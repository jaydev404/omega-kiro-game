class_name HelperDroneCat
extends Node2D

## Drone gato que ayuda al player recogiendo box/pot y entregándolos al container correcto.
## No recibe daño. Velocidad fija 130. Carga 1 item por viaje.

@export var speed: float = 100.0
@export var pickup_radius: float = 12.0

enum State { IDLE, MOVING_TO_PACKAGE, PICKING_UP, MOVING_TO_DELIVERY, DELIVERING, WAITING }

var _state: State = State.IDLE
var _target_package: PackageBody = null
var _target_zone: DeliveryZone = null
var _carried_package: PackageBody = null
var _wait_timer: float = 0.0

const _WAIT_TIME := 1.0  ## Espera entre entregas
const _PICKUP_DISTANCE := 14.0
const _DELIVERY_DISTANCE := 18.0

func _physics_process(delta: float) -> void:
	match _state:
		State.IDLE:
			_find_package()

		State.MOVING_TO_PACKAGE:
			if not is_instance_valid(_target_package) or not _is_valid_target(_target_package):
				_reset_to_idle()
				return
			if _move_to(_target_package.global_position, delta):
				_do_pickup()

		State.PICKING_UP:
			# Transición inmediata después de pickup
			_find_delivery_zone()

		State.MOVING_TO_DELIVERY:
			if not is_instance_valid(_target_zone):
				_reset_to_idle()
				return
			if _move_to(_target_zone.global_position, delta):
				_do_delivery()

		State.DELIVERING:
			_state = State.WAITING
			_wait_timer = _WAIT_TIME

		State.WAITING:
			_wait_timer -= delta
			if _wait_timer <= 0.0:
				_state = State.IDLE

# ------------------------------------------------------------------ búsqueda

func _find_package() -> void:
	var packages := get_tree().get_nodes_in_group("packages")
	var best: PackageBody = null
	var best_dist := INF

	for node in packages:
		if not node is PackageBody:
			continue
		var pkg := node as PackageBody
		# Solo recoger BOX, BLUEPOT o THIRDBOX que estén en el suelo
		if pkg.package_type not in [PackageBody.PackageType.BOX, PackageBody.PackageType.BLUEPOT, PackageBody.PackageType.THIRDBOX]:
			continue
		if pkg.is_carried():
			continue
		if pkg.pickup_blocked:
			continue
		var dist := global_position.distance_to(pkg.global_position)
		if dist < best_dist:
			best_dist = dist
			best = pkg

	if best:
		_target_package = best
		_state = State.MOVING_TO_PACKAGE
	# Si no hay paquetes, se queda en IDLE y reintenta el siguiente frame

func _find_delivery_zone() -> void:
	if _carried_package == null:
		_reset_to_idle()
		return

	var zones := get_tree().get_nodes_in_group("delivery_zones")
	for node in zones:
		if not node is DeliveryZone:
			continue
		var zone := node as DeliveryZone
		if zone.accepts(_carried_package):
			_target_zone = zone
			_state = State.MOVING_TO_DELIVERY
			return

	# No encontró zona — soltar el paquete
	_drop_package()
	_reset_to_idle()

# ------------------------------------------------------------------ acciones

func _do_pickup() -> void:
	if not is_instance_valid(_target_package) or not _is_valid_target(_target_package):
		_reset_to_idle()
		return

	_target_package.pick_up()
	_target_package.reparent(self)
	_target_package.position = Vector2(0, 10)
	_carried_package = _target_package
	_target_package = null
	_state = State.PICKING_UP

func _do_delivery() -> void:
	if _carried_package == null or not is_instance_valid(_target_zone):
		_reset_to_idle()
		return

	_carried_package.reparent(get_tree().current_scene)
	_carried_package.global_position = _target_zone.global_position
	_target_zone.receive(_carried_package)
	_carried_package = null
	_target_zone = null
	_state = State.DELIVERING

func _drop_package() -> void:
	if _carried_package and is_instance_valid(_carried_package):
		_carried_package.reparent(get_tree().current_scene)
		_carried_package.global_position = global_position
		_carried_package.drop()
	_carried_package = null

# ------------------------------------------------------------------ utilidades

func _move_to(target: Vector2, delta: float) -> bool:
	var dist := global_position.distance_to(target)
	var step := speed * delta
	if step >= dist:
		global_position = target
		return true
	global_position += (target - global_position).normalized() * step
	return false

func _is_valid_target(pkg: PackageBody) -> bool:
	if not is_instance_valid(pkg):
		return false
	return not pkg.is_carried() and pkg.is_inside_tree()

func _reset_to_idle() -> void:
	_target_package = null
	_target_zone = null
	_state = State.IDLE
