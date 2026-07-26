class_name Shop
extends Control

const MAX_VEL_LEVEL  := 5
const MAX_CANT_LEVEL := 3
const MAX_HP_LEVEL   := 3
const REVIVE_COST    := 100

## Costos fijos por nivel de corazón (índice = nivel a comprar, 0-indexed)
const HP_COSTS: Array[int] = [10, 20, 50]

## Modo dev: las compras son gratis. Cambiar a false para producción.
const DEV_MODE := true

var coins: int = 0
var vel_level: int = 0
var vel_purchases: int = 0
var cant_level: int = 0
var cant_purchases: int = 0
var hp_level: int = 0
var has_revive: bool = false

@onready var _vel_bar: ProgressBar    = $VBoxContainer/VelRow/VelBar
@onready var _vel_level_label: Label  = $VBoxContainer/VelRow/VelLevelLabel
@onready var _vel_cost_label: Label   = $VBoxContainer/VelRow/VelCostLabel
@onready var _btn_buy_vel: Button     = $VBoxContainer/VelRow/BtnBuyVel
@onready var _cant_bar: ProgressBar   = $VBoxContainer/CantRow/CantBar
@onready var _cant_level_label: Label = $VBoxContainer/CantRow/CantLevelLabel
@onready var _cant_cost_label: Label  = $VBoxContainer/CantRow/CantCostLabel
@onready var _btn_buy_cant: Button    = $VBoxContainer/CantRow/BtnBuyCant
@onready var _hp_bar: ProgressBar     = $VBoxContainer/HpRow/HpBar
@onready var _hp_level_label: Label   = $VBoxContainer/HpRow/HpLevelLabel
@onready var _hp_cost_label: Label    = $VBoxContainer/HpRow/HpCostLabel
@onready var _btn_buy_hp: Button      = $VBoxContainer/HpRow/BtnBuyHp
@onready var _revive_cost_label: Label = $VBoxContainer/ReviveRow/ReviveCostLabel
@onready var _btn_buy_revive: Button   = $VBoxContainer/ReviveRow/BtnBuyRevive
@onready var _coins_label: Label      = $VBoxContainer/CoinsLabel
@onready var _btn_back: Button        = $VBoxContainer/BtnBack
@onready var _dev_panel: Control      = $VBoxContainer/DevPanel
@onready var _btn_dev_max: Button     = $VBoxContainer/DevPanel/BtnDevMax
@onready var _btn_dev_reset: Button   = $VBoxContainer/DevPanel/BtnDevReset
@onready var _dev_label: Label        = $VBoxContainer/DevPanel/DevLabel

func _ready() -> void:
	_btn_buy_vel.pressed.connect(_on_buy_vel)
	_btn_buy_cant.pressed.connect(_on_buy_cant)
	_btn_buy_hp.pressed.connect(_on_buy_hp)
	_btn_buy_revive.pressed.connect(_on_buy_revive)
	_btn_back.pressed.connect(_on_back)
	_btn_dev_max.pressed.connect(_on_dev_max)
	_btn_dev_reset.pressed.connect(_on_dev_reset)
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

func _on_back() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/ChaosMainMenu.tscn")

# ------------------------------------------------------------------ dev mode

func _on_dev_max() -> void:
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
	_vel_bar.value         = vel_level
	_vel_level_label.text  = str(vel_level)  + "/" + str(MAX_VEL_LEVEL)
	_cant_bar.value        = cant_level
	_cant_level_label.text = str(cant_level) + "/" + str(MAX_CANT_LEVEL)
	_hp_bar.value          = hp_level
	_hp_level_label.text   = str(hp_level)   + "/" + str(MAX_HP_LEVEL)
	_coins_label.text      = "$ " + str(coins) + (" [DEV]" if DEV_MODE else "")

	var vel_cost  := _get_cost(vel_level)
	var cant_cost := _get_cost(cant_level)
	var hp_cost   := _get_hp_cost()

	_vel_cost_label.text  = "(GRATIS)" if DEV_MODE else "($" + str(vel_cost)  + ")"
	_cant_cost_label.text = "(GRATIS)" if DEV_MODE else "($" + str(cant_cost) + ")"
	_hp_cost_label.text   = "(GRATIS)" if DEV_MODE else ("($" + str(hp_cost) + ")" if hp_level < MAX_HP_LEVEL else "(MAX)")

	_btn_buy_vel.disabled  = vel_level  >= MAX_VEL_LEVEL
	_btn_buy_cant.disabled = cant_level >= MAX_CANT_LEVEL
	_btn_buy_hp.disabled   = hp_level   >= MAX_HP_LEVEL
	var revive_cost := 0 if DEV_MODE else REVIVE_COST
	_revive_cost_label.text = "(GRATIS)" if DEV_MODE else ("($" + str(REVIVE_COST) + ")" if not has_revive else "(COMPRADO)")
	_btn_buy_revive.disabled = has_revive or (not DEV_MODE and coins < REVIVE_COST)

	if DEV_MODE and _dev_label:
		_dev_label.text = "Vel: x" + str(vel_level) + "  Cant: x" + str(cant_level) + "  HP: x" + str(hp_level) + "  Rev:" + ("SI" if has_revive else "NO")

# ------------------------------------------------------------------ persistencia

func _save_data() -> void:
	SaveManager.coins          = coins
	SaveManager.vel_level      = vel_level
	SaveManager.vel_purchases  = vel_purchases
	SaveManager.cant_level     = cant_level
	SaveManager.cant_purchases = cant_purchases
	SaveManager.hp_level       = hp_level
	SaveManager.has_revive     = has_revive
	SaveManager.save_data()

func _load_data() -> void:
	coins          = SaveManager.coins
	vel_level      = SaveManager.vel_level
	vel_purchases  = SaveManager.vel_purchases
	cant_level     = SaveManager.cant_level
	cant_purchases = SaveManager.cant_purchases
	hp_level       = SaveManager.hp_level
	has_revive     = SaveManager.has_revive
