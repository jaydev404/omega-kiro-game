class_name DroneSpawner
extends Node2D

## Señales
signal package_spawned(package: PackageBody)
signal spawn_blocked()

## Config
@export var spawn_interval: float = 5.0
@export var max_packages: int = 4
@export var drone_scene: PackedScene
@export var package_scene: PackedScene

## Curva de dificultad — asignar DifficultyConfig.tres desde el inspector
@export var difficulty_config: DifficultyConfig

## Escenas adicionales de objetos
@export var bluepot_scene: PackedScene
@export var third_package_scene: PackedScene
@export var surprise_box_scene: PackedScene
@export var bomb_scene: PackedScene
@export var bomb_timer_scene: PackedScene
@export var ruby_scene: PackedScene
@export var gold_coin_scene: PackedScene
@export var silver_coin_scene: PackedScene

## Probabilidad (0-1) de que salga una caja sorpresa
@export_range(0.0, 1.0) var surprise_chance: float = 0.08

## Escenas de paquetes entregables activas (se amplía con el tiempo)
var _active_delivery_scenes: Array[PackedScene] = []

## Probabilidad (0-1) de que salga una bomba
@export_range(0.0, 1.0) var bomb_chance: float = 0.1

## Probabilidad (0-1) de que el dron apunte al jugador
@export_range(0.0, 1.0) var target_player_chance: float = 0.3

## Margen fuera de pantalla desde donde aparece el dron (px)
@export var offscreen_margin: float = 40.0

## Radio de exclusión alrededor del camión (px)
@export var truck_exclusion_radius: float = 50.0
@export var detect_radius: float = 12.0
@export var max_drop_attempts: int = 12
@export var chase_chance: float = 0.01

## Internos
var _active_count: int = 0
var _drones_in_flight: int = 0
var _timer: float = 0.0
var _difficulty_timer: float = 0.0
var _viewport_size: Vector2 = Vector2(640, 352)
var _spawn_ruby_next: bool = false
var _spawn_gold_next: bool = false
var _spawn_silver_next: bool = false
var _gold_timer: float = 0.0
var _silver_timer: float = 0.0
var _drop_zone_min: Vector2 = Vector2.ZERO
var _drop_zone_max: Vector2 = Vector2.ZERO

## Dificultad: incrementos cada 10 segundos
var _max_concurrent_drones: int = 3
var _drone_speed_bonus: float = 0.0
var _current_phase: int = 0  ## fase de dificultad activa

# ------------------------------------------------------------------ ciclo --

func _ready() -> void:
	_viewport_size = get_viewport_rect().size
	# Construir lista inicial de paquetes entregables (BOX + BLUEPOT)
	_active_delivery_scenes.clear()
	if package_scene:
		_active_delivery_scenes.append(package_scene)
	if bluepot_scene:
		_active_delivery_scenes.append(bluepot_scene)
	# Buscar markers de zona de drop en la escena
	var scene := get_tree().current_scene
	var top_left := scene.get_node_or_null("DropZoneTopLeft") as Marker2D
	var bottom_right := scene.get_node_or_null("DropZoneBottomRight") as Marker2D
	if top_left and bottom_right:
		_drop_zone_min = top_left.global_position
		_drop_zone_max = bottom_right.global_position
	else:
		_drop_zone_min = Vector2(30, 30)
		_drop_zone_max = _viewport_size - Vector2(30, 30)

## Activa el tercer tipo de paquete. Llamado por GameManager al minuto 5.
func enable_third_package() -> void:
	if third_package_scene and not _active_delivery_scenes.has(third_package_scene):
		_active_delivery_scenes.append(third_package_scene)

## Aplica los parámetros de una fase de dificultad. Llamado por GameManager.
func apply_difficulty_phase(phase: int) -> void:
	if difficulty_config == null or phase <= _current_phase:
		return
	_current_phase = phase
	match phase:
		1:
			spawn_interval      = difficulty_config.phase1_spawn_interval
			_max_concurrent_drones = difficulty_config.phase1_max_drones
			_drone_speed_bonus  = difficulty_config.phase1_drone_speed - 120.0
			bomb_chance         = difficulty_config.phase1_bomb_chance
			chase_chance        = difficulty_config.phase1_chase_chance
		2:
			spawn_interval      = difficulty_config.phase2_spawn_interval
			_max_concurrent_drones = difficulty_config.phase2_max_drones
			_drone_speed_bonus  = difficulty_config.phase2_drone_speed - 120.0
			bomb_chance         = difficulty_config.phase2_bomb_chance
			chase_chance        = difficulty_config.phase2_chase_chance
		3:
			spawn_interval      = difficulty_config.phase3_spawn_interval
			_max_concurrent_drones = difficulty_config.phase3_max_drones
			_drone_speed_bonus  = difficulty_config.phase3_drone_speed - 120.0
			bomb_chance         = difficulty_config.phase3_bomb_chance
			chase_chance        = difficulty_config.phase3_chase_chance
		4:
			spawn_interval      = difficulty_config.phase4_spawn_interval
			_max_concurrent_drones = difficulty_config.phase4_max_drones
			_drone_speed_bonus  = difficulty_config.phase4_drone_speed - 120.0
			bomb_chance         = difficulty_config.phase4_bomb_chance
			chase_chance        = difficulty_config.phase4_chase_chance

