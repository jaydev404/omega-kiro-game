class_name Shop
extends Node2D

const MAX_VEL_LEVEL  := 5
const MAX_CANT_LEVEL := 3
const MAX_HP_LEVEL   := 3
const REVIVE_COST    := 100
const HELPER_COST    := 300

## Costos fijos por nivel de corazón (índice = nivel a comprar, 0-indexed)
const HP_COSTS: Array[int] = [10, 20, 50]

## Modo dev: las compras son gratis. Cambiar a false para producción.
const DEV_MODE := false

var coins: int = 0
var vel_level: int = 0
var vel_purchases: int = 0
var cant_level: int = 0
var cant_purchases: int = 0
var hp_level: int = 0
var has_revive: bool = false
var has_helper: bool = false

@onready var _vel_bar: ColorRect       = get_node_or_null("VelRow/VelFill")
@onready var _vel_level_label: Label  = get_node_or_null("VelRow/VelLevelLabel")
@onready var _vel_cost_label: Label   = get_node_or_null("VelRow/VelCostLabel")
@onready var _btn_buy_vel: Button     = get_node_or_null("VelRow/BtnBuyVel")
@onready var _cant_bar: ColorRect     = get_node_or_null("CantRow/CantFill")
@onready var _cant_level_label: Label = get_node_or_null("CantRow/CantLevelLabel")
@onready var _cant_cost_label: Label  = get_node_or_null("CantRow/CantCostLabel")
@onready var _btn_buy_cant: Button    = get_node_or_null("CantRow/BtnBuyCant")
@onready var _hp_bar: ColorRect       = get_node_or_null("HpRow/HpFill")
@onready var _hp_level_label: Label   = get_node_or_null("HpRow/HpLevelLabel")
@onready var _hp_cost_label: Label    = get_node_or_null("HpRow/HpCostLabel")
@onready var _btn_buy_hp: Button      = get_node_or_null("HpRow/BtnBuyHp")
@onready var _revive_cost_label: Label = get_node_or_null("ReviveRow/ReviveCostLabel")
@onready var _btn_buy_revive: Button   = get_node_or_null("ReviveRow/BtnBuyRevive")
@onready var _helper_cost_label: Label = get_node_or_null("HelperRow/HelperCostLabel")
@onready var _btn_buy_helper: Button   = get_node_or_null("HelperRow/BtnBuyHelper")
@onready var _coins_label: Label      = get_node_or_null("CoinsLabel")
@onready var _btn_back: Button        = get_node_or_null("BtnBack")
@onready var _dev_panel: Control      = get_node_or_null("DevPanel")
@onready var _btn_dev_max: Button     = get_node_or_null("DevPanel/BtnDevMax")
@onready var _btn_dev_reset: Button   = get_node_or_null("DevPanel/BtnDevReset")
@onready var _dev_label: Label        = $VBoxContainer/DevPanel/DevLabel

func _ready() -> void:
	if _btn_buy_vel:
		_btn_buy_vel.pressed.connect(_on_buy_vel)
	if _btn_buy_cant:
		_btn_buy_cant.pressed.connect(_on_buy_cant)
	if _btn_buy_hp:
		_btn_buy_hp.pressed.connect(_on_buy_hp)
	if _btn_buy_revive:
		_btn_buy_revive.pressed.connect(_on_buy_revive)
	if _btn_buy_helper:
		_btn_buy_helper.pressed.connect(_on_buy_helper)
	if _btn_back:
		_btn_back.pressed.connect(_on_back)
	if _btn_dev_max:
		_btn_dev_max.pressed.connect(_on_dev_max)
	if _btn_dev_reset:
		_btn_dev_reset.pressed.connect(_on_dev_reset)
	if _dev_panel:
		_dev_panel.visible = DEV_MODE
	_load_data()
	_update_ui()

# ------------------------------------------------------------------ costos

## Costo por nivel de vel/cant usando fórmula escalada. Gratis en dev.
func _get_cost(level: int) -> int:
	if DEV_MODE:
		return 0
	const BASE_COST := 10
	var cost := BASE_COST
	for i in range(level):
		cost = cost + cost / 2
	return cost

## Costo del siguiente nivel de corazón. Gratis en dev.
func _get_hp_cost() -> int:
	if DEV_MODE:
		return 0
	if hp_level >= MAX_HP_LEVEL:
		return 0
	return HP_COSTS[hp_level]

func _purchases_needed_for_vel_level(level: int) -> int:
	return 1

func _purchases_needed_for_cant_level(level: int) -> int:
	return 2

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
	if coins >= cost and vel_level < MAX_VEL_LEVEL:
		coins -= cost
		vel_purchases += 1
		if _purchases_in_current_vel_level() >= _purchases_needed_for_vel_level(vel_level):
			vel_level += 1
		_save_data()
		_update_ui()

func _on_buy_cant() -> void:
	var cost := _get_cost(cant_level)
	if coins >= cost and cant_level < MAX_CANT_LEVEL:
		coins -= cost
		cant_purchases += 1
		if _purchases_in_current_cant_level() >= _purchases_needed_for_cant_level(cant_level):
			cant_level += 1
		_save_data()
		_update_ui()

func _on_buy_hp() -> void:
	var cost := _get_hp_cost()
	if coins >= cost and hp_level < MAX_HP_LEVEL:
		coins -= cost
		hp_level += 1
		_save_data()
		_update_ui()

