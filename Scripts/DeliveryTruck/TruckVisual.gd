## Placeholder visual del camión de entrega.
## Reemplazar por Sprite2D cuando haya assets.
class_name TruckVisual
extends Node2D

const _BODY_COLOR   := Color(0.1, 0.55, 0.2)
const _BORDER_COLOR := Color(0.05, 0.35, 0.1)
const _TEXT_COLOR   := Color(1.0, 1.0, 1.0)
const _SIZE         := Vector2(120.0, 72.0)

func _draw() -> void:
	var rect := Rect2(-_SIZE / 2.0, _SIZE)
	draw_rect(rect, _BODY_COLOR)
	draw_rect(rect, _BORDER_COLOR, false, 2.5)
	draw_string(
		ThemeDB.fallback_font,
		Vector2(-28.0, 6.0),
		"CAMION",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		14,
		_TEXT_COLOR
	)
