## DeliveryProgressUI — feedback visual durante entrega múltiple.
## Se instancia dinámicamente sobre el player y se destruye al terminar.
class_name DeliveryProgressUI
extends Node2D

var _duration: float = 1.0
var _elapsed: float  = 0.0
var _count: int      = 0

const _BAR_W     := 36.0
const _BAR_H     := 5.0
const _BAR_COLOR := Color(0.2, 0.85, 0.3, 1.0)
const _BG_COLOR  := Color(0.1, 0.1, 0.1, 0.7)
const _TXT_COLOR := Color(1.0, 1.0, 1.0, 1.0)

func init(count: int, duration: float) -> void:
	_count    = count
	_duration = duration

func _process(delta: float) -> void:
	_elapsed += delta
	queue_redraw()

func _draw() -> void:
	var progress := clampf(_elapsed / _duration, 0.0, 1.0)
	var base_y   := -32.0   # encima del jugador

	# Texto "Entregando Nx..."
	var dot_count: int = int(_elapsed * 3.0) % 4
	var dots: String = ".".repeat(dot_count)
	draw_string(
		ThemeDB.fallback_font,
		Vector2(-_BAR_W * 0.5, base_y - 2.0),
		"Entregando %dx%s" % [_count, dots],
		HORIZONTAL_ALIGNMENT_LEFT, -1, 7, _TXT_COLOR
	)

	# Fondo de la barra
	var bar_rect := Rect2(-_BAR_W * 0.5, base_y + 2.0, _BAR_W, _BAR_H)
	draw_rect(bar_rect, _BG_COLOR)

	# Relleno de la barra
	var fill_rect := Rect2(-_BAR_W * 0.5, base_y + 2.0, _BAR_W * progress, _BAR_H)
	draw_rect(fill_rect, _BAR_COLOR)
