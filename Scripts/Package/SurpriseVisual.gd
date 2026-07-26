## Visual placeholder de la caja sorpresa.
## Dibuja una caja morada con "?" blanco encima.
## Reemplazar por Sprite2D cuando haya asset.
extends Node2D

const _BOX_COLOR    := Color(0.55, 0.1, 0.75)
const _BORDER_COLOR := Color(0.35, 0.05, 0.5)
const _TEXT_COLOR   := Color(1.0, 1.0, 1.0)
const _SIZE         := Vector2(16.0, 16.0)

func _draw() -> void:
	var rect := Rect2(-_SIZE / 2.0, _SIZE)
	draw_rect(rect, _BOX_COLOR)
	draw_rect(rect, _BORDER_COLOR, false, 1.5)
	draw_string(
		ThemeDB.fallback_font,
		Vector2(-4.0, 5.0),
		"?",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		11,
		_TEXT_COLOR
	)
