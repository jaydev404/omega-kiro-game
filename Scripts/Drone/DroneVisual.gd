## Placeholder visual del dron.
## Dibuja cuerpo, rotores y un cable hacia el paquete que transporta.
## Reemplazar por Sprite2D/AnimatedSprite2D cuando haya assets.
class_name DroneVisual
extends Node2D

const _BODY_COLOR  := Color(0.25, 0.25, 0.28)
const _ROTOR_COLOR := Color(0.55, 0.55, 0.6)
const _CABLE_COLOR := Color(0.7, 0.7, 0.7)
const _BODY_SIZE   := Vector2(28.0, 12.0)
const _ROTOR_R     := 6.0
const _CABLE_LEN   := 18.0  ## longitud del cable hasta el paquete

func _draw() -> void:
	# cuerpo central
	draw_rect(Rect2(-_BODY_SIZE / 2.0, _BODY_SIZE), _BODY_COLOR)

	# rotor izquierdo
	draw_circle(Vector2(-_BODY_SIZE.x / 2.0 - _ROTOR_R, 0.0), _ROTOR_R, _ROTOR_COLOR)
	# rotor derecho
	draw_circle(Vector2( _BODY_SIZE.x / 2.0 + _ROTOR_R, 0.0), _ROTOR_R, _ROTOR_COLOR)

	# cable hacia el paquete (solo visible si el dron está cargando)
	if get_parent() and get_parent().has_method("is_carrying_package"):
		if get_parent().is_carrying_package():
			draw_line(
				Vector2(0.0, _BODY_SIZE.y / 2.0),
				Vector2(0.0, _BODY_SIZE.y / 2.0 + _CABLE_LEN),
				_CABLE_COLOR,
				1.5
			)

func _process(_delta: float) -> void:
	queue_redraw()  # refresca el cable cada frame
