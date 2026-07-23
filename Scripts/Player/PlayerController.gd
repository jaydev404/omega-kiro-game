class_name PlayerController
extends CharacterBody2D

# -- Exportables --
@export var move_speed: float = 150.0
@export var sprint_multiplier: float = 1.6
@export var push_force: float = 120.0
@export var carry_distance: float = 28.0  ## distancia del CarryPoint al centro
@export var max_push_count: int = 1       ## máximo de cajas empujables a la vez

# -- Señales --
signal moved(direction: Vector2)
signal stopped()

@onready var _visual: PlayerVisual = $Visual
@onready var _carry_point: Marker2D = $CarryPoint

var _facing: Vector2 = Vector2.DOWN

# Radio de detección frontal para contar cajas en la dirección de movimiento
const _PUSH_DETECT_RADIUS := 22.0

func _physics_process(_delta: float) -> void:
	var direction := _get_input_direction()

	if direction != Vector2.ZERO:
		_facing = direction
		var speed := move_speed * sprint_multiplier if _is_sprinting() else move_speed
		velocity = direction * speed
		_visual.set_facing(direction)
		emit_signal("moved", direction)
	else:
		velocity = Vector2.ZERO
		emit_signal("stopped")

	_carry_point.position = _facing * carry_distance

	# Antes de moverse: contar cajas en la dirección actual
	if direction != Vector2.ZERO and _count_packages_ahead(direction) > max_push_count:
		velocity = Vector2.ZERO

	move_and_slide()
	_apply_push_to_colliders()

func _get_input_direction() -> Vector2:
	return Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	).normalized()

func _is_sprinting() -> bool:
	return Input.is_action_pressed("sprint")

## Cuenta cuántas cajas únicas hay en la dirección de movimiento
## usando una consulta de forma frente al player.
func _count_packages_ahead(direction: Vector2) -> int:
	var space: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state

	var shape_params := PhysicsShapeQueryParameters2D.new()
	var circle := CircleShape2D.new()
	circle.radius = _PUSH_DETECT_RADIUS
	shape_params.shape = circle
	# Centro de detección: ligeramente adelante del player
	var probe_pos := global_position + direction * (14.0 + _PUSH_DETECT_RADIUS * 0.6)
	shape_params.transform = Transform2D(0.0, probe_pos)
	shape_params.collision_mask = 4  # layer "package"
	shape_params.exclude = [get_rid()]

	var results := space.intersect_shape(shape_params, max_push_count + 2)

	# Filtrar solo cajas FREE (las CARRIED no bloquean)
	var count := 0
	for r in results:
		var body: Object = r.get("collider")
		if body is PackageBody and not (body as PackageBody).is_carried():
			count += 1
	return count

func _apply_push_to_colliders() -> void:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if collider is PackageBody:
			var push_dir := -collision.get_normal()
			(collider as PackageBody).push(push_dir, push_force)
