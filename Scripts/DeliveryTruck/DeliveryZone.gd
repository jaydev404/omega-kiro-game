class_name DeliveryZone
extends Area2D

## Señales
signal package_delivered(count: int)

## Internos
var _delivery_count: int = 0

## Implementa la interfaz Interactable — detectado por PlayerInteraction
func interact() -> void:
	pass  # la lógica la invoca PlayerCarry.deliver()

## Llamado por PlayerCarry cuando el player entrega una caja aquí
func receive(package: PackageBody) -> void:
	_delivery_count += 1
	package.deliver()
	emit_signal("package_delivered", _delivery_count)

func get_delivery_count() -> int:
	return _delivery_count
