class_name PlayerCarry
extends Node

# -- Señales --
signal package_picked_up(package: PackageBody)
signal package_dropped(package: PackageBody)

@onready var _carry_point: Marker2D = $"../CarryPoint"
@onready var _interaction: PlayerInteraction = $"../PlayerInteraction"

var _carried_package: PackageBody = null

func _ready() -> void:
	_interaction.interact_pressed.connect(_on_interact_pressed)

# ------------------------------------------------------------------ público --

func is_carrying() -> bool:
	return _carried_package != null

func get_carried_package() -> PackageBody:
	return _carried_package

# ------------------------------------------------------------------ interno --

func _on_interact_pressed(interactable: Node) -> void:
	if is_carrying():
		if interactable is DeliveryZone:
			_deliver(interactable as DeliveryZone)
		else:
			_drop()
	elif interactable is PackageBody:
		_pick_up(interactable)

func _pick_up(package: PackageBody) -> void:
	_carried_package = package
	package.reparent(_carry_point)
	package.position = Vector2.ZERO
	package.pick_up()
	emit_signal("package_picked_up", package)

func _drop() -> void:
	var package := _carried_package
	_carried_package = null
	var scene_root := get_tree().current_scene
	package.reparent(scene_root)
	package.drop()
	emit_signal("package_dropped", package)

func _deliver(zone: DeliveryZone) -> void:
	var package := _carried_package
	_carried_package = null
	# Sacar del CarryPoint antes de entregar
	package.reparent(get_tree().current_scene)
	zone.receive(package)
	emit_signal("package_dropped", package)
