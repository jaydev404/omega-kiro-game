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

## Escenas adicionales de objetos
@export var bluepot_scene: PackedScene
@export var bomb_scene: PackedScene
@export var ruby_scene: PackedScene
@export var gold_coin_scene: PackedScene
@export var silver_coin_scene: PackedScene

## Probabilidad (0-1) de que salga una bomba
@export_range(0.0, 1.0) var bomb_chance: float = 0.1

## Probabilidad (0-1) de que el dron apunte al jugador
@export_range(0.0, 1.0) var target_player_chance: float = 0.3

## Margen fuera de pantalla desde donde aparece el dron (px)
@export var offscreen_margin: float = 80.0

## Radio de exclusión alrededor del camión (px)
const _TRUCK_EXCLUSION_RADIUS := 100.0
const _DETECT_RADIUS := 20.0
const _MAX_DROP_ATTEMPTS := 12

## Internos
var _active_count: int = 0
var _drones_in_flight: int = 0
var _timer: float = 0.0
var _difficulty_timer: float = 0.0
var _viewport_size: Vector2 = Vector2(1152, 648)
var _spawn_ruby_next: bool = false
var _spawn_gold_next: bool = false
var _spawn_silver_next: bool = false
var _gold_timer: float = 0.0
var _silver_timer: float = 0.0

## Dificultad: incrementos cada 10 segundos
var _max_concurrent_drones: int = 3
var _drone_speed_bonus: float = 0.0

# ------------------------------------------------------------------ ciclo --

func _ready() -> void:
	_viewport_size = get_viewport_rect().size

func _process(delta: float) -> void:
	# Escalar dificultad cada 10 segundos
	_difficulty_timer += delta
	if _difficulty_timer >= 10.0:
		_difficulty_timer = 0.0
		_increase_difficulty()

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
	# Reducir intervalo de spawn (mínimo 1 segundo)
	spawn_interval = max(1.0, spawn_interval - 0.3)

# ------------------------------------------------------------------ lógica --

func _try_spawn() -> void:
	# Lanzar drones hasta alcanzar el máximo concurrente
	while _drones_in_flight < _max_concurrent_drones:
		_launch_drone()

func _launch_drone() -> void:
	var chosen_scene := _pick_package_scene()

	# Si es bomba, siempre apuntar a la posición actual del player
	var drop_pos: Vector2
	if chosen_scene == bomb_scene:
		var player_pos := _get_player_position()
		if player_pos == Vector2.INF:
			drop_pos = _random_drop_in_playarea()
		else:
			drop_pos = player_pos
	else:
		drop_pos = _choose_drop_position()

	var spawn_origin := _random_offscreen_origin()
	var fly_target := Vector2(drop_pos.x, drop_pos.y - 60.0)

	var drone: Drone = drone_scene.instantiate()
	add_child(drone)
	drone.speed += _drone_speed_bonus
	drone.init(spawn_origin, fly_target, drop_pos, chosen_scene)

	# 5% de probabilidad de que un drone con box/pot persiga al player
	if chosen_scene != bomb_scene and chosen_scene != ruby_scene \
		and chosen_scene != gold_coin_scene and chosen_scene != silver_coin_scene:
		if randf() < 0.05:
			drone.set_chase_mode(true)

	drone.package_delivered.connect(_on_package_delivered)
	drone.drone_finished.connect(_on_drone_finished)
	_drones_in_flight += 1

## Elige qué objeto soltar: ruby/gold/silver si toca, si no 10% bomba, 90% se reparte entre box y bluepot.
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
	if roll < bomb_chance and bomb_scene:
		return bomb_scene
	else:
		if randf() < 0.5 and bluepot_scene:
			return bluepot_scene
		else:
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

	for _i in range(_MAX_DROP_ATTEMPTS):
		var candidate := _random_drop_in_playarea()
		if _is_near_truck(candidate):
			continue
		if _is_on_blocked_tile(candidate):
			continue
		if _is_position_occupied(candidate):
			continue
		return candidate

	# Si no encontró posición libre, usar una aleatoria de todas formas
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

## Genera una posición aleatoria dentro del área de juego.
func _random_drop_in_playarea() -> Vector2:
	var margin := 60.0
	return Vector2(
		randf_range(margin, _viewport_size.x - margin),
		randf_range(margin + 100.0, _viewport_size.y - margin)
	)

## Verifica si una posición está cerca de algún camión.
func _is_near_truck(pos: Vector2) -> bool:
	var trucks := get_tree().get_nodes_in_group("truck")
	if trucks.is_empty():
		var scene := get_tree().current_scene
		if scene:
			for child in scene.get_children():
				if child.name.begins_with("DeliveryTruck"):
					if pos.distance_to(child.global_position) < _TRUCK_EXCLUSION_RADIUS:
						return true
		return false
	for truck in trucks:
		if pos.distance_to(truck.global_position) < _TRUCK_EXCLUSION_RADIUS:
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
	circle.radius = _DETECT_RADIUS
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
