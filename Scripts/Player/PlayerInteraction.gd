class_name PlayerInteraction
extends Node

# -- Señales --
signal interaction_available(interactable: Node)
signal interaction_unavailable()
signal interact_pressed(interactable: Node)

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

	# Cargando fuera de zona → suelta
	if _carry.is_carrying():
		emit_signal("interact_pressed", _carry.get_carried_package())
		return

	# Sin carga → interactúa con lo que haya en rango
	if _current_interactable != null:
		emit_signal("interact_pressed", _current_interactable)

# ------------------------------------------------------------------ interno --

func _on_body_entered(body: Node) -> void:
	if body.has_method("interact") and not _carry.is_carrying():
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