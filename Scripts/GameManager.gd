class_name GameManager
extends Node

## Señales
signal score_changed(new_score: int)
signal bomb_chance_changed(new_chance: float)
signal match_timer_updated(seconds_left: int)
signal match_ended()

## Config
@export var match_duration: float = 600.0   ## 10 minutos en segundos
@export var endgame_duration: float = 30.0  ## Últimos X segundos = bombardeo
@export var endgame_extra_drones: int = 10
@export var endgame_bomb_chance: float = 0.8
@export var endgame_spawn_interval: float = 0.3
@export var survival_bonus_coins: int = 10
@export var third_package_unlock_time: float = 360.0   ## Minuto 4 de 10 (600-240)
@export var helper_cat_scene: PackedScene  ## Escena del drone gato helper
@export var helper_cat_spawn_level: int = 1  ## Nivel al que aparece el helper

## Estados
enum GameState { PLAYING, ENDGAME, GAME_OVER }
var _state: GameState = GameState.PLAYING

## Timer de partida
var _match_timer: float = 0.0
var _elapsed_time: float = 0.0  ## tiempo transcurrido (sube desde 0)
var _endgame_triggered: bool = false
var _third_package_unlocked: bool = false
var _helper_cat_spawned: bool = false
var _difficulty_phase: int = 0  ## fase de dificultad activa

## Puntaje
var score: int = 0
var _next_ruby_at: int = 5  ## Siguiente puntaje donde aparece un ruby
var coins: int = 0  ## Dinero acumulado (persistente entre partidas)
var _coins_this_run: int = 0  ## Monedas ganadas en esta partida (se guardan solo al perder)

## Referencia al spawner para modificar bomb_chance
@onready var _spawner: DroneSpawner = get_node_or_null("../DroneSpawner")
@onready var _score_label: Label = get_node_or_null("ScoreLabel")
@onready var _drone_count_label: Label = get_node_or_null("DroneHUD/DroneCountLabel")
@onready var _vel_label: Label = get_node_or_null("PlayerStatsHUD/VelLabel")
@onready var _cant_label: Label = get_node_or_null("PlayerStatsHUD/CantLabel")
@onready var _player: PlayerController = get_node_or_null("../Player") as PlayerController
@onready var _coins_label: Label = get_node_or_null("../HUDPanel/CoinsLabel")
@onready var _hearts_label: Label = get_node_or_null("HealthHUD/HeartsLabel")
@onready var _power_menu: Control = get_node_or_null("PowerUpMenu")
@onready var _btn_vel: Button = get_node_or_null("PowerUpMenu/VBoxContainer/BtnVel")
@onready var _btn_cant: Button = get_node_or_null("PowerUpMenu/VBoxContainer/BtnCant")
@onready var _btn_shield: Button = get_node_or_null("PowerUpMenu/VBoxContainer/BtnShield")
@onready var _game_over_menu: Control = get_node_or_null("GameOverMenu")
@onready var _revive_menu: Control    = get_node_or_null("ReviveMenu")
@onready var _btn_revive: Button      = get_node_or_null("ReviveMenu/Panel/VBoxContainer/BtnRevive")
@onready var _btn_revive_menu: Button = get_node_or_null("ReviveMenu/Panel/VBoxContainer/BtnGoMenu")
@onready var _game_over_score: Label = get_node_or_null("GameOverMenu/Panel/VBoxContainer/FinalScore")
@onready var _game_over_coins_earned: Label = get_node_or_null("GameOverMenu/Panel/VBoxContainer/CoinsEarned")
@onready var _game_over_coins_total: Label  = get_node_or_null("GameOverMenu/Panel/VBoxContainer/CoinsTotal")
@onready var _btn_restart: Button = get_node_or_null("GameOverMenu/Panel/VBoxContainer/BtnRestart")
@onready var _btn_go_menu: Button = get_node_or_null("GameOverMenu/Panel/VBoxContainer/BtnGoMenu")
@onready var _btn_quit_game: Button = get_node_or_null("GameOverMenu/Panel/VBoxContainer/BtnQuitGame")
@onready var _pause_menu: Control = get_node_or_null("PauseMenu")
@onready var _btn_resume: Button = get_node_or_null("PauseMenu/Panel/VBoxContainer/BtnResume")
@onready var _btn_main_menu: Button = get_node_or_null("PauseMenu/Panel/VBoxContainer/BtnMainMenu")
@onready var _btn_quit: Button = get_node_or_null("PauseMenu/Panel/VBoxContainer/BtnQuit")

