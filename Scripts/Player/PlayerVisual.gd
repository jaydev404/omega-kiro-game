## Placeholder visual del player.
## Dibuja un círculo con una marca de dirección.
## Reemplazar por Sprite2D/AnimatedSprite2D cuando haya assets.
class_name PlayerVisual
extends Node2D

const _BODY_COLOR := Color(0.2, 0.5, 1.0)
const _DIR_COLOR  := Color(1.0, 1.0, 1.0)
const _RADIUS     := 16.0

var _facing := Vector2.DOWN

func _draw() -> void:
	draw_circle(Vector2.ZERO, _RADIUS, _BODY_COLOR)
	draw_line(Vector2.ZERO, _facing * _RADIUS, _DIR_COLOR, 3.0)

func set_facing(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		return
	_facing = direction
	queue_redraw()
