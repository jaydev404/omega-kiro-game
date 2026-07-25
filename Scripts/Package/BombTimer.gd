class_name BombTimer
extends PackageBody

## Config
@export var fuse_time: float = 3.0  ## Tiempo antes de explotar (segundos)

## Internos
var _fuse_timer: float = 0.0
var _is_fuse_active: bool = false
var _blink_timer: float = 0.0

@onready var _visual: AnimatedSprite2D = $BombTimerVisual

func _ready() -> void:
	package_type = PackageType.BOMB_TIMER

func _process(delta: float) -> void:
	if not _is_fuse_active:
		return

	_fuse_timer -= delta
	# Parpadeo que se acelera conforme se acerca a explotar
	var blink_speed := lerpf(4.0, 20.0, 1.0 - (_fuse_timer / fuse_time))
	_blink_timer += delta * blink_speed
	if _visual:
		_visual.modulate.a = 0.4 + 0.6 * abs(sin(_blink_timer))

	if _fuse_timer <= 0.0:
		_explode()

## Inicia la mecha al caer (cuando el drone la suelta)
func drop() -> void:
	super.drop()
	_start_fuse()

## También inicia la mecha si el player la suelta
func _start_fuse() -> void:
	if _is_fuse_active:
		return
	_is_fuse_active = true
	_fuse_timer = fuse_time

func _explode() -> void:
	_is_fuse_active = false
	if not is_inside_tree():
		return

	# Efecto de explosión
	var bomb_effect := _bomb_explosion_scene.instantiate()
	get_tree().current_scene.add_child(bomb_effect)
	bomb_effect.global_position = global_position

	# Dañar al player si está cerca
	var player := get_tree().current_scene.get_node_or_null("Player") as PlayerController
	if player and global_position.distance_to(player.global_position) < bomb_radius:
		var health := player.get_node_or_null("PlayerHealth") as PlayerHealth
		if health:
			health.take_damage(bomb_damage)

	# Destruir objetos cercanos
	var space: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var shape_params := PhysicsShapeQueryParameters2D.new()
	var circle := CircleShape2D.new()
	circle.radius = bomb_radius
	shape_params.shape = circle
	shape_params.transform = Transform2D(0.0, global_position)
	shape_params.collision_mask = 4
	shape_params.exclude = [get_rid()]

	var results := space.intersect_shape(shape_params, 16)
	for r in results:
		var collider: Object = r.get("collider")
		if collider is PackageBody:
			var other := collider as PackageBody
			if not other.is_carried():
				var dirty_effect := _dirty_explosion_scene.instantiate()
				get_tree().current_scene.add_child(dirty_effect)
				dirty_effect.global_position = other.global_position
				other.queue_free()

	queue_free()