func _ready() -> void:
	# Conectar las señales de entrega de ambos camiones
	var scene := get_tree().current_scene
	for child in scene.get_children():
		if child.name.begins_with("DeliveryTruck"):
			var zone := child.get_node_or_null("DeliveryZone")
			if zone and zone is DeliveryZone:
				zone.package_delivered.connect(_on_delivery)

	# Conectar señal de ruby del player
	if _player:
		var interaction := _player.get_node_or_null("PlayerInteraction") as PlayerInteraction
		if interaction:
			interaction.ruby_collected.connect(_on_ruby_collected)
		var health := _player.get_node_or_null("PlayerHealth") as PlayerHealth
		if health:
			health.died.connect(_on_player_died)
			health.health_changed.connect(_on_health_changed)
		var xp := _player.get_node_or_null("PlayerXP") as PlayerXP
		if xp:
			xp.leveled_up.connect(_on_leveled_up)
			xp.xp_changed.connect(_on_xp_changed)

	if _btn_vel:
		_btn_vel.pressed.connect(_on_power_vel)
	if _btn_cant:
		_btn_cant.pressed.connect(_on_power_cant)
	if _btn_shield:
		_btn_shield.pressed.connect(_on_power_shield)
	if _btn_restart:
		_btn_restart.pressed.connect(_on_restart)
	if _btn_go_menu:
		_btn_go_menu.pressed.connect(_on_gameover_main_menu)
	if _btn_quit_game:
		_btn_quit_game.pressed.connect(_on_quit)
	if _btn_revive:
		_btn_revive.pressed.connect(_on_revive)
	if _btn_revive_menu:
		_btn_revive_menu.pressed.connect(_on_gameover_main_menu)
	if _btn_resume:
		_btn_resume.pressed.connect(_on_resume)
	if _btn_main_menu:
		_btn_main_menu.pressed.connect(_on_main_menu)
	if _btn_quit:
		_btn_quit.pressed.connect(_on_quit)

	if _power_menu:
		_power_menu.visible = false
	if _game_over_menu:
		_game_over_menu.visible = false
	if _revive_menu:
		_revive_menu.visible = false
	if _pause_menu:
		_pause_menu.visible = false
	_load_save()
	_match_timer = match_duration
	_elapsed_time = 0.0
	_update_label()

func _process(delta: float) -> void:
	if _state != GameState.PLAYING:
		return

	_match_timer -= delta
	_elapsed_time += delta
	emit_signal("match_timer_updated", int(_match_timer))

	# Actualizar label del timer — muestra tiempo transcurrido (00:00 → 25:00)
	var timer_label := get_node_or_null("TimerLabel") as Label
	if timer_label:
		var mins := int(_elapsed_time) / 60
		var secs := int(_elapsed_time) % 60
		timer_label.text = "%02d:%02d" % [mins, secs]

	# Tercer paquete se desbloquea al minuto 5
	if not _third_package_unlocked and _match_timer <= third_package_unlock_time:
		_third_package_unlocked = true
		if _spawner:
			_spawner.enable_third_package()

	# Curva de dificultad por tiempo
	_check_difficulty_phase()

	# Evento final: bombardeo masivo en los últimos 30 segundos
	if _match_timer <= endgame_duration and not _endgame_triggered:
		_endgame_triggered = true
		_start_endgame()

	# Fin de partida
	if _match_timer <= 0.0:
		_match_timer = 0.0
		_state = GameState.GAME_OVER
		_match_victory()

func _start_endgame() -> void:
	if _spawner:
		_spawner._max_concurrent_drones += endgame_extra_drones
		_spawner.bomb_chance = endgame_bomb_chance
		_spawner.spawn_interval = endgame_spawn_interval

func _match_victory() -> void:
	get_tree().paused = true
	coins += _coins_this_run
	coins += survival_bonus_coins
	_save_run()
	_show_summary("VICTORIA! Puntaje: " + str(score))
	if _game_over_menu:
		_game_over_menu.visible = true
	emit_signal("match_ended")

