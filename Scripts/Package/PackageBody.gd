class_name PackageBody
extends CharacterBody2D

## Tipos de paquete
enum PackageType { BOX, BLUEPOT, THIRDBOX, BOMB, RUBY, GOLD_COIN, SILVER_COIN, BOMB_TIMER, SURPRISE }

## Estados de la caja
enum State { FREE, CARRIED }

# -- Señales --
signal picked_up(package: PackageBody)
signal dropped(package: PackageBody)

# -- Config --
@export var package_type: PackageType = PackageType.BOX

# -- Internos --
var _state: State = State.FREE

## Si es true, no puede ser recogido automáticamente (delay post-spawn de SurpriseBox)
var pickup_blocked: bool = false

@onready var _collision: CollisionShape2D = $CollisionShape2D

# ------------------------------------------------------------------ público --

func _ready() -> void:
	add_to_group("packages")

func interact() -> void:
	pass  # lógica gestionada por PlayerCarry

func is_carried() -> bool:
	return _state == State.CARRIED

func pick_up() -> void:
	if _state == State.CARRIED:
		return
	_state = State.CARRIED
	velocity = Vector2.ZERO
	_collision.disabled = true
	z_index = 10  # por encima de todo durante el transporte
	emit_signal("picked_up", self)

## Escena del efecto DirtyExplosion
var _dirty_explosion_scene: PackedScene = preload("res://Scenes/Effects/DirtyExplosion.tscn")
var _bomb_explosion_scene: PackedScene = preload("res://Scenes/Effects/BombExplosion.tscn")

func drop() -> void:
	if _state == State.FREE:
		return
	_state = State.FREE
	velocity = Vector2.ZERO
	_collision.set_deferred("disabled", false)
	z_index = 0
	emit_signal("dropped", self)

	if package_type == PackageType.BOMB:
		# La bomba explota al caer
		call_deferred("_bomb_explode")
	else:
		# Verificar colisión con otro paquete (no bomba) al caer
		call_deferred("_check_landing_collision")

## Entrega al camión — fade out y destrucción
func deliver() -> void:
	_state = State.CARRIED
	_collision.set_deferred("disabled", true)
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_callback(queue_free)

## Chequea si al caer hay otro paquete (no bomba) en la misma posición.
## Si lo hay, ejecuta DirtyExplosion y destruye ambos.
## También verifica si cae sobre el player para restar puntos.
func _check_landing_collision() -> void:
	if not is_inside_tree():
		return

	# Verificar si cae sobre el player
	var player := get_tree().current_scene.get_node_or_null("Player") as PlayerController
	if player and global_position.distance_to(player.global_position) < landing_hit_radius:
		# Ruby y monedas no hacen daño ni muestran explosión al caer
		var no_damage := package_type in [PackageType.RUBY, PackageType.GOLD_COIN, PackageType.SILVER_COIN]
		if no_damage:
			return
		var health := player.get_node_or_null("PlayerHealth") as PlayerHealth
		if health:
			health.take_damage(landing_damage)
		# Destruir el paquete que cayó encima
		var effect := _dirty_explosion_scene.instantiate()
		get_tree().current_scene.add_child(effect)
		effect.global_position = global_position
		queue_free()
		return

	var space: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var shape_params := PhysicsShapeQueryParameters2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 14.0
	shape_params.shape = circle
	shape_params.transform = Transform2D(0.0, global_position)
	shape_params.collision_mask = 4  # layer package
	shape_params.exclude = [get_rid()]

	var results := space.intersect_shape(shape_params, 4)
	for r in results:
		var collider: Object = r.get("collider")
		if collider is PackageBody:
			var other := collider as PackageBody
			if other.package_type != PackageType.BOMB and not other.is_carried():
				# Spawn efecto
				var effect := _dirty_explosion_scene.instantiate()
				get_tree().current_scene.add_child(effect)
				effect.global_position = global_position
				# Destruir ambos
				other.queue_free()
				queue_free()
				return

## La bomba explota: ejecuta BombExplosion, destruye objetos cercanos con DirtyExplosion.
@export var bomb_radius: float = 24.0
@export var bomb_damage: int = 2
@export var landing_damage: int = 1
@export var landing_hit_radius: float = 16.0

func _bomb_explode() -> void:
	if not is_inside_tree():
		return

	# Efecto de explosión de bomba
	var bomb_effect := _bomb_explosion_scene.instantiate()
	get_tree().current_scene.add_child(bomb_effect)
	bomb_effect.global_position = global_position

	# Verificar si el player está cerca → aplicar daño via PlayerHealth
	var player := get_tree().current_scene.get_node_or_null("Player") as PlayerController
	if player and global_position.distance_to(player.global_position) < bomb_radius:
		var health := player.get_node_or_null("PlayerHealth") as PlayerHealth
		if health:
			health.take_damage(bomb_damage)
		queue_free()
		return

	# Buscar objetos cercanos para destruir
	var space: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var shape_params := PhysicsShapeQueryParameters2D.new()
	var circle := CircleShape2D.new()
	circle.radius = bomb_radius
	shape_params.shape = circle
	shape_params.transform = Transform2D(0.0, global_position)
	shape_params.collision_mask = 4  # layer package
	shape_params.exclude = [get_rid()]

	var results := space.intersect_shape(shape_params, 16)
	for r in results:
		var collider: Object = r.get("collider")
		if collider is PackageBody:
			var other := collider as PackageBody
			if not other.is_carried():
				# Efecto dirty en cada objeto destruido
				var dirty_effect := _dirty_explosion_scene.instantiate()
				get_tree().current_scene.add_child(dirty_effect)
				dirty_effect.global_position = other.global_position
				other.queue_free()

	# Destruir la bomba misma
	queue_free()

func _trigger_game_over() -> void:
	var game_manager := get_tree().current_scene.get_node_or_null("GameManager") as GameManager
	if game_manager:
		game_manager.game_over()
