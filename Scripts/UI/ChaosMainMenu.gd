class_name ChaosMainMenu
extends Node2D

## Sprites de botones
@onready var _btn_start: AnimatedSprite2D = $BtnStartSprite
@onready var _btn_shop: AnimatedSprite2D  = $BtnShopSprite
@onready var _btn_exit: AnimatedSprite2D  = $BtnExitSprite
@onready var _btn_help_sprite: AnimatedSprite2D = $BtnHelpSprite
@onready var _help_screen: Control = $HelpScreenLayer/HelpScreen

## Frames: 0=normal, 1=hover, 2=pressed, 3=disabled
const FRAME_NORMAL  := 0
const FRAME_HOVER   := 1
const FRAME_PRESSED := 2
const FRAME_DISABLED := 3

## Navegación por teclado
var _selected_index: int = 0
var _keyboard_active: bool = false   ## flecha solo visible tras primera pulsación
var _arrow_label: Label = null

func _ready() -> void:
	_btn_start.frame = FRAME_NORMAL
	_btn_shop.frame  = FRAME_NORMAL
	_btn_exit.frame  = FRAME_NORMAL
	_btn_help_sprite.frame = FRAME_NORMAL

	# Crear la flecha de selección
	_arrow_label = Label.new()
	_arrow_label.text = ">"
	_arrow_label.add_theme_color_override("font_color", Color(1, 0.9, 0.2, 1))
	_arrow_label.add_theme_font_size_override("font_size", 9)
	_arrow_label.visible = false
	add_child(_arrow_label)

func _input(event: InputEvent) -> void:
	# Navegación por teclado — activa la flecha al primer uso
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_UP or event.keycode == KEY_DOWN \
			or event.keycode == KEY_W or event.keycode == KEY_S:
			_keyboard_active = true
			_arrow_label.visible = true
			var dir := -1 if (event.keycode == KEY_UP or event.keycode == KEY_W) else 1
			_selected_index = (_selected_index + dir + 4) % 4
			_update_keyboard_selection()
			get_viewport().set_input_as_handled()
			return
		if _keyboard_active and (event.keycode == KEY_ENTER or event.keycode == KEY_SPACE \
			or event.keycode == KEY_KP_ENTER):
			_confirm_selection()
			return

	# Mouse — desactiva la flecha al mover el mouse
	if event is InputEventMouseMotion:
		if _keyboard_active:
			_keyboard_active = false
			_arrow_label.visible = false
			_reset_all_frames()
		_update_hover(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_handle_press(event.position)
		else:
			_handle_release(event.position)

func _update_keyboard_selection() -> void:
	var sprites: Array[AnimatedSprite2D] = [_btn_start, _btn_shop, _btn_help_sprite, _btn_exit]
	for i in sprites.size():
		sprites[i].frame = FRAME_HOVER if i == _selected_index else FRAME_NORMAL
	var selected_sprite: AnimatedSprite2D = sprites[_selected_index]
	_arrow_label.position = selected_sprite.position + Vector2(-62, -6)

func _confirm_selection() -> void:
	match _selected_index:
		0: _on_start()
		1: _on_shop()
		2: _on_help()
		3: _on_exit()

func _reset_all_frames() -> void:
	_btn_start.frame = FRAME_NORMAL
	_btn_shop.frame  = FRAME_NORMAL
	_btn_exit.frame  = FRAME_NORMAL
	_btn_help_sprite.frame = FRAME_NORMAL

func _update_hover(pos: Vector2) -> void:
	_btn_start.frame      = FRAME_HOVER if _is_over(_btn_start,      pos) else FRAME_NORMAL
	_btn_shop.frame       = FRAME_HOVER if _is_over(_btn_shop,       pos) else FRAME_NORMAL
	_btn_exit.frame       = FRAME_HOVER if _is_over(_btn_exit,       pos) else FRAME_NORMAL
	_btn_help_sprite.frame = FRAME_HOVER if _is_over(_btn_help_sprite, pos) else FRAME_NORMAL

func _handle_press(pos: Vector2) -> void:
	if _is_over(_btn_start, pos):
		_btn_start.frame = FRAME_PRESSED
	elif _is_over(_btn_shop, pos):
		_btn_shop.frame = FRAME_PRESSED
	elif _is_over(_btn_exit, pos):
		_btn_exit.frame = FRAME_PRESSED
	elif _is_over(_btn_help_sprite, pos):
		_btn_help_sprite.frame = FRAME_PRESSED

func _handle_release(pos: Vector2) -> void:
	if _is_over(_btn_start, pos):
		_on_start()
	elif _is_over(_btn_shop, pos):
		_on_shop()
	elif _is_over(_btn_exit, pos):
		_on_exit()
	elif _is_over(_btn_help_sprite, pos):
		_on_help()
	_reset_all_frames()

func _is_over(sprite: AnimatedSprite2D, pos: Vector2) -> bool:
	var half_w := 48.0
	var half_h := 11.0
	# Convertir posición del sprite de coordenadas mundo a coordenadas viewport
	var screen_pos := get_viewport().get_canvas_transform() * sprite.global_position
	var rect := Rect2(screen_pos.x - half_w, screen_pos.y - half_h, 96.0, 22.0)
	return rect.has_point(pos)

func _on_start() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/ChaosGame.tscn")

func _on_shop() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/Shop.tscn")

func _on_help() -> void:
	_help_screen.visible = true

func _on_exit() -> void:
	get_tree().quit()
