class_name GameManager
extends Node

## Señales
signal score_changed(new_score: int)
signal bomb_chance_changed(new_chance: float)

## Puntaje
var score: int = 0
var _next_ruby_at: int = 5  ## Siguiente puntaje donde aparece un ruby
var coins: int = 0  ## Dinero acumulado (persistente entre partidas)
var _coins_this_run: int = 0  ## Monedas ganadas en esta partida (se guardan solo al perder)

## Referencia al spawner para modificar bomb_chance
@onready var _spawner: DroneSpawner = get_node_or_null("../DroneSpawner")
@onready var _score_label: Label = $ScoreLabel
@onready var _drone_count_label: Label = $DroneHUD/DroneCountLabel
@onready var _vel_label: Label = $PlayerStatsHUD/VelLabel
@onready var _cant_label: Label = $PlayerStatsHUD/CantLabel
@onready var _player: PlayerController = get_node_or_null("../Player") as PlayerController
@onready var _coins_label: Label = $CoinsHUD/CoinsLabel
@onready var _power_menu: Control = $PowerUpMenu
@onready var _btn_vel: Button = $PowerUpMenu/VBoxContainer/BtnVel
@onready var _btn_cant: Button = $PowerUpMenu/VBoxContainer/BtnCant
@onready var _btn_shield: Button = $PowerUpMenu/VBoxContainer/BtnShield
@onready var _game_over_menu: Control = $GameOverMenu
@onready var _game_over_score: Label = $GameOverMenu/VBoxContainer/FinalScore
@onready var _btn_restart: Button = $GameOverMenu/VBoxContainer/BtnRestart
@onready var _btn_go_menu: Button = $GameOverMenu/VBoxContainer/BtnGoMenu
@onready var _btn_quit_game: Button = $GameOverMenu/VBoxContainer/BtnQuitGame
@onready var _pause_menu: Control = $PauseMenu
@onready var _btn_resume: Button = $PauseMenu/VBoxContainer/BtnResume
@onready var _btn_main_menu: Button = $PauseMenu/VBoxContainer/BtnMainMenu
@onready var _btn_quit: Button = $PauseMenu/VBoxContainer/BtnQuit

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
	_btn_go_menu.pressed.connect(_on_gameover_main_menu)
	_btn_quit_game.pressed.connect(_on_quit)
	_btn_resume.pressed.connect(_on_resume)
	_btn_main_menu.pressed.connect(_on_main_menu)
	_btn_quit.pressed.connect(_on_quit)

	_power_menu.visible = false
	_game_over_menu.visible = false
	_pause_menu.visible = false
	_load_coins()
	_load_upgrades()
	_update_label()

func _on_delivery(_count: int) -> void:
	score += 1
	emit_signal("score_changed", score)

	# Aumentar bomb_chance en 1% por cada entrega (máximo 50%)
	if _spawner:
		_spawner.bomb_chance = min(0.5, _spawner.bomb_chance + 0.01)
		emit_signal("bomb_chance_changed", _spawner.bomb_chance)

	# Cada 3 puntos, aumentar en 1 los drones que aparecen por oleada
	if _spawner and score % 3 == 0:
		_spawner._max_concurrent_drones += 1

	# Ruby aparece solo al alcanzar el siguiente umbral (no cuenta puntos recuperados)
	if _spawner and score >= _next_ruby_at:
		_spawner.queue_ruby()
		_next_ruby_at += 5

	_update_label()

func _on_ruby_collected(item: PackageBody) -> void:
	var item_type := item.package_type
	item.queue_free()

	if item_type == PackageBody.PackageType.GOLD_COIN:
		_coins_this_run += 5
		_update_label()
	elif item_type == PackageBody.PackageType.SILVER_COIN:
		_coins_this_run += 1
		_update_label()
	elif item_type == PackageBody.PackageType.RUBY:
		# Pausar el juego y mostrar menú de power-up
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
	if _coins_label:
		_coins_label.text = str(coins + _coins_this_run)

func game_over() -> void:
	get_tree().paused = true
	# Al perder, se acumulan las monedas de esta partida
	coins += _coins_this_run
	_save_coins()
	_game_over_score.text = "Puntaje final: " + str(score)
	_game_over_menu.visible = true

func lose_points(amount: int) -> void:
	score = max(0, score - amount)
	emit_signal("score_changed", score)
	_update_label()

func _on_restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_gameover_main_menu() -> void:
	# Al perder las monedas ya se guardaron en game_over()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if _game_over_menu.visible or _power_menu.visible:
			return  # No pausar si hay otro menú abierto
		if get_tree().paused:
			_on_resume()
		else:
			_pause_game()

func _pause_game() -> void:
	get_tree().paused = true
	_pause_menu.visible = true

func _on_resume() -> void:
	_pause_menu.visible = false
	get_tree().paused = false

func _on_main_menu() -> void:
	# No guardar monedas de esta partida al volver al menú
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")

func _on_quit() -> void:
	get_tree().quit()

## Guarda las monedas en un archivo para persistir entre partidas.
func _save_coins() -> void:
	var file := FileAccess.open("user://coins.save", FileAccess.WRITE)
	if file:
		file.store_32(coins)
		file.close()

## Carga las monedas guardadas.
func _load_coins() -> void:
	if FileAccess.file_exists("user://coins.save"):
		var file := FileAccess.open("user://coins.save", FileAccess.READ)
		if file:
			coins = file.get_32()
			file.close()

## Carga los upgrades de la tienda y los aplica al player.
func _load_upgrades() -> void:
	if FileAccess.file_exists("user://upgrades.save"):
		var upgrades := FileAccess.open("user://upgrades.save", FileAccess.READ)
		if upgrades:
			var vel_level: int = upgrades.get_32()
			var cant_level: int = upgrades.get_32()
			# vel_purchases y cant_purchases también se guardan pero no los necesitamos aquí
			upgrades.close()
			if _player:
				_player.move_speed += vel_level * 15.0  # cada nivel de tienda = +15 vel
				_player.max_carry += cant_level          # cada nivel = +1 carry
