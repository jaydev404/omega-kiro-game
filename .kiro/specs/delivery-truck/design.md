# Delivery Truck — Design

## Escena

```
DeliveryTruck.tscn

Area2D                        ← zona de entrega, detecta al Player
├── DeliveryZone.gd           ← lógica de entrega y contador
├── CollisionShape2D          ← RectangleShape2D, área de detección
└── TruckVisual (Node2D)
    └── TruckVisual.gd        ← placeholder: rectángulo verde con label
```

## Script — DeliveryZone.gd

Responsabilidades:
- Implementa `interact()` → es detectado por `PlayerInteraction`.
- Al recibir `interact()` desde `PlayerCarry`:
  - Verifica que el player carga un `PackageBody`.
  - Llama `package.deliver()` para animación de desaparición.
  - Incrementa `_delivery_count`.
  - Emite `package_delivered(count: int)`.
- Expone `get_delivery_count() -> int`.

## Integración con PlayerCarry

`PlayerCarry._on_interact_pressed` ya maneja dos casos:
- Cargando + interactable es `DeliveryZone` → llama `delivery_zone.receive(package)`
- Cargando + no hay DeliveryZone → suelta al suelo (comportamiento actual)

Se agrega un tercer caso en `PlayerCarry`:

```
func _on_interact_pressed(interactable: Node) -> void:
    if is_carrying():
        if interactable is DeliveryZone:
            _deliver(interactable)   ← NUEVO
        else:
            _drop()
    elif interactable is PackageBody:
        _pick_up(interactable)
```

## Animación de Entrega (PackageBody)

Se agrega el método `deliver()` a `PackageBody`:
- Desactiva colisión inmediatamente.
- Hace `modulate` fade a transparente en 0.2s con un `Tween`.
- Llama `queue_free()` al terminar.

## Collision Layers

`DeliveryZone` (Area2D):
- `collision_layer = 0` (no tiene capa propia)
- `collision_mask = 2` (detecta al Player, layer 2)

## Señales

```
package_delivered(count: int)   ← emitida por DeliveryZone
```
