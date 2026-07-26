## KeyboardMenu — navegación por teclado genérica para menús con Button de Godot.
## Adjuntar al nodo Control que contiene los botones.
## La flecha solo aparece cuando el jugador presiona arriba/abajo por primera vez.
extends Control

var _selected_index: int = 0
var _buttons: Array[Button] = []
var _arrow_labels: Array[Label] = []
var _keyboard_active: bool = false

func _ready() -> void:
	_collect_buttons()

func _collect_buttons() -> void:
	_buttons.clear()
	_arrow_labels.clear()
	# Buscar botones recursivamente en el primer VBoxContainer encontrado
	var vbox := _find_vbox(self)
	if vbox == null:
		return
	for child in vbox.get_children():
		if child is Button:
			_buttons.append(child as Button)
			var arrow := Label.new()
			arrow.text = "▶"
			arrow.add_theme_color_override("font_color", Color(1, 0.9, 0.2, 1))
			arrow.add_theme_font_size_override("font_size", 8)
			arrow.visible = false
			(child as Button).add_child(arrow)
			arrow.position = Vector2(-14, 4)
			_arrow_labels.append(arrow)
	# Conectar focus_entered para sincronizar con el mouse
	for i in _buttons.size():
		var idx := i
		_buttons[i].focus_entered.connect(func():
			if _keyboard_active:
				_selected_index = idx
				_update_arrows()
		)

func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED and visible:
		# Re-recopilar botones por si cambió la escena
		if _buttons.is_empty():
			_collect_buttons()
		# Ocultar flecha hasta que el jugador presione una tecla
		_keyboard_active = false
		_hide_all_arrows()

func _unhandled_input(event: InputEvent) -> void:
	if not visible or _buttons.is_empty():
		return

	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_UP:
				_activate_keyboard()
				_select((_selected_index - 1 + _buttons.size()) % _buttons.size())
				get_viewport().set_input_as_handled()
			KEY_DOWN:
				_activate_keyboard()
				_select((_selected_index + 1) % _buttons.size())
				get_viewport().set_input_as_handled()
			KEY_ENTER, KEY_SPACE, KEY_KP_ENTER:
				if _keyboard_active and _selected_index < _buttons.size():
					_buttons[_selected_index].emit_signal("pressed")

	# Mouse desactiva la flecha
	elif event is InputEventMouseMotion and _keyboard_active:
		_keyboard_active = false
		_hide_all_arrows()

func _activate_keyboard() -> void:
	if not _keyboard_active:
		_keyboard_active = true
		_update_arrows()

func _select(index: int) -> void:
	_selected_index = index
	_update_arrows()
	_buttons[index].grab_focus()

func _update_arrows() -> void:
	for i in _arrow_labels.size():
		_arrow_labels[i].visible = _keyboard_active and (i == _selected_index)

func _hide_all_arrows() -> void:
	for arrow in _arrow_labels:
		arrow.visible = false

func _find_vbox(node: Node) -> VBoxContainer:
	for child in node.get_children():
		if child is VBoxContainer:
			return child as VBoxContainer
		var found := _find_vbox(child)
		if found:
			return found
	return null
