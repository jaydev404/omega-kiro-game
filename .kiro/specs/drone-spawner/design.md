# Drone Spawner — Design

## Escenas

```
DroneSpawner.tscn
└── Node2D                   ← raíz, contiene lógica y puntos de referencia
    ├── DroneSpawner.gd      ← controla el ciclo: timer → spawn → esperar → repeat
    ├── SpawnOrigin (Marker2D)  ← punto de entrada/salida del dron (fuera de pantalla)
    ├── DropPoint (Marker2D)    ← donde el dron deposita la caja
    └── Drone (instancia de Drone.tscn, creada/destruida dinámicamente)

Drone.tscn
└── Node2D
    ├── Drone.gd             ← movimiento y ciclo de vida del dron
    └── DroneVisual.gd       ← placeholder: rectángulo gris oscuro con rotores dibujados
```

## Scripts

### DroneSpawner.gd
Responsabilidades:
- `Timer` interno que dispara el intento de spawn.
- Conteo de cajas activas (`_active_count`).
- Al disparar el timer: si `_active_count < max_packages` y no hay dron en vuelo,
  instancia `Drone.tscn` y le pasa las posiciones de `SpawnOrigin` y `DropPoint`.
- Conecta la señal `package_dropped` de cada `PackageBody` para decrementar
  el conteo cuando el player recoge una caja.
- Señales emitidas: `package_spawned(package)`, `spawn_blocked(reason)`.

### Drone.gd
Estados: `FLYING_IN → DROPPING → FLYING_OUT → DONE`

- `FLYING_IN`: se mueve de `SpawnOrigin` a `DropPoint` a velocidad constante.
- `DROPPING`: instancia `Package.tscn` en `DropPoint`, espera un frame, emite
  `package_delivered(package)` y transiciona a `FLYING_OUT`.
- `FLYING_OUT`: se mueve de regreso a `SpawnOrigin`.
- `DONE`: emite `drone_finished()` y llama `queue_free()`.

Señales: `package_delivered(package: PackageBody)`, `drone_finished()`

### DroneVisual.gd
- Dibuja un rectángulo gris oscuro (cuerpo del dron).
- Dibuja dos círculos pequeños en los costados (rotores placeholder).

## Flujo Completo

```
Timer dispara
    ↓
DroneSpawner verifica límite y DropPoint libre
    ↓
Instancia Drone en SpawnOrigin
    ↓
Drone vuela a DropPoint (FLYING_IN)
    ↓
Drone instancia Package en DropPoint (DROPPING)
    ↓
DroneSpawner recibe package_delivered → _active_count++
    ↓
Drone vuela de regreso (FLYING_OUT)
    ↓
Drone se destruye (DONE)
    ↓
Player recoge caja → PackageBody.picked_up → _active_count--
```

## Collision Layers

El dron no tiene colisión física. Es puramente visual durante el vuelo.
