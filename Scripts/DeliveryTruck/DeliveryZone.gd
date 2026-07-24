class_name DeliveryZone
extends Area2D

## Señales
signal package_delivered(count: int)
signal package_rejected(package: PackageBody)

## Tipo de paquete que acepta este camión
@export var accepted_type: PackageBody.PackageType = PackageBody.PackageType.BOX

## Internos
var _delivery_count: int = 0

## Implementa la interfaz Interactable — detectado por PlayerInteraction
func interact() -> void:
	pass  # la lógica la invoca PlayerCarry.deliver()

## Verifica si el camión acepta este tipo de paquete
func accepts(package: PackageBody) -> bool:
	return package.package_type == accepted_type

## Llamado por PlayerCarry cuando el player entrega una caja aquí
func receive(package: PackageBody) -> void:
	_delivery_count += 1
	package.deliver()
	emit_signal("package_delivered", _delivery_count)

func get_delivery_count() -> int:
	return _delivery_count
