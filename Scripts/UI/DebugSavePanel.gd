## Panel de debug — muestra y permite editar datos del SaveManager en pantalla.
## Quitar este nodo cuando ya no sea necesario verificar el guardado.
extends Node2D

@onready var _label: Label  = $Label
@onready var _btn: Button   = $BtnReset

var _buttons_created: bool = false

func _ready() -> void:
	_btn.pressed.connect(_on_reset)
	_create_edit_buttons()
	_refresh()

func _process(_delta: float) -> void:
	_refresh()

func _refresh() -> void:
	_label.text = "[DEBUG SaveManager]\n" \
		+ "Monedas:        " + str(SaveManager.coins) + "\n" \
		+ "Vel nivel:      " + str(SaveManager.vel_level) + "\n" \
		+ "Vel efectiva:   " + str(SaveManager.get_effective_move_speed()) + "\n" \
		+ "Cant nivel:     " + str(SaveManager.cant_level) + "\n" \
		+ "Cant efectiva:  " + str(SaveManager.get_effective_max_carry()) + "\n" \
		+ "HP nivel:       " + str(SaveManager.hp_level) + "\n" \
		+ "Corazones:      " + str(SaveManager.get_effective_max_hearts()) + "\n" \
		+ "Revive:         " + str(SaveManager.has_revive) + "\n" \
		+ "Helper:         " + str(SaveManager.has_helper)

func _on_reset() -> void:
	SaveManager.reset_all()

func _create_edit_buttons() -> void:
	if _buttons_created:
		return
	_buttons_created = true

	var x_offset := 130.0
	var line_h := 10.0   # Altura por línea del label (font_size 7)
	var btn_w := 14.0
	var btn_h := 10.0
	var font_size := 5

	# Líneas donde van los botones (0-indexed, línea 0 = título)
	var rows := [
		{"line": 1, "plus": _add_coins, "minus": _sub_coins},
		{"line": 2, "plus": _add_vel, "minus": _sub_vel},
		{"line": 4, "plus": _add_cant, "minus": _sub_cant},
		{"line": 6, "plus": _add_hp, "minus": _sub_hp},
		{"line": 8, "plus": _toggle_revive, "minus": _toggle_revive},
		{"line": 9, "plus": _toggle_helper, "minus": _toggle_helper},
	]

	for row in rows:
		var y := row["line"] as float * line_h

		var btn_minus := Button.new()
		btn_minus.text = "-"
		btn_minus.position = Vector2(x_offset, y)
		btn_minus.size = Vector2(btn_w, btn_h)
		btn_minus.add_theme_font_size_override("font_size", font_size)
		btn_minus.pressed.connect(row["minus"])
		add_child(btn_minus)

		var btn_plus := Button.new()
		btn_plus.text = "+"
		btn_plus.position = Vector2(x_offset + btn_w + 8, y)
		btn_plus.size = Vector2(btn_w, btn_h)
		btn_plus.add_theme_font_size_override("font_size", font_size)
		btn_plus.pressed.connect(row["plus"])
		add_child(btn_plus)

# ------------------------------------------------------------------ callbacks

func _add_coins() -> void:
	SaveManager.coins += 1000
	SaveManager.save_data()

func _sub_coins() -> void:
	SaveManager.coins -= 1000
	SaveManager.save_data()

func _add_vel() -> void:
	SaveManager.vel_level = mini(SaveManager.vel_level + 1, 5)
	SaveManager.save_data()

func _sub_vel() -> void:
	SaveManager.vel_level = maxi(SaveManager.vel_level - 1, 0)
	SaveManager.save_data()

func _add_cant() -> void:
	SaveManager.cant_level = mini(SaveManager.cant_level + 1, 3)
	SaveManager.save_data()

func _sub_cant() -> void:
	SaveManager.cant_level = maxi(SaveManager.cant_level - 1, 0)
	SaveManager.save_data()

func _add_hp() -> void:
	SaveManager.hp_level = mini(SaveManager.hp_level + 1, 3)
	SaveManager.save_data()

func _sub_hp() -> void:
	SaveManager.hp_level = maxi(SaveManager.hp_level - 1, 0)
	SaveManager.save_data()

func _toggle_revive() -> void:
	SaveManager.has_revive = not SaveManager.has_revive
	SaveManager.save_data()

func _toggle_helper() -> void:
	SaveManager.has_helper = not SaveManager.has_helper
	SaveManager.save_data()
