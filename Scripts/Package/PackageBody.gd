class_name PackageBody
extends CharacterBody2D

## Tipos de paquete
enum PackageType { BOX, BLUEPOT, BOMB, RUBY, GOLD_COIN, SILVER_COIN }

## Estados de la caja
enum State { FREE, CARRIED }

# -- Señales --
signal picked_up(package: PackageBody)
signal dropped(package: PackageBody)

# -- Config --
@export var package_type: PackageType = PackageType.BOX

# -- Internos --
var _state: State = State.FREE

@onready var _collision: CollisionShape2D = $CollisionShape2D

# ------------------------------------------------------------------ público --

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
	if player and global_position.distance_to(player.global_position) < 30.0:
		var game_manager := get_tree().current_scene.get_node_or_null("GameManager") as GameManager
		if game_manager:
			game_manager.lose_points(2)
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
const _BOMB_RADIUS := 48.0

func _bomb_explode() -> void:
	if not is_inside_tree():
		return

	# Efecto de explosión de bomba
	var bomb_effect := _bomb_explosion_scene.instantiate()
	get_tree().current_scene.add_child(bomb_effect)
	bomb_effect.global_position = global_position

	# Verificar si el player tiene escudo y está cerca
	var player := get_tree().current_scene.get_node_or_null("Player") as PlayerController
	if player and global_position.distance_to(player.global_position) < _BOMB_RADIUS:
		if player.has_shield:
			player.has_shield = false  # consumir escudo
			queue_free()
			return
		else:
			# Game Over
			queue_free()
			_trigger_game_over()
			return

	# Buscar objetos cercanos para destruir
	var space: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var shape_params := PhysicsShapeQueryParameters2D.new()
	var circle := CircleShape2D.new()
	circle.radius = _BOMB_RADIUS
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