func _on_delivery(_count: int) -> void:
	score += 1
	emit_signal("score_changed", score)

	# Dar XP al player
	if _player:
		var xp := _player.get_node_or_null("PlayerXP") as PlayerXP
		if xp:
			xp.add_xp(xp.xp_per_delivery)

	# Aumentar bomb_chance en 1% por cada entrega (máximo 50%)
	if _spawner:
		_spawner.bomb_chance = min(0.5, _spawner.bomb_chance + 0.01)
		emit_signal("bomb_chance_changed", _spawner.bomb_chance)

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
		if _power_menu:
			_power_menu.visible = true

func _on_power_vel() -> void:
	if _player:
		_player.move_speed += 5.0
	if _spawner:
		_spawner.on_player_vel_powerup()
	_close_menu()

func _on_power_cant() -> void:
	if _player:
		_player.max_carry += 1
	if _spawner:
		_spawner.on_player_cant_powerup()
	_close_menu()

func _on_power_shield() -> void:
	if _player:
		_player.shield_count += 1
	_update_shield_icon()
	_close_menu()

func _close_menu() -> void:
	if _power_menu:
		_power_menu.visible = false
	get_tree().paused = false
	_update_label()

func _update_label() -> void:
	if _score_label:
		_score_label.text = "Puntaje: " + str(score)
	if _drone_count_label and _spawner:
		_drone_count_label.text = "x" + str(_spawner.get_max_drones())
	if _vel_label and _player:
		_vel_label.text = "Vel: " + str(int(_player.move_speed))
	if _cant_label and _player:
		_cant_label.text = "Cant: " + str(_player.max_carry)
	if _coins_label:
		_coins_label.text = "$ " + str(_coins_this_run)
	_update_shield_icon()
	_update_stats_panel()

func _update_shield_icon() -> void:
	var shield_icon := get_tree().current_scene.get_node_or_null("HUDPanel/ShieldIcon")
	var shield_label := get_tree().current_scene.get_node_or_null("HUDPanel/ShieldLabel") as Label
	if _player:
		var count := _player.shield_count
		if shield_icon:
			shield_icon.visible = count > 0
		if shield_label:
			shield_label.visible = count > 0
			shield_label.text = "x" + str(count)
	var revive_icon := get_tree().current_scene.get_node_or_null("HUDPanel/ReviveIcon")
	if revive_icon:
		revive_icon.visible = SaveManager.has_revive and not SaveManager.revive_used

func _update_stats_panel() -> void:
	var vel_label := get_tree().current_scene.get_node_or_null("HUDPanel/StatsPanel/VelLabel")
	if vel_label and _player:
		vel_label.text = "Vel:" + str(int(_player.move_speed))
	var cant_label := get_tree().current_scene.get_node_or_null("HUDPanel/StatsPanel/CantLabel")
	if cant_label and _player:
		cant_label.text = "Cant:" + str(_player.max_carry)

func game_over() -> void:
	_state = GameState.GAME_OVER
	get_tree().paused = true
	coins += _coins_this_run
	_save_run()
	# Si tiene revive disponible y no lo ha usado, mostrar pantalla de revive
	if SaveManager.has_revive and not SaveManager.revive_used:
		if _revive_menu:
			_revive_menu.visible = true
		return
	# Game over definitivo
	_show_summary("Puntaje final: " + str(score))
	if _game_over_menu:
		_game_over_menu.visible = true

## Revive al jugador: restaura vida completa y reanuda la partida.
func _on_revive() -> void:
	SaveManager.revive_used = true
	if _revive_menu:
		_revive_menu.visible = false
	# Restaurar vida completa
	if _player:
		var health := _player.get_node_or_null("PlayerHealth") as PlayerHealth
		if health:
			health.init_hearts(SaveManager.get_effective_max_hearts())
	# Cambiar estado de vuelta a PLAYING
	_state = GameState.PLAYING
	get_tree().paused = false

func lose_points(amount: int) -> void:
	score = max(0, score - amount)
	emit_signal("score_changed", score)
	_update_label()

func _on_player_died() -> void:
	game_over()

