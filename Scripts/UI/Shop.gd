class_name Shop
extends Control

const BASE_COST := 10
const MAX_LEVEL := 10

var coins: int = 0
var vel_level: int = 0
var vel_purchases: int = 0
var cant_level: int = 0
var cant_purchases: int = 0

@onready var _vel_bar: ProgressBar    = $VBoxContainer/VelRow/VelBar
@onready var _vel_level_label: Label  = $VBoxContainer/VelRow/VelLevelLabel
@onready var _vel_cost_label: Label   = $VBoxContainer/VelRow/VelCostLabel
@onready var _btn_buy_vel: Button     = $VBoxContainer/VelRow/BtnBuyVel
@onready var _cant_bar: ProgressBar   = $VBoxContainer/CantRow/CantBar
@onready var _cant_level_label: Label = $VBoxContainer/CantRow/CantLevelLabel
@onready var _cant_cost_label: Label  = $VBoxContainer/CantRow/CantCostLabel
@onready var _btn_buy_cant: Button    = $VBoxContainer/CantRow/BtnBuyCant
@onready var _coins_label: Label      = $VBoxContainer/CoinsLabel
@onready var _btn_back: Button        = $VBoxContainer/BtnBack

func _ready() -> void:
	_btn_buy_vel.pressed.connect(_on_buy_vel)
	_btn_buy_cant.pressed.connect(_on_buy_cant)
	_btn_back.pressed.connect(_on_back)
	_load_data()
	_update_ui()

# ------------------------------------------------------------------ costos

## Costo actual basado en el nivel. Sube solo al completar un nivel.
func _get_cost(level: int) -> int:
	var cost := BASE_COST
	for i in range(level):
		cost = cost + cost / 2
	return cost

## Compras necesarias para subir un nivel. Niveles 1-5: 2. Niveles 6-10: 3.
func _purchases_needed_for_vel_level(level: int) -> int:
	return 2 if level < 5 else 3

func _purchases_needed_for_cant_level(level: int) -> int:
	return 2 if level < 5 else 3

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

# ------------------------------------------------------------------ compras

func _on_buy_vel() -> void:
	var cost := _get_cost(vel_level)
	if coins >= cost and vel_level < MAX_LEVEL:
		coins -= cost
		vel_purchases += 1
		if _purchases_in_current_vel_level() >= _purchases_needed_for_vel_level(vel_level):
			vel_level += 1
		_save_data()
		_update_ui()

func _on_buy_cant() -> void:
	var cost := _get_cost(cant_level)
	if coins >= cost and cant_level < MAX_LEVEL:
		coins -= cost
		cant_purchases += 1
		if _purchases_in_current_cant_level() >= _purchases_needed_for_cant_level(cant_level):
			cant_level += 1
		_save_data()
		_update_ui()

func _on_back() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")

# ------------------------------------------------------------------ UI

func _update_ui() -> void:
	_vel_bar.value         = vel_level
	_vel_level_label.text  = str(vel_level)  + "/" + str(MAX_LEVEL)
	_cant_bar.value        = cant_level
	_cant_level_label.text = str(cant_level) + "/" + str(MAX_LEVEL)
	_coins_label.text      = "$ " + str(coins)

	var vel_cost  := _get_cost(vel_level)
	var cant_cost := _get_cost(cant_level)
	_vel_cost_label.text  = "($" + str(vel_cost)  + ")"
	_cant_cost_label.text = "($" + str(cant_cost) + ")"

	_btn_buy_vel.disabled  = coins < vel_cost  or vel_level  >= MAX_LEVEL
	_btn_buy_cant.disabled = coins < cant_cost or cant_level >= MAX_LEVEL

# ------------------------------------------------------------------ persistencia (via SaveManager)

func _save_data() -> void:
	SaveManager.coins          = coins
	SaveManager.vel_level      = vel_level
	SaveManager.vel_purchases  = vel_purchases
	SaveManager.cant_level     = cant_level
	SaveManager.cant_purchases = cant_purchases
	SaveManager.save_data()

func _load_data() -> void:
	coins          = SaveManager.coins
	vel_level      = SaveManager.vel_level
	vel_purchases  = SaveManager.vel_purchases
	cant_level     = SaveManager.cant_level
	cant_purchases = SaveManager.cant_purchases
