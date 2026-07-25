class_name ChaosMainMenu
extends Node2D

## Sprites de botones
@onready var _btn_start: AnimatedSprite2D = $BtnStartSprite
@onready var _btn_shop: AnimatedSprite2D = $BtnShopSprite
@onready var _btn_exit: AnimatedSprite2D = $BtnExitSprite

## Frames: 0=normal, 1=hover, 2=pressed, 3=disabled
const FRAME_NORMAL := 0
const FRAME_HOVER := 1
const FRAME_PRESSED := 2
const FRAME_DISABLED := 3

func _ready() -> void:
	_btn_start.frame = FRAME_NORMAL
	_btn_shop.frame = FRAME_NORMAL
	_btn_exit.frame = FRAME_NORMAL

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_update_hover(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_handle_press(event.position)
		else:
			_handle_release(event.position)

func _update_hover(pos: Vector2) -> void:
	_btn_start.frame = FRAME_HOVER if _is_over(_btn_start, pos) else FRAME_NORMAL
	_btn_shop.frame = FRAME_HOVER if _is_over(_btn_shop, pos) else FRAME_NORMAL
	_btn_exit.frame = FRAME_HOVER if _is_over(_btn_exit, pos) else FRAME_NORMAL

func _handle_press(pos: Vector2) -> void:
	if _is_over(_btn_start, pos):
		_btn_start.frame = FRAME_PRESSED
	elif _is_over(_btn_shop, pos):
		_btn_shop.frame = FRAME_PRESSED
	elif _is_over(_btn_exit, pos):
		_btn_exit.frame = FRAME_PRESSED

func _handle_release(pos: Vector2) -> void:
	if _is_over(_btn_start, pos):
		_on_start()
	elif _is_over(_btn_shop, pos):
		_on_shop()
	elif _is_over(_btn_exit, pos):
		_on_exit()
	_btn_start.frame = FRAME_NORMAL
	_btn_shop.frame = FRAME_NORMAL
	_btn_exit.frame = FRAME_NORMAL

func _is_over(sprite: AnimatedSprite2D, pos: Vector2) -> bool:
	var half_w := 48.0
	var half_h := 11.0
	var rect := Rect2(sprite.global_position.x - half_w, sprite.global_position.y - half_h, 96.0, 22.0)
	return rect.has_point(pos)

func _on_start() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/ChaosGame.tscn")

func _on_shop() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/Shop.tscn")

func _on_exit() -> void:
	get_tree().quit()