func _on_health_changed(current_fragments: int, max_fragments: int, hearts: int, max_h: int) -> void:
	# Actualizar HUD de corazones si existen en la escena
	var hud_panel := get_tree().current_scene.get_node_or_null("HUDPanel")
	if hud_panel == null:
		return
	for i in range(5):
		var heart_node: AnimatedSprite2D = hud_panel.get_node_or_null("Heart" + str(i + 1))
		if heart_node == null:
			continue
		if i < max_h:
			heart_node.visible = true
			# Calcular fragmentos de este corazón
			var heart_fragments := clampi(current_fragments - i * 4, 0, 4)
			# Frame: 4=lleno, 3=3/4, 2=mitad, 1=1/4, 0=vacío
			heart_node.frame = heart_fragments
		else:
			heart_node.visible = false
	_update_shield_icon()

func _on_restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_gameover_main_menu() -> void:
	# Al perder las monedas ya se guardaron en game_over()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/UI/ChaosMainMenu.tscn")

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
	if _pause_menu:
		_pause_menu.visible = true

func _on_resume() -> void:
	if _pause_menu:
		_pause_menu.visible = false
	get_tree().paused = false

func _on_main_menu() -> void:
	# No guardar monedas de esta partida al volver al menú
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/UI/ChaosMainMenu.tscn")

func _on_quit() -> void:
	get_tree().quit()

## Verifica y aplica la fase de dificultad según el timer actual.
func _check_difficulty_phase() -> void:
	if _spawner == null or _spawner.difficulty_config == null:
		return
	var cfg := _spawner.difficulty_config
	var new_phase := _difficulty_phase
	if _match_timer <= cfg.phase4_start_at:
		new_phase = 4
	elif _match_timer <= cfg.phase3_start_at:
		new_phase = 3
	elif _match_timer <= cfg.phase2_start_at:
		new_phase = 2
	elif _match_timer <= cfg.phase1_start_at:
		new_phase = 1
	if new_phase != _difficulty_phase:
		_difficulty_phase = new_phase
		_spawner.apply_difficulty_phase(new_phase)

## Carga save centralizado y aplica stats al player.
func _load_save() -> void:
	coins = SaveManager.coins
	SaveManager.revive_used = false  ## resetear por partida
	if _player:
		_player.move_speed = SaveManager.get_effective_move_speed()
		_player.max_carry  = SaveManager.get_effective_max_carry()
		var health := _player.get_node_or_null("PlayerHealth") as PlayerHealth
		if health:
			# Diferir para que el HUD esté listo antes de emitir health_changed
			health.call_deferred("init_hearts", SaveManager.get_effective_max_hearts())

## Sincroniza monedas al SaveManager y persiste.
func _save_run() -> void:
	SaveManager.coins = coins
	SaveManager.save_data()

## Rellena los labels del panel de Game Over / Victoria.
func _show_summary(title: String) -> void:
	if _game_over_score:
		_game_over_score.text = title
	if _game_over_coins_earned:
		_game_over_coins_earned.text = "Monedas ganadas: +" + str(_coins_this_run)
	if _game_over_coins_total:
		_game_over_coins_total.text  = "Total acumulado: " + str(coins)

## XP y Level Up
func _on_leveled_up(_new_level: int) -> void:
	# Al subir de nivel, mostrar menú de power-up
	get_tree().paused = true
	if _power_menu:
		_power_menu.visible = true
	# Escalar dificultad de drones
	if _spawner:
		_spawner.on_player_level_up(_new_level)
	# Spawn helper cat al alcanzar el nivel configurado
	if not _helper_cat_spawned and _new_level >= helper_cat_spawn_level and helper_cat_scene and SaveManager.has_helper:
		_helper_cat_spawned = true
		SaveManager.has_helper = false  # Un solo uso por partida
		SaveManager.save_data()
		var helper: Node2D = helper_cat_scene.instantiate()
		helper.global_position = Vector2(320, 50)
		get_tree().current_scene.add_child(helper)

func _on_xp_changed(current_xp: int, xp_needed: int) -> void:
	# Actualizar barra de XP (ColorRect Fill)
	var fill := get_tree().current_scene.get_node_or_null("HUDPanel/XPBar/Fill")
	if fill and fill is ColorRect:
		var progress := float(current_xp) / float(xp_needed) if xp_needed > 0 else 0.0
		fill.offset_right = 2.0 + 188.0 * progress
	# Actualizar label de nivel
	var level_label := get_tree().current_scene.get_node_or_null("HUDPanel/LevelLabel")
	if level_label and _player:
		var xp := _player.get_node_or_null("PlayerXP") as PlayerXP
		if xp:
			level_label.text = "Lv." + str(xp.get_level())
