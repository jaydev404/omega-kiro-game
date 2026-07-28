class_name PlayerController
extends CharacterBody2D

# -- Exportables --
@export var move_speed: float = 150.0
@export var sprint_multiplier: float = 1.6
@export var carry_distance: float = 14.0  ## distancia del CarryPoint al centro

# -- Señales --
signal moved(direction: Vector2)
signal stopped()

@onready var _visual: PlayerVisual = $Visual
@onready var _carry_point: Marker2D = $CarryPoint

var _facing: Vector2 = Vector2.DOWN
var _delivery_locked: bool = false  ## bloqueado durante entrega múltiple

func set_delivery_locked(locked: bool) -> void:
	_delivery_locked = locked
	if locked:
		velocity = Vector2.ZERO
var max_carry: int = 1
var shield_count: int = 0

func _physics_process(_delta: float) -> void:
	if _delivery_locked:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var direction := _get_input_direction()

	if direction != Vector2.ZERO:
		_facing = direction
		var speed := move_speed * sprint_multiplier if _is_sprinting() else move_speed
		velocity = direction * speed
		_visual.set_facing(direction)
		emit_signal("moved", direction)
	else:
		velocity = Vector2.ZERO
		_visual.set_facing(Vector2.ZERO)
		emit_signal("stopped")

	_carry_point.position = Vector2.UP * carry_distance

	move_and_slide()

func _get_input_direction() -> Vector2:
	return Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	).normalized()

func _is_sprinting() -> bool:
	return Input.is_action_pressed("sprint")