func _on_buy_revive() -> void:
	var cost := 0 if DEV_MODE else REVIVE_COST
	if coins >= cost and not has_revive:
		coins -= cost
		has_revive = true
		_save_data()
		_update_ui()

func _on_buy_helper() -> void:
	var cost := 0 if DEV_MODE else HELPER_COST
	if coins >= cost and not has_helper:
		coins -= cost
		has_helper = true
		_save_data()
		_update_ui()

func _on_back() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/ChaosMainMenu.tscn")
# ------------------------------------------------------------------ dev mode

func _on_dev_max() -> void:
	coins          = 99999999
	vel_level      = MAX_VEL_LEVEL
	vel_purchases  = _total_purchases_for_level(MAX_VEL_LEVEL, true)
	cant_level     = MAX_CANT_LEVEL
	cant_purchases = _total_purchases_for_level(MAX_CANT_LEVEL, false)
	hp_level       = MAX_HP_LEVEL
	has_revive     = true
	_save_data()
	_update_ui()

func _on_dev_reset() -> void:
	SaveManager.reset_all()
	_load_data()
	_update_ui()

func _total_purchases_for_level(target_level: int, is_vel: bool) -> int:
	var total := 0
	for lvl in range(target_level):
		total += _purchases_needed_for_vel_level(lvl) if is_vel else _purchases_needed_for_cant_level(lvl)
	return total

# ------------------------------------------------------------------ UI

func _update_ui() -> void:
	if _vel_bar:
		var vel_max_width := 58.0
		_vel_bar.offset_right = _vel_bar.offset_left + vel_max_width * (float(vel_level) / MAX_VEL_LEVEL)
	if _vel_level_label:
		_vel_level_label.text  = str(vel_level)  + "/" + str(MAX_VEL_LEVEL)
	if _cant_bar:
		var cant_max_width := 58.0
		_cant_bar.offset_right = _cant_bar.offset_left + cant_max_width * (float(cant_level) / MAX_CANT_LEVEL)
	if _cant_level_label:
		_cant_level_label.text = str(cant_level) + "/" + str(MAX_CANT_LEVEL)
	if _hp_bar:
		var hp_max_width := 58.0
		_hp_bar.offset_right = _hp_bar.offset_left + hp_max_width * (float(hp_level) / MAX_HP_LEVEL)
	if _hp_level_label:
		_hp_level_label.text   = str(hp_level)   + "/" + str(MAX_HP_LEVEL)
	if _coins_label:
		_coins_label.text      = "monedas: " + str(coins)

	var vel_cost  := _get_cost(vel_level)
	var cant_cost := _get_cost(cant_level)
	var hp_cost   := _get_hp_cost()

	if _vel_cost_label:
		_vel_cost_label.visible = false
	if _cant_cost_label:
		_cant_cost_label.visible = false
	if _hp_cost_label:
		_hp_cost_label.visible = false

	if _btn_buy_vel:
		if vel_level >= MAX_VEL_LEVEL:
			_btn_buy_vel.text = "MAX"
			_btn_buy_vel.disabled = true
		else:
			_btn_buy_vel.text = "+" + str(vel_cost)
			_btn_buy_vel.disabled = coins < vel_cost
	if _btn_buy_cant:
		if cant_level >= MAX_CANT_LEVEL:
			_btn_buy_cant.text = "MAX"
			_btn_buy_cant.disabled = true
		else:
			_btn_buy_cant.text = "+" + str(cant_cost)
			_btn_buy_cant.disabled = coins < cant_cost
	if _btn_buy_hp:
		if hp_level >= MAX_HP_LEVEL:
			_btn_buy_hp.text = "MAX"
			_btn_buy_hp.disabled = true
		else:
			_btn_buy_hp.text = "+" + str(hp_cost)
			_btn_buy_hp.disabled = coins < hp_cost
	if _revive_cost_label:
		_revive_cost_label.visible = false
	if _btn_buy_revive:
		if has_revive:
			_btn_buy_revive.text = "Comprado"
			_btn_buy_revive.disabled = true
		else:
			_btn_buy_revive.text = "+" + str(REVIVE_COST)
			_btn_buy_revive.disabled = coins < REVIVE_COST
	if _helper_cost_label:
		_helper_cost_label.visible = false
	if _btn_buy_helper:
		if has_helper:
			_btn_buy_helper.text = "Comprado"
			_btn_buy_helper.disabled = true
		else:
			_btn_buy_helper.text = "+" + str(HELPER_COST)
			_btn_buy_helper.disabled = coins < HELPER_COST

# ------------------------------------------------------------------ persistencia

func _save_data() -> void:
	SaveManager.coins          = coins
	SaveManager.vel_level      = vel_level
	SaveManager.vel_purchases  = vel_purchases
	SaveManager.cant_level     = cant_level
	SaveManager.cant_purchases = cant_purchases
	SaveManager.hp_level       = hp_level
	SaveManager.has_revive     = has_revive
	SaveManager.has_helper     = has_helper
	SaveManager.save_data()

func _load_data() -> void:
	coins          = SaveManager.coins
	vel_level      = SaveManager.vel_level
	vel_purchases  = SaveManager.vel_purchases
	cant_level     = SaveManager.cant_level
	cant_purchases = SaveManager.cant_purchases
	hp_level       = SaveManager.hp_level
	has_revive     = SaveManager.has_revive
	has_helper     = SaveManager.has_helper
