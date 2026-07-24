class_name Shop
extends Control

const BASE_COST := 10  ## Costo inicial de mejora
const MAX_LEVEL := 10

var coins: int = 0
var vel_level: int = 0
var vel_purchases: int = 0  ## Compras acumuladas para vel
var cant_level: int = 0
var cant_purchases: int = 0  ## Compras acumuladas para cant

@onready var _vel_bar: ProgressBar = $VBoxContainer/VelRow/VelBar
@onready var _vel_level_label: Label = $VBoxContainer/VelRow/VelLevelLabel
@onready var _vel_cost_label: Label = $VBoxContainer/VelRow/VelCostLabel
@onready var _btn_buy_vel: Button = $VBoxContainer/VelRow/BtnBuyVel
@onready var _cant_bar: ProgressBar = $VBoxContainer/CantRow/CantBar
@onready var _cant_level_label: Label = $VBoxContainer/CantRow/CantLevelLabel
@onready var _cant_cost_label: Label = $VBoxContainer/CantRow/CantCostLabel
@onready var _btn_buy_cant: Button = $VBoxContainer/CantRow/BtnBuyCant
@onready var _coins_label: Label = $VBoxContainer/CoinsLabel
@onready var _btn_back: Button = $VBoxContainer/BtnBack

func _ready() -> void:
	_btn_buy_vel.pressed.connect(_on_buy_vel)
	_btn_buy_cant.pressed.connect(_on_buy_cant)
	_btn_back.pressed.connect(_on_back)
	_load_data()
	_update_ui()

## Calcula el costo actual basado en el nivel completado.
## El costo solo sube cuando se completa un nivel entero.
func _get_cost(level: int) -> int:
	var cost := BASE_COST
	for i in range(level):
		cost = cost + cost / 2
	return cost

## Cuántas compras necesita para subir un nivel de cant.
## Niveles 1-5: 2 compras por nivel. Niveles 6-10: 3 compras por nivel.
func _purchases_needed_for_cant_level(level: int) -> int:
	if level < 5:
		return 2
	else:
		return 3

## Cuántas compras necesita para subir un nivel de vel (misma lógica que cant).
func _purchases_needed_for_vel_level(level: int) -> int:
	if level < 5:
		return 2
	else:
		return 3

## Compras dentro del nivel actual (cuántas lleva de las necesarias).
func _purchases_in_current_vel_level() -> int:
	var spent := 0
	for lvl in range(vel_level):
		spent += _purchases_needed_for_vel_level(lvl)
	return vel_purchases - spent

func _purchases_in_current_cant_level() -> int:
	var spent := 0
	for lvl in range(cant_level):
		spent += _purchases_needed_for_cant_level(lvl)
	return cant_purchases - spent

func _on_buy_vel() -> void:
	var cost := _get_cost(vel_level)
	if coins >= cost and vel_level < MAX_LEVEL:
		coins -= cost
		vel_purchases += 1
		# Verificar si sube de nivel
		var needed := _purchases_needed_for_vel_level(vel_level)
		if _purchases_in_current_vel_level() >= needed:
			vel_level += 1
		_save_data()
		_update_ui()

func _on_buy_cant() -> void:
	var cost := _get_cost(cant_level)
	if coins >= cost and cant_level < MAX_LEVEL:
		coins -= cost
		cant_purchases += 1
		# Verificar si sube de nivel
		var needed := _purchases_needed_for_cant_level(cant_level)
		if _purchases_in_current_cant_level() >= needed:
			cant_level += 1
		_save_data()
		_update_ui()

func _on_back() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")

func _update_ui() -> void:
	_vel_bar.value = vel_level
	_vel_level_label.text = str(vel_level) + "/" + str(MAX_LEVEL)
	_cant_bar.value = cant_level
	_cant_level_label.text = str(cant_level) + "/" + str(MAX_LEVEL)
	_coins_label.text = "$ " + str(coins)

	var vel_cost := _get_cost(vel_level)
	var cant_cost := _get_cost(cant_level)

	_vel_cost_label.text = "($" + str(vel_cost) + ")"
	_cant_cost_label.text = "($" + str(cant_cost) + ")"

	_btn_buy_vel.disabled = coins < vel_cost or vel_level >= MAX_LEVEL
	_btn_buy_cant.disabled = coins < cant_cost or cant_level >= MAX_LEVEL

func _save_data() -> void:
	var file := FileAccess.open("user://coins.save", FileAccess.WRITE)
	if file:
		file.store_32(coins)
		file.close()

	var upgrades := FileAccess.open("user://upgrades.save", FileAccess.WRITE)
	if upgrades:
		upgrades.store_32(vel_level)
		upgrades.store_32(cant_level)
		upgrades.store_32(vel_purchases)
		upgrades.store_32(cant_purchases)
		upgrades.close()

func _load_data() -> void:
	if FileAccess.file_exists("user://coins.save"):
		var file := FileAccess.open("user://coins.save", FileAccess.READ)
		if file:
			coins = file.get_32()
			file.close()

	if FileAccess.file_exists("user://upgrades.save"):
		var upgrades := FileAccess.open("user://upgrades.save", FileAccess.READ)
		if upgrades:
			vel_level = upgrades.get_32()
			cant_level = upgrades.get_32()
			vel_purchases = upgrades.get_32()
			cant_purchases = upgrades.get_32()
			upgrades.close()
