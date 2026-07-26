class_name DropMarker
extends Node2D

## Indicador visual de dónde caerá un paquete.
## Se muestra como una X con un círculo pulsante.

@export var radius: float = 8.0
@export var color: Color = Color(0.0, 0.0, 0.0, 0.6)
@export var pulse_speed: float = 3.0

var _time: float = 0.0

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()

func _draw() -> void:
	var alpha := 0.3 + 0.3 * sin(_time * pulse_speed)
	var c := Color(color.r, color.g, color.b, alpha)

	# Círculo exterior
	draw_arc(Vector2.ZERO, radius, 0, TAU, 16, c, 1.0)

	# X interior
	var half := radius * 0.6
	draw_line(Vector2(-half, -half), Vector2(half, half), c, 1.0)
	draw_line(Vector2(half, -half), Vector2(-half, half), c, 1.0)
