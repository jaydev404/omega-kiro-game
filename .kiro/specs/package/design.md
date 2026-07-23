# Package — Design

## Escena

```
Package.tscn

CharacterBody2D          ← física sólida, empuje por contacto
├── PackageVisual.gd     ← Node2D, dibuja placeholder de color
├── CollisionShape2D     ← RectangleShape2D, desactivada en CARRIED
└── InteractArea (Area2D)
    └── CollisionShape2D ← radio de detección para PlayerInteraction
```

## Scripts

### PackageBody.gd
- Extiende `CharacterBody2D`.
- Gestiona el estado `FREE` / `CARRIED`.
- En estado `FREE`: recibe velocidad de empuje del Player mediante `push(direction, force)`.
- En estado `CARRIED`: desactiva `CollisionShape2D`, mueve junto al CarryPoint.
- Implementa el método `interact()` para ser detectado por `PlayerInteraction`.
- Emite señales: `picked_up`, `dropped`.

### PackageVisual.gd
- Extiende `Node2D`.
- Dibuja un rectángulo de color sólido con `_draw()`.
- Color configurable vía `@export`.
- Reemplazar por `Sprite2D` cuando haya assets.

## Física de Empuje

El empuje ocurre de forma natural porque tanto el Player como la caja son `CharacterBody2D`.

En `PackageBody.gd._physics_process()`:
- Si `FREE`: aplica fricción para frenar gradualmente.
- Si `CARRIED`: posición controlada por el Player vía `reparent`.

## Integración con PlayerCarry

`PlayerInteraction` detecta la caja por su `InteractArea`.
Al presionar E:
1. `PlayerInteraction` emite `interact_pressed(package)`.
2. `PlayerCarry` llama `package.pick_up()`.
3. `PackageBody` cambia a estado `CARRIED` y se reparenta al `CarryPoint`.

Al presionar E con caja en mano:
1. `PlayerCarry` llama `package.drop()`.
2. `PackageBody` cambia a estado `FREE` y se reparenta a la escena raíz.

## Collision Layers

| Layer | Nombre | Quién lo usa |
|---|---|---|
| 1 | `world` | paredes, suelo |
| 2 | `player` | Player |
| 3 | `package` | Package |

Player mask: layers 1, 3 → colisiona con mundo y cajas.
Package mask: layers 1, 2 → colisiona con mundo y player.
