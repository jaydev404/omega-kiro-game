## HelpScreen — pantalla de ayuda con dos pestañas navegables por teclado y mouse.
## Pestaña 0: CÓMO JUGAR (controles y objetivo)
## Pestaña 1: ITEMS (descripción visual de cada objeto del juego)
extends Control

var _current_tab: int = 0
var _tabs: Array[Control] = []

@onready var _tab0: Control = $Panel/Content/Tab0
@onready var _tab1: Control = $Panel/Content/Tab1
@onready var _tab2: Control = $Panel/Content/Tab2
@onready var _btn_prev: Button = $Panel/NavRow/BtnPrev
@onready var _btn_next: Button = $Panel/NavRow/BtnNext
@onready var _tab_label: Label = $Panel/NavRow/TabLabel
@onready var _btn_close: Button = $Panel/BtnClose

const TAB_NAMES := ["CÓMO JUGAR", "ITEMS", "ENTREGAS"]

func _ready() -> void:
	_tabs = [_tab0, _tab1, _tab2]
	_btn_prev.pressed.connect(_on_prev)
	_btn_next.pressed.connect(_on_close if false else _on_prev)
	_btn_next.pressed.connect(_on_next)
	_btn_close.pressed.connect(_on_close)
	_show_tab(0)

func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED and visible and is_inside_tree():
		_show_tab(0)
		# Quitar foco de los botones para que las flechas no queden capturadas por ellos
		_btn_prev.release_focus()
		_btn_next.release_focus()
		_btn_close.release_focus()

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_LEFT, KEY_A:
				_on_prev()
				get_viewport().set_input_as_handled()
			KEY_RIGHT, KEY_D:
				_on_next()
				get_viewport().set_input_as_handled()
			KEY_ESCAPE:
				_on_close()
				get_viewport().set_input_as_handled()

func _on_prev() -> void:
	_show_tab((_current_tab - 1 + _tabs.size()) % _tabs.size())

func _on_next() -> void:
	_show_tab((_current_tab + 1) % _tabs.size())

func _on_close() -> void:
	visible = false

func _show_tab(index: int) -> void:
	_current_tab = index
	for i in _tabs.size():
		if _tabs[i]:
			_tabs[i].visible = (i == index)
	if _tab_label:
		_tab_label.text = "◀  " + TAB_NAMES[index] + "  ▶"
	if _btn_prev:
		_btn_prev.disabled = false
	if _btn_next:
		_btn_next.disabled = false
