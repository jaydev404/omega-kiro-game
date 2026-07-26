## SurpriseBox — al recogerla se revela aleatoriamente como moneda, ruby o bomba timer.
## El player la recoge con E pero nunca la carga: se destruye y spawna el item real.
class_name SurpriseBox
extends PackageBody

## Escenas posibles que puede revelar
@export var reveal_gold_coin_scene: PackedScene
@export var reveal_ruby_scene: PackedScene
@export var reveal_bomb_scene: PackedScene

## Probabilidades de cada resultado (deben sumar 1.0)
@export var chance_gold_coin: float  = 0.50
@export var chance_ruby: float       = 0.30
@export var chance_bomb: float       = 0.20

func _ready() -> void:
	package_type = PackageType.SURPRISE

## Sobreescribe pick_up: en lugar de cargarse, se revela en el lugar.
## Llamado por PlayerCarry cuando detecta el tipo SURPRISE.
func reveal_at(pos: Vector2) -> void:
	if not is_inside_tree():
		return

	var chosen := _pick_reveal_scene()
	if chosen:
		var item: Node = chosen.instantiate()
		get_tree().current_scene.add_child(item)
		item.global_position = pos

		if item is PackageBody:
			var pkg := item as PackageBody
			if pkg.package_type == PackageType.BOMB:
				# La bomba explota directamente al aparecer — llamar pick_up + drop activa _bomb_explode
				pkg.pick_up()
				pkg.drop()
			else:
				# Moneda/Ruby: bloquear recogida brevemente para que el player vea qué salió
				pkg.pickup_blocked = true
				item.scale = Vector2.ZERO
				var tween := item.create_tween()
				tween.tween_property(item, "scale", Vector2(1.3, 1.3), 0.15).set_ease(Tween.EASE_OUT)
				tween.tween_property(item, "scale", Vector2(1.0, 1.0), 0.08)
				# Desbloquear después de 0.3s — suficiente para ver, no tanto para molestar
				tween.tween_interval(0.07)
				tween.tween_callback(func(): pkg.pickup_blocked = false)

	# Flash de la surprise box antes de desaparecer
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.4, 1.4), 0.08)
	tween.tween_property(self, "modulate:a", 0.0, 0.1)
	tween.tween_callback(queue_free)

func _pick_reveal_scene() -> PackedScene:
	var roll := randf()
	if roll < chance_gold_coin and reveal_gold_coin_scene:
		return reveal_gold_coin_scene
	roll -= chance_gold_coin
	if roll < chance_ruby and reveal_ruby_scene:
		return reveal_ruby_scene
	if reveal_bomb_scene:
		return reveal_bomb_scene
	return null
