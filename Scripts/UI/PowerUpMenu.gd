## PowerUpMenu — gestiona la navegación por teclado y el indicador visual de selección.
## Adjuntar al nodo PowerUpMenu en ChaosGame.tscn.
extends Control

## Referencia al indicador de selección (flecha izquierda del botón activo)
var _selected_index: int = 0
var _buttons: Array[Button] = []
var _arrow_labels: Array[Label] = []

func _ready() -> void:
	# Recopilar los botones del VBoxContainer
	var vbox := $VBoxContainer
	for child in vbox.get_children():
		if child is Button:
			_buttons.append(child as Button)

	# Crear labels de flecha para cada botón
	for i in _buttons.size():
		var arrow := Label.new()
		arrow.text = ">"
		arrow.add_theme_color_override("font_color", Color(1, 0.9, 0.2, 1))
		arrow.add_theme_font_size_override("font_size", 8)
		arrow.visible = false
		# Posicionar la flecha a la izquierda del botón
		_buttons[i].add_child(arrow)
		arrow.position = Vector2(-14, 4)
		_arrow_labels.append(arrow)

	# Conectar focus_entered de cada botón para actualizar la selección
	for i in _buttons.size():
		var idx := i  # capturar el índice para el closure
		_buttons[i].focus_entered.connect(func(): _on_button_focused(idx))

func _notification(what: int) -> void:
	# Cada vez que el menú se hace visible, enfocar el primer botón
	if what == NOTIFICATION_VISIBILITY_CHANGED and visible:
		_select(0)

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("ui_up"):
		_select((_selected_index - 1 + _buttons.size()) % _buttons.size())
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_down"):
		_select((_selected_index + 1) % _buttons.size())
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_select"):
		if _selected_index < _buttons.size():
			_buttons[_selected_index].emit_signal("pressed")
			get_viewport().set_input_as_handled()

func _select(index: int) -> void:
	_selected_index = index
	_update_arrows()
	if index < _buttons.size():
		_buttons[index].grab_focus()

func _on_button_focused(index: int) -> void:
	_selected_index = index
	_update_arrows()

func _update_arrows() -> void:
	for i in _arrow_labels.size():
		_arrow_labels[i].visible = (i == _selected_index)