func _process(delta: float) -> void:
	# Timer para gold coin (cada 30 segundos)
	_gold_timer += delta
	if _gold_timer >= 30.0:
		_gold_timer = 0.0
		_spawn_gold_next = true

	# Timer para silver coin (cada 10 segundos)
	_silver_timer += delta
	if _silver_timer >= 10.0:
		_silver_timer = 0.0
		_spawn_silver_next = true

	_timer += delta
	if _timer >= spawn_interval:
		_timer = 0.0
		_try_spawn()

func _increase_difficulty() -> void:
	_drone_speed_bonus += 30.0
	spawn_interval = max(0.5, spawn_interval - 0.2)

## Llamado cuando el player sube de nivel para escalar dificultad.
func on_player_level_up(level: int) -> void:
	# Cada nivel: +1 drone concurrente
	_max_concurrent_drones += 1
	# Cada 2 niveles: aumentar velocidad y chase chance
	if level % 2 == 0:
		_increase_difficulty()
		chase_chance = min(0.3, chase_chance + 0.02)

# ------------------------------------------------------------------ lógica --

func _try_spawn() -> void:
	# Lanzar drones hasta alcanzar el máximo concurrente
	while _drones_in_flight < _max_concurrent_drones:
		_launch_drone()

func _launch_drone() -> void:
	var chosen_scene := _pick_package_scene()

	# Si es bomba (inmediata o timer), siempre apuntar a la posición actual del player
	var drop_pos: Vector2
	if chosen_scene == bomb_scene or chosen_scene == bomb_timer_scene:
		var player_pos := _get_player_position()
		if player_pos == Vector2.INF:
			drop_pos = _random_drop_in_playarea()
		else:
			drop_pos = player_pos
	else:
		drop_pos = _choose_drop_position()

	var spawn_origin := _random_offscreen_origin()
	var fly_target := Vector2(drop_pos.x, drop_pos.y - 30.0)

	var drone: Drone = drone_scene.instantiate()
	add_child(drone)
	drone.speed += _drone_speed_bonus
	drone.init(spawn_origin, fly_target, drop_pos, chosen_scene)

	# 5% de probabilidad de que un drone con box/pot persiga al player
	if chosen_scene != bomb_scene and chosen_scene != bomb_timer_scene and chosen_scene != ruby_scene \
		and chosen_scene != gold_coin_scene and chosen_scene != silver_coin_scene:
		if randf() < chase_chance:
			drone.set_chase_mode(true)

	drone.package_delivered.connect(_on_package_delivered)
	drone.drone_finished.connect(_on_drone_finished)
	_drones_in_flight += 1

## Elige qué objeto soltar: ruby/gold/silver si toca, si no 10% bomba, resto reparte entre paquetes activos.
func _pick_package_scene() -> PackedScene:
	if _spawn_ruby_next and ruby_scene:
		_spawn_ruby_next = false
		return ruby_scene

	if _spawn_gold_next and gold_coin_scene:
		_spawn_gold_next = false
		return gold_coin_scene

	if _spawn_silver_next and silver_coin_scene:
		_spawn_silver_next = false
		return silver_coin_scene

	var roll := randf()
	if roll < bomb_chance:
		if randf() < 0.6 and bomb_scene:
			return bomb_scene
		elif bomb_timer_scene:
			return bomb_timer_scene
		else:
			return bomb_scene

	# Caja sorpresa con probabilidad baja
	if randf() < surprise_chance and surprise_box_scene:
		return surprise_box_scene

	# Selección aleatoria uniforme entre los paquetes entregables activos
	if not _active_delivery_scenes.is_empty():
		return _active_delivery_scenes[randi() % _active_delivery_scenes.size()]

	return package_scene

## Llamado por GameManager cada 5 puntos para que el próximo drone traiga un ruby.
func queue_ruby() -> void:
	_spawn_ruby_next = true

