## Botón de mute — dibuja icono de speaker en gris pixel art.
## Alterna mute del bus Master al presionar.
extends Control

var _muted: bool = false
var _hovered: bool = false

func _ready() -> void:
	_muted = AudioServer.is_bus_mute(AudioServer.get_bus_index("Master"))
	custom_minimum_size = Vector2(16, 16)
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_entered.connect(func(): _hovered = true; queue_redraw())
	mouse_exited.connect(func(): _hovered = false; queue_redraw())

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_muted = not _muted
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), _muted)
		queue_redraw()
		accept_event()

func _draw() -> void:
	var color := Color(0.7, 0.7, 0.7, 1.0) if not _hovered else Color(1.0, 1.0, 1.0, 1.0)
	var s := size

	# Speaker body (rectángulo izquierdo)
	draw_rect(Rect2(s.x * 0.15, s.y * 0.35, s.x * 0.2, s.y * 0.3), color)

	# Speaker cone (triángulo)
	var cone_points := PackedVector2Array([
		Vector2(s.x * 0.35, s.y * 0.35),
		Vector2(s.x * 0.55, s.y * 0.15),
		Vector2(s.x * 0.55, s.y * 0.85),
		Vector2(s.x * 0.35, s.y * 0.65),
	])
	draw_colored_polygon(cone_points, color)

	if _muted:
		# X de mute
		var x_color := Color(0.9, 0.3, 0.3, 1.0)
		draw_line(Vector2(s.x * 0.65, s.y * 0.25), Vector2(s.x * 0.9, s.y * 0.75), x_color, 2.0)
		draw_line(Vector2(s.x * 0.9, s.y * 0.25), Vector2(s.x * 0.65, s.y * 0.75), x_color, 2.0)
	else:
		# Ondas de sonido (arcos)
		draw_arc(Vector2(s.x * 0.55, s.y * 0.5), s.x * 0.15, -0.8, 0.8, 8, color, 1.5)
		draw_arc(Vector2(s.x * 0.55, s.y * 0.5), s.x * 0.25, -0.6, 0.6, 8, color, 1.5)
