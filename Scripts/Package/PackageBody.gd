class_name PackageBody
extends CharacterBody2D

## Estados de la caja
enum State { FREE, CARRIED }

# -- Señales --
signal picked_up(package: PackageBody)
signal dropped(package: PackageBody)

# -- Config --
@export var friction: float = 5.0   ## qué tan rápido frena al deslizarse

# -- Internos --
var _state: State = State.FREE
var _push_velocity: Vector2 = Vector2.ZERO

@onready var _collision: CollisionShape2D = $CollisionShape2D

# ------------------------------------------------------------------ público --

func interact() -> void:
	pass  # lógica gestionada por PlayerCarry

func is_carried() -> bool:
	return _state == State.CARRIED

func pick_up() -> void:
	if _state == State.CARRIED:
		return
	_state = State.CARRIED
	_push_velocity = Vector2.ZERO
	_collision.set_deferred("disabled", true)
	z_index = 10  # por encima de todo durante el transporte
	emit_signal("picked_up", self)

func drop() -> void:
	if _state == State.FREE:
		return
	_state = State.FREE
	_collision.set_deferred("disabled", false)
	z_index = 0
	emit_signal("dropped", self)

## Entrega al camión — fade out y destrucción
func deliver() -> void:
	_state = State.CARRIED  # evita que _physics_process interfiera
	_collision.set_deferred("disabled", true)
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_callback(queue_free)

## Recibe velocidad de empuje desde PlayerController
func push(direction: Vector2, force: float) -> void:
	if _state == State.CARRIED:
		return
	_push_velocity = direction * force

# ------------------------------------------------------------------ interno --

func _physics_process(delta: float) -> void:
	if _state == State.CARRIED:
		velocity = Vector2.ZERO
		return

	velocity = _push_velocity
	move_and_slide()

	# propaga el empuje a cajas vecinas
	_propagate_push_to_packages()

	# frena gradualmente después del empuje
	_push_velocity = _push_velocity.move_toward(Vector2.ZERO, friction * delta * 100.0)

## Transfiere velocidad residual a cajas con las que colisiona
func _propagate_push_to_packages() -> void:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if collider is PackageBody:
			var push_dir := -collision.get_normal()
			# La fuerza propagada es proporcional a la velocidad actual
			var propagated_force := _push_velocity.length() * 0.8
			(collider as PackageBody).push(push_dir, propagated_force)