## Elige posición de drop: a veces apunta al player, si no, punto aleatorio.
## Siempre evita la zona del camión y los tiles prohibidos.
func _choose_drop_position() -> Vector2:
	if randf() < target_player_chance:
		var player_pos := _get_player_position()
		if player_pos != Vector2.INF and not _is_near_truck(player_pos) and not _is_on_blocked_tile(player_pos):
			return player_pos

	for _i in range(max_drop_attempts):
		var candidate := _random_drop_in_playarea()
		if _is_near_truck(candidate):
			continue
		if _is_on_blocked_tile(candidate):
			continue
		if _is_position_occupied(candidate):
			continue
		return candidate

	# Si no encontró posición libre, buscar una que al menos no esté sobre un camión
	for _j in range(5):
		var fallback := _random_drop_in_playarea()
		if not _is_near_truck(fallback):
			return fallback
	return _random_drop_in_playarea()

## Genera un punto de spawn aleatorio desde cualquier borde de la pantalla.
func _random_offscreen_origin() -> Vector2:
	var side := randi() % 4
	match side:
		0:  # arriba
			return Vector2(randf_range(0.0, _viewport_size.x), -offscreen_margin)
		1:  # abajo
			return Vector2(randf_range(0.0, _viewport_size.x), _viewport_size.y + offscreen_margin)
		2:  # izquierda
			return Vector2(-offscreen_margin, randf_range(0.0, _viewport_size.y))
		3:  # derecha
			return Vector2(_viewport_size.x + offscreen_margin, randf_range(0.0, _viewport_size.y))
	return Vector2(-offscreen_margin, _viewport_size.y * 0.5)

## Genera una posición aleatoria dentro de la zona de drop definida.
func _random_drop_in_playarea() -> Vector2:
	return Vector2(
		randf_range(_drop_zone_min.x, _drop_zone_max.x),
		randf_range(_drop_zone_min.y, _drop_zone_max.y)
	)

## Verifica si una posición está cerca de algún camión.
func _is_near_truck(pos: Vector2) -> bool:
	var trucks := get_tree().get_nodes_in_group("truck")
	if trucks.is_empty():
		var scene := get_tree().current_scene
		if scene:
			for child in scene.get_children():
				if child.name.begins_with("DeliveryTruck"):
					if pos.distance_to(child.global_position) < truck_exclusion_radius:
						return true
		return false
	for truck in trucks:
		if pos.distance_to(truck.global_position) < truck_exclusion_radius:
			return true
	return false

## Tiles bloqueados donde no se pueden soltar objetos (coordenadas de tile 16x16).
const _TILE_SIZE := 16.0
const _BLOCKED_TILES: Array = [
	Vector2i(0, 16), Vector2i(1, 16), Vector2i(3, 16),
	Vector2i(0, 17), Vector2i(3, 17),
	Vector2i(0, 18), Vector2i(1, 18), Vector2i(3, 18)
]

## Verifica si una posición en mundo cae sobre un tile bloqueado.
func _is_on_blocked_tile(pos: Vector2) -> bool:
	var tile_coord := Vector2i(int(pos.x / _TILE_SIZE), int(pos.y / _TILE_SIZE))
	for blocked in _BLOCKED_TILES:
		if tile_coord == blocked:
			return true
	return false

## Verifica si ya hay un paquete en esa posición.
func _is_position_occupied(pos: Vector2) -> bool:
	var world: World2D = get_tree().current_scene.get_world_2d()
	if world == null:
		return false
	var space: PhysicsDirectSpaceState2D = world.direct_space_state
	var shape_params := PhysicsShapeQueryParameters2D.new()
	var circle := CircleShape2D.new()
	circle.radius = detect_radius
	shape_params.shape = circle
	shape_params.transform = Transform2D(0.0, pos)
	shape_params.collision_mask = 4
	var results := space.intersect_shape(shape_params, 1)
	return not results.is_empty()

## Obtiene la posición global del jugador.
func _get_player_position() -> Vector2:
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		var scene := get_tree().current_scene
		if scene:
			var p := scene.get_node_or_null("Player")
			if p:
				return p.global_position
		return Vector2.INF
	return player.global_position

# ------------------------------------------------------------------ callbacks --

func _on_package_delivered(package: PackageBody) -> void:
	# Las bombas se autodestruyen, no cuentan como activas
	if package.package_type == PackageBody.PackageType.BOMB:
		return
	_active_count += 1
	package.picked_up.connect(_on_package_picked_up)
	emit_signal("package_spawned", package)

func _on_drone_finished() -> void:
	_drones_in_flight = max(0, _drones_in_flight - 1)

func _on_package_picked_up(_package: PackageBody) -> void:
	_active_count = max(0, _active_count - 1)
