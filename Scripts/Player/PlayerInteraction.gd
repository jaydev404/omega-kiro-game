class_name PlayerInteraction
extends Node

# -- Señales --
signal interaction_available(interactable: Node)
signal interaction_unavailable()
signal interact_pressed(interactable: Node)
signal ruby_collected(ruby: PackageBody)

@onready var _area: Area2D = $"../InteractionArea"
@onready var _carry: PlayerCarry = $"../PlayerCarry"

var _current_interactable: Node = null
var _current_zone: DeliveryZone = null  # zona de entrega si el player está dentro

func _ready() -> void:
	_area.body_entered.connect(_on_body_entered)
	_area.body_exited.connect(_on_body_exited)
	_area.area_entered.connect(_on_area_entered)
	_area.area_exited.connect(_on_area_exited)

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"):
		return

	# Cargando dentro de zona de entrega → siempre entrega al camión
	if _carry.is_carrying() and _current_zone != null:
		emit_signal("interact_pressed", _current_zone)
		return

	# Hay un objeto interactuable en rango → intentar agarrar o soltar
	if _current_interactable != null:
		emit_signal("interact_pressed", _current_interactable)
		return

	# Cargando fuera de zona sin objeto cerca → suelta
	if _carry.is_carrying():
		var pkg := _carry.get_carried_package()
		if is_instance_valid(pkg):
			emit_signal("interact_pressed", pkg)
		return

# ------------------------------------------------------------------ interno --

func _on_body_entered(body: Node) -> void:
	# Ruby y monedas se recogen automáticamente al contacto
	if body is PackageBody:
		var pkg := body as PackageBody
		if not pkg.is_carried() and not pkg.pickup_blocked:
			if pkg.package_type == PackageBody.PackageType.RUBY \
				or pkg.package_type == PackageBody.PackageType.GOLD_COIN \
				or pkg.package_type == PackageBody.PackageType.SILVER_COIN:
				emit_signal("ruby_collected", pkg)
				return
	if body.has_method("interact"):
		_current_interactable = body
		emit_signal("interaction_available", body)

func _on_body_exited(body: Node) -> void:
	if body == _current_interactable:
		_current_interactable = null
		emit_signal("interaction_unavailable")

func _on_area_entered(area: Area2D) -> void:
	if area is DeliveryZone:
		_current_zone = area as DeliveryZone
		emit_signal("interaction_available", area)

func _on_area_exited(area: Area2D) -> void:
	if area == _current_zone:
		_current_zone = null
		emit_signal("interaction_unavailable")