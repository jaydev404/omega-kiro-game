## Panel de debug temporal — muestra datos del SaveManager en pantalla.
## Quitar este nodo cuando ya no sea necesario verificar el guardado.
extends Node2D

@onready var _label: Label  = $Label
@onready var _btn: Button   = $BtnReset

func _ready() -> void:
	_btn.pressed.connect(_on_reset)
	_refresh()

func _process(_delta: float) -> void:
	_refresh()

func _refresh() -> void:
	_label.text = "[DEBUG SaveManager]\n" \
		+ "Monedas:        " + str(SaveManager.coins) + "\n" \
		+ "Vel base:       " + str(SaveManager.base_move_speed) + "\n" \
		+ "Vel efectiva:   " + str(SaveManager.get_effective_move_speed()) + "\n" \
		+ "Vel nivel:      " + str(SaveManager.vel_level) + "\n" \
		+ "Carga base:     " + str(SaveManager.base_max_carry) + "\n" \
		+ "Carga efectiva: " + str(SaveManager.get_effective_max_carry()) + "\n" \
		+ "Carga nivel:    " + str(SaveManager.cant_level) + "\n" \
		+ "Corazones:      " + str(SaveManager.get_effective_max_hearts()) + "\n" \
		+ "Sprint mult:    " + str(SaveManager.base_sprint_multiplier)

func _on_reset() -> void:
	SaveManager.reset_all()
