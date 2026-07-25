# Sistema de Drops

Tipologia completa de todos los objetos que los drones pueden soltar.

---

## Tipos de Drop

| Tipo | Escena | Recogida | Collision Layer |
|---|---|---|---|
| Paquete | Package.tscn | Tecla E | 3 (package) |
| Moneda | Coin.tscn | Auto al tocar (Area2D) | 5 (pickup) |
| Power-up | PowerUpDrop.tscn | Auto al tocar (Area2D) | 5 (pickup) |
| Bomba Inmediata | BombImmediate.tscn | No se recoge | 6 (hazard) |
| Bomba Timer | BombTimer.tscn | Tecla E (recoger y lanzar) | 6 (hazard) |
| Paquete Sorpresa | SurprisePackage.tscn | Tecla E | 3 (package) |

---

## Paquete (Package)

- Varios tipos (A, B, C...) definidos por PackageTypeData Resource.
- Cada tipo tiene color, punto de entrega, recompensa XP y dinero.
- Se recoge con E, se carga, se lleva al punto de entrega correcto.
- Ocupa 1 slot de capacidad de carga.

---

## Moneda (Coin)

- Area2D que detecta al Player.
- Al entrar en contacto: se recoge automaticamente.
- Efecto: suma dinero inmediato (money_earned += coin_value).
- Visual: circulo dorado parpadeante (placeholder).
- coin_value: configurable por Resource.
- Se destruye al ser recogida.

---

## Power-up Drop (PowerUpDrop)

- Area2D que detecta al Player.
- Al entrar en contacto: se recoge automaticamente.
- Efecto: abre ventana de seleccion de stat (misma que level up).
- Visual: estrella verde parpadeante (placeholder).
- Se destruye al ser recogido.
- La ventana pausa el juego hasta que el jugador elige.

---

## Bomba Inmediata (BombImmediate)

- Explota al contacto con el suelo (instantaneo al ser dejada por el dron).
- El dron la suelta y explota inmediatamente.
- Dano: 2 fragmentos.
- Radio: 64 px.
- Visual: destello rojo + circulo de radio (placeholder).
- No se puede recoger ni interactuar.
- Indicador previo: el dron parpadea en rojo antes de soltar (aviso al jugador).

---

## Bomba Timer (BombTimer)

- El dron la suelta, llega al suelo, comienza countdown.
- Timer: 3 segundos (configurable).
- Visual: parpadeo que se acelera conforme se acerca la explosion.
- Dano: 2 fragmentos.
- Radio: 80 px.
- El jugador PUEDE recogerla con E y lanzarla lejos.
- Al lanzar: vuela en la direccion del facing del player.
- Si explota mientras el player la carga: recibe dano completo.

---

## Paquete Sorpresa (SurprisePackage)

- Se ve como un paquete normal pero con indicador de "?" (placeholder).
- Se recoge con E como un paquete normal.
- Al recogerlo se REVELA aleatoriamente como:
  - Moneda (50% sugerido)
  - Power-up (30% sugerido)
  - Bomba timer (20% sugerido, comienza countdown al revelarse)
- Probabilidades configurables por Resource.

---

## DropTable (probabilidades de spawn)
package_weight: 0.5 -> 50% de probabilidad coin_weight: 0.2 -> 20% powerup_weight: 0.1 -> 10% bomb_weight: 0.15 -> 15% surprise_weight: 0.05 -> 5%


El DroneSpawner usa DropTable para decidir que cargar en cada dron.
Las probabilidades se pueden modificar por DifficultyPhase.

---

## Collision Layers sugeridos (actualizacion)

| Layer | Nombre | Uso |
|---|---|---|
| 1 | world | Paredes, bordes |
| 2 | player | Player |
| 3 | package | Paquetes y sorpresas |
| 4 | delivery_zone | Puntos de entrega |
| 5 | pickup | Monedas y power-ups (auto-recoger) |
| 6 | hazard | Bombas |

