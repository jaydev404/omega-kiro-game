# Development Roadmap — Specs Priorizados

> Orden de implementación incremental. Cada spec es probeable de forma aislada.

---

## Fase 1 — Core Loop Básico (ya implementado parcialmente)

- [x] Player movement + sprint
- [x] Package pickup/drop
- [x] Drone spawner
- [x] Delivery truck (punto de entrega)
- [x] Push physics

## Fase 2 — Sistema de Vida y Daño

**Spec: `health-system`**
- PlayerStats Resource con corazones y fragmentos
- RuntimePlayerStats como nodo del Player
- Daño, invulnerabilidad con parpadeo
- Game Over al llegar a 0
- HUD de corazones

Prueba: el player recibe daño (con un trigger de prueba) y muere.

## Fase 3 — Bombas

**Spec: `bombs`**
- BombData Resource
- BombImmediate.tscn (explota al caer)
- BombTimer.tscn (countdown, parpadeo, recogible, lanzable)
- Integración con DroneSpawner (DropTable)
- Daño al player en radio

Prueba: drones sueltan bombas, el player recibe daño al estar en el radio.

## Fase 4 — Match Timer y Game States

**Spec: `game-manager`**
- GameManager singleton
- Timer de 25 min
- Estados: MENU → PLAYING → ENDGAME → GAME_OVER → SUMMARY
- Evento final (bombardeo masivo)
- Bonus por supervivencia

Prueba: partida inicia, timer corre, a los 25 min entra el bombardeo.

## Fase 5 — XP y Level Up

**Spec: `xp-leveling`**
- LevelUpConfig Resource
- XP al entregar paquetes
- Ventana de selección al subir de nivel
- Mejoras temporales aplicadas a RuntimePlayerStats

Prueba: entregar paquetes da XP, al llenar la barra aparece la selección.

## Fase 6 — Economía y Dinero

**Spec: `economy`**
- Dinero por entrega (diferente de XP)
- Dinero persistente en PlayerStats
- Pantalla de resumen post-partida

Prueba: ganar dinero en partida, ver el total acumulado al terminar.

## Fase 7 — Múltiples Tipos de Paquete y Puntos de Entrega

**Spec: `package-types`**
- PackageTypeData Resources (A, B, C mínimo)
- Múltiples DeliveryPoints en el escenario
- Desbloqueo progresivo por DifficultyPhase
- Colores/formas placeholder diferentes por tipo

Prueba: aparecen paquetes de distintos tipos, cada uno va a su punto.

## Fase 8 — Drops Variados (Monedas, Power-ups, Sorpresas)

**Spec: `drops`**
- DropTable Resource
- Coin.tscn (auto-recoger al tocar)
- PowerUpDrop.tscn (auto-recoger, ventana de stat)
- SurprisePackage.tscn (se revela al recoger)
- Integración con DroneSpawner

Prueba: drones sueltan variedad de items, cada uno funciona correctamente.

## Fase 9 — Curva de Dificultad

**Spec: `difficulty-system`**
- DifficultyPhase Resources (una por tramo de tiempo)
- DroneSpawner lee la fase activa según el timer
- Más drones, más rápidos, más bombas con el tiempo

Prueba: la partida se siente progresivamente más difícil.

## Fase 10 — Tienda de Power-ups Permanentes

**Spec: `upgrade-shop`**
- PermanentUpgrade Resources
- UI de tienda en pantalla de inicio
- Compra → modifica PlayerStats → SaveManager persiste

Prueba: comprar velocidad, iniciar partida y notar el cambio.

## Fase 11 — Destrucción por Apilamiento

**Spec: `package-collision`**
- Detección de drop sobre paquete existente
- Destrucción de ambos con efecto visual
- Daño en radio al player

Prueba: dron suelta sobre otro paquete, ambos explotan.

## Fase 12 — Pantalla de Inicio y Flujo Completo

**Spec: `main-menu`**
- Pantalla con Jugar / Power-ups / Salir
- Dinero visible
- Transiciones entre escenas

## Fase 13 — Dron Aliado (post-MVP)

**Spec: `ally-drone`**
- NPC con pathfinding simple
- Recoge paquetes, los entrega
- Más lento que el player
- No recibe daño

---

## Dónde viven los valores parametrizables

| Dato | Archivo | Tipo |
|---|---|---|
| Stats base del player | `Resources/PlayerStats.tres` | Resource |
| Tabla de XP | `Resources/LevelUpConfig.tres` | Resource |
| Config de partida | `Resources/MatchConfig.tres` | Resource |
| Fases de dificultad | `Resources/Difficulty/phase_*.tres` | Resource[] |
| Tipos de paquete | `Resources/Packages/type_*.tres` | Resource[] |
| Datos de bomba | `Resources/Bombs/bomb_*.tres` | Resource[] |
| Tabla de drops | `Resources/DropTable.tres` | Resource |
| Upgrades de tienda | `Resources/Upgrades/upgrade_*.tres` | Resource[] |

Todos editables desde el inspector de Godot sin tocar código.
