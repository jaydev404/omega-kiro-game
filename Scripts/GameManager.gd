class_name GameManager
extends Node

## Señales
signal score_changed(new_score: int)
signal bomb_chance_changed(new_chance: float)

## Puntaje
var score: int = 0
var _next_ruby_at: int = 5  ## Siguiente puntaje donde aparece un ruby

## Referencia al spawner para modificar bomb_chance
@onready var _spawner: DroneSpawner = get_node_or_null("../DroneSpawner")
@onready var _score_label: Label = $ScoreLabel
@onready var _drone_count_label: Label = $DroneHUD/DroneCountLabel
@onready var _vel_label: Label = $PlayerStatsHUD/VelLabel
@onready var _cant_label: Label = $PlayerStatsHUD/CantLabel
@onready var _player: PlayerController = get_node_or_null("../Player") as PlayerController
@onready var _power_menu: Control = $PowerUpMenu
@onready var _btn_vel: Button = $PowerUpMenu/VBoxContainer/BtnVel
@onready var _btn_cant: Button = $PowerUpMenu/VBoxContainer/BtnCant
@onready var _btn_shield: Button = $PowerUpMenu/VBoxContainer/BtnShield
@onready var _game_over_menu: Control = $GameOverMenu
@onready var _game_over_score: Label = $GameOverMenu/VBoxContainer/FinalScore
@onready var _btn_restart: Button = $GameOverMenu/VBoxContainer/BtnRestart

func _ready() -> void:
	# Conectar las señales de entrega de ambos camiones
	var scene := get_tree().current_scene
	for child in scene.get_children():
		if child.name.begins_with("DeliveryTruck"):
			var zone := child.get_node_or_null("DeliveryZone")
			if zone and zone is DeliveryZone:
				zone.package_delivered.connect(_on_delivery)

	# Conectar señal de ruby del player
	var interaction := _player.get_node_or_null("PlayerInteraction") as PlayerInteraction
	if interaction:
		interaction.ruby_collected.connect(_on_ruby_collected)

	_btn_vel.pressed.connect(_on_power_vel)
	_btn_cant.pressed.connect(_on_power_cant)
	_btn_shield.pressed.connect(_on_power_shield)
	_btn_restart.pressed.connect(_on_restart)

	_power_menu.visible = false
	_game_over_menu.visible = false
	_update_label()

func _on_delivery(_count: int) -> void:
	score += 1
	emit_signal("score_changed", score)

	# Aumentar bomb_chance en 1% por cada entrega (máximo 50%)
	if _spawner:
		_spawner.bomb_chance = min(0.5, _spawner.bomb_chance + 0.01)
		emit_signal("bomb_chance_changed", _spawner.bomb_chance)

	# Cada 2 puntos, aumentar en 1 los drones que aparecen por oleada
	if _spawner and score % 2 == 0:
		_spawner._max_concurrent_drones += 1

	# Ruby aparece solo al alcanzar el siguiente umbral (no cuenta puntos recuperados)
	if _spawner and score >= _next_ruby_at:
		_spawner.queue_ruby()
		_next_ruby_at += 5

	_update_label()

func _on_ruby_collected(ruby: PackageBody) -> void:
	# Destruir el ruby
	ruby.queue_free()
	# Pausar el juego y mostrar menú
	get_tree().paused = true
	_power_menu.visible = true

func _on_power_vel() -> void:
	if _player:
		_player.move_speed += 30.0
	_close_menu()

func _on_power_cant() -> void:
	if _player:
		_player.max_carry += 1
	_close_menu()

func _on_power_shield() -> void:
	if _player:
		_player.has_shield = true
	_close_menu()

func _close_menu() -> void:
	_power_menu.visible = false
	get_tree().paused = false
	_update_label()

func _update_label() -> void:
	if _score_label:
		_score_label.text = "Puntaje: " + str(score)
	if _drone_count_label and _spawner:
		_drone_count_label.text = "x" + str(_spawner._max_concurrent_drones)
	if _vel_label and _player:
		_vel_label.text = "Vel: " + str(int(_player.move_speed))
	if _cant_label and _player:
		_cant_label.text = "Cant: " + str(_player.max_carry)

func game_over() -> void:
	get_tree().paused = true
	_game_over_score.text = "Puntaje final: " + str(score)
	_game_over_menu.visible = true

func lose_points(amount: int) -> void:
	score = max(0, score - amount)
	emit_signal("score_changed", score)
	_update_label()

func _on_restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
