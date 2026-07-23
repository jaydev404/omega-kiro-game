## Placeholder visual de la caja.
## Dibuja un rectángulo de color sólido.
## Reemplazar por Sprite2D cuando haya assets.
class_name PackageVisual
extends Node2D

@export var color: Color = Color(0.85, 0.55, 0.1)  ## naranja caja

const _SIZE := Vector2(32.0, 32.0)

func _draw() -> void:
	var rect := Rect2(-_SIZE / 2.0, _SIZE)
	draw_rect(rect, color)
	# borde oscuro para legibilidad
	draw_rect(rect, color.darkened(0.35), false, 2.0)
