# Development Roadmap — Specs Priorizados

> Orden de implementación incremental. Cada spec es probeable de forma aislada.

---

## Fase 1 — Core Loop Básico (ya implementado parcialmente)

- [x] Player movement + sprint
- [x] Package pickup/drop
- [x] Drone spawner
- [x] Delivery truck (punto de entrega)
- [x] Push physics

## Fase 2 — Sistema de Vida y Daño ✅

**Spec: `health-system`** — COMPLETADO
- PlayerHealth.gd: corazones (@export max_hearts=1), fragmentos x4, invulnerabilidad 2s con parpadeo
- take_damage(amount): aplica daño, activa invulnerabilidad, emite died() al llegar a 0
- heal(amount) y add_max_heart(amount) para curación y aumento de máximo
- Escudo: absorbe un golpe y se consume (has_shield en PlayerController)
- HUD: AnimatedSprite2D Heart1..Heart5, frame 0-4 según fragmentos
- Game Over conectado a PlayerHealth.died → GameManager.game_over()
- Señales: health_changed, damaged, healed, died, invulnerability_started, invulnerability_ended


## Fase 3 — Bombas ✅

**Spec: `bombs`** — COMPLETADO
- BombImmediate: explota al caer, 2 fragmentos daño, radio 24px, apunta al player
- BombTimer: cae cerca del player, countdown 3s con parpadeo acelerado, recogible/lanzable, explota con radio 32px, 2 fragmentos daño
- Explosión usa sprWeaponBombExplosion.png (6 frames 32x32)
- Integración con DroneSpawner: 60% inmediata / 40% timer cuando sale bomba
- Daño pasa por PlayerHealth (fragmentos)

## Fase 4 — Match Timer y Game States ✅

**Spec: `game-manager`** — COMPLETADO
- Timer de 25 minutos con display MM:SS
- Estados: PLAYING → ENDGAME (últimos 30s) → GAME_OVER / VICTORIA
- Evento final: bombardeo masivo (+10 drones, 80% bombas, intervalo 0.3s)
- Bonus por supervivencia: +10 monedas al completar los 25 min
- Victoria muestra puntaje final y guarda monedas

## Fase 5 — XP y Level Up ✅

**Spec: `xp-leveling`** — COMPLETADO
- PlayerXP script: gana XP al entregar paquetes (10 XP por entrega)
- Barra de XP en HUD panel (5 frames: vacío → lleno)
- Al llenar la barra: sube de nivel, muestra menú de power-up (+Vel, +Cant, Escudo)
- XP necesaria escala x1.5 por nivel (30, 45, 67, 101...)
- Barra se actualiza visualmente frame a frame según progreso

## Fase 6 — Economía y Dinero ✅

**Spec: `economy`** — COMPLETADO
- Dinero ganado en partida via monedas (GOLD_COIN +5, SILVER_COIN +1) y bonus de supervivencia (+10)
- SaveManager centraliza toda la persistencia en `user://save.json` (JSON extensible)
- Stats base parametrizables desde constantes en `SaveManager.gd`
- `_load_save()` en GameManager aplica stats efectivos al player al inicio de cada partida
- `_save_run()` persiste monedas al terminar (victoria o game over)
- Shop.gd migrado a SaveManager
- Panel de debug en ChaosMainMenu con botón RESET SAVE
- Pantalla de resumen muestra monedas ganadas en la run y total acumulado
- Bug fix: bomba explotando mientras está cargada ya no deja referencia sucia

## Fase 7 — Múltiples Tipos de Paquete y Puntos de Entrega ✅

**Spec: `package-types`** — COMPLETADO
- 3 tipos de paquete: BOX (type 0), BLUEPOT (type 1), THIRDBOX (type 2)
- 3 puntos de entrega fijos: DeliveryTruck (BOX), DeliveryTruckBluePot (BLUEPOT), DeliveryTruckThird (THIRDBOX)
- Escena ThirdBox.tscn — placeholder verde (misma base que BluePot, modulate verde)
- Escena DeliveryTruckThird.tscn — camión verde con accepted_type=2
- DroneSpawner refactorizado: array `_active_delivery_scenes` en lugar de `randf() < 0.5` hardcodeado
- Selección uniforme aleatoria entre todos los paquetes activos
- `enable_third_package()` agrega THIRDBOX al array al ser llamado
- GameManager dispara `enable_third_package()` cuando `_match_timer <= 1200.0` (minuto 5)
- `third_package_unlock_time` es `@export` — ajustable desde el inspector
- Para activar: instanciar DeliveryTruckThird en ChaosGame.tscn y asignar ThirdBox.tscn al campo `third_package_scene` del DroneSpawner

## Fase 8 — Drops Variados (Monedas, Power-ups, Sorpresas) ✅

**Spec: `drops`** — COMPLETADO
- GoldCoin (+5 monedas), SilverCoin (+1 moneda) — auto-recogida al tocar, timer periódico en DroneSpawner
- Ruby — drop especial cada 5 entregas, abre menú de power-up temporal (+Vel, +Cant, Escudo)
- SurpriseBox (tipo SURPRISE=8) — caja morada con `?`, al presionar E revela aleatoriamente:
  - 50% GoldCoin, 30% Ruby, 20% Bomba inmediata
  - Animación bounce de aparición (scale 0→1.3→1.0), pickup bloqueado 0.3s para feedback visual
  - Bomba revelada explota inmediatamente con pick_up()+drop()
- Integración con DroneSpawner: `surprise_box_scene` + `surprise_chance = 0.08`
- `pickup_blocked` flag en PackageBody previene auto-recogida durante la animación
- Bug fix: package_type enum desincronizado con escenas `.tscn` corregido en todas las escenas
- Bug fix: bomba desde SurpriseBox explota correctamente

## Fase 9 — Curva de Dificultad ✅

**Spec: `difficulty-system`** — COMPLETADO
- `DifficultyConfig.gd` — Resource centralizado con 5 fases de dificultad configurables
- `Resources/DifficultyConfig.tres` — archivo editable desde el inspector de Godot
- DroneSpawner lee la fase activa via `apply_difficulty_phase(phase)`
- GameManager evalúa `_check_difficulty_phase()` cada frame y dispara transiciones
- Mecánica de persecución ya existente: `chase_chance` en DroneSpawner, estados FLYING_IN→CHASING→DROPPING en Drone.gd

| Tiempo | Fase | Drones | Intervalo | Velocidad | Bombas | Persecución |
|---|---|---|---|---|---|---|
| 0:00 - 2:00 | 0 | 3 | 5.0s | 120 | 5% | 1% |
| 2:00 - 5:00 | 1 | 4 | 4.0s | 150 | 10% | 5% |
| 5:00 - 10:00 | 2 | 5 | 3.0s | 180 | 18% | 10% |
| 10:00 - 18:00 | 3 | 7 | 2.0s | 220 | 28% | 18% |
| 18:00 - 25:00 | 4 | 10 | 1.2s | 260 | 38% | 25% |

Para modificar: DroneSpawner inspector → campo **Difficulty Config** → asignar `DifficultyConfig.tres`

## Fase 10 — Tienda de Power-ups Permanentes ✅

**Spec: `upgrade-shop`** — COMPLETADO
- **Velocidad** (max nivel 5): cada nivel +15 px/s de velocidad base, coste escalado
- **Capacidad de carga** (max nivel 3): cada nivel +1 paquete simultáneo, coste escalado
- **Corazones** (max nivel 3): precios fijos $10/$20/$50, +1 corazón permanente por nivel
  - `PlayerHealth.init_hearts()` aplica el total con recálculo de fragmentos y actualización del HUD
  - `call_deferred` garantiza que el HUD esté listo al iniciar partida
- **Revivir** (1 compra, $100): se activa 1 vez por partida al morir
  - Al morir con revive disponible: muestra `ReviveMenu` (fondo azul, botón Revivir + Volver al Menú)
  - Al revivir: vida completa restaurada, puntaje/tiempo/estadísticas conservados, juego reanuda
  - `SaveManager.revive_used` se resetea al inicio de cada partida
- **Dev Mode** (`const DEV_MODE := true` en Shop.gd):
  - Todas las compras son gratis ($0)
  - Botón **MAX TODO**: sube vel/cant/hp al máximo y activa revive
  - Botón **RESET**: llama `SaveManager.reset_all()` para empezar como jugador nuevo
  - Label en tiempo real: `Vel: xN  Cant: xN  HP: xN  Rev: SI/NO`
- Persistencia en `save.json` bajo `upgrades.*` via SaveManager


## Fase 11 — Destrucción por Apilamiento ✅

**Spec: `package-collision`** — COMPLETADO
- `_check_landing_collision()` en PackageBody detecta colisión con otro paquete al caer
- Si hay colisión: efecto DirtyExplosion.tscn en ambas posiciones, ambos se destruyen
- Si cae sobre el player (radio 16px): 1 fragmento de daño + destrucción del paquete
- Solo aplica a paquetes no-bomba y no-carried

## Fase 12 — Pantalla de Inicio y Flujo Completo ✅

**Spec: `main-menu`** — COMPLETADO
- ChaosMainMenu.tscn con botones Jugar, Tienda, Salir — estilo pixel art con sprites animados
- Transiciones a ChaosGame.tscn y Shop.tscn implementadas
- Monedas acumuladas visibles en menú (desde SaveManager)
- DebugSavePanel con botón RESET SAVE para testing
- Navegación por teclado: ↑/↓ mueve flecha `▶`, Enter/Space confirma (flecha oculta hasta primer uso)


## Fase 13 — Dron Aliado ✅

**Spec: `ally-drone`** — COMPLETADO por compañero
- `HelperDroneCat.gd` + `HelperDroneCat.tscn` — NPC autónomo con sprite de gato
- Estados: `IDLE → MOVING_TO_PACKAGE → PICKING_UP → MOVING_TO_DELIVERY → DELIVERING → WAITING`
- Solo recoge BOX, BLUEPOT y THIRDBOX que estén libres y no bloqueados
- Busca la zona de entrega correcta usando `DeliveryZone.accepts()`
- Si no encuentra zona: suelta el paquete en su posición actual
- Velocidad fija `@export speed = 100.0` (más lento que el player)
- No recibe daño
- Se activa al subir al nivel configurado en `helper_cat_spawn_level` (GameManager)
- 1 uso por partida: `SaveManager.has_helper = false` después de spawnear
- `DropMarker.gd` — efecto visual de marcador en zona de drop
- Tienda: precio $300, compra única, campo **HelperRow** en Shop.tscn

---

## Cambios adicionales del compañero (PR #8)

- **Shop.gd** completamente rediseñado visualmente con barras `ColorRect` custom
- **DebugSavePanel.gd** ampliado: botones `+/-` inline para editar cada stat desde el menú (coins ±1000, vel, cant, hp, toggle revive/helper)
- **SaveManager.gd** — `has_helper: bool` añadido, `coins` con setter `clampi(0, 99999999)`, `get_effective_move_speed()` cambiado a `vel_level * 5.0` (antes 15.0)
- **DEV_MODE** desactivado (`false`) en Shop.gd para producción
- **DeliveryZone.gd** — ajustes menores
- **Drone.gd** — ajustes de comportamiento

---

## Dónde viven los valores parametrizables

| Dato | Archivo | Cómo cambiar |
|---|---|---|
| Stats base del player (velocidad, carga, corazones, sprint) | `Scripts/SaveManager.gd` — constantes `DEFAULT_*` | Editar constante + RESET SAVE |
| Tabla de XP y crecimiento por nivel | `Scripts/Player/PlayerXP.gd` — `@export base_xp_to_level`, `xp_growth` | Inspector del nodo PlayerXP |
| Duración de la partida y evento final | `Scripts/GameManager.gd` — `@export match_duration`, `endgame_duration` | Inspector del nodo GameManager |
| Desbloqueo del 3er paquete | `Scripts/GameManager.gd` — `@export third_package_unlock_time` | Inspector del nodo GameManager |
| Curva de dificultad (velocidad, bombas, drones por fase) | `Resources/DifficultyConfig.tres` | Inspector del Resource o editor de texto |
| Velocidad base de drones | `Scripts/DifficultyConfig.gd` — `phase0_drone_speed` ... `phase4_drone_speed` | Editar DifficultyConfig.tres |
| Probabilidad de bombas por fase | `Scripts/DifficultyConfig.gd` — `phase0_bomb_chance` ... `phase4_bomb_chance` | Editar DifficultyConfig.tres |
| Probabilidad de persecución por fase | `Scripts/DifficultyConfig.gd` — `phase0_chase_chance` ... `phase4_chase_chance` | Editar DifficultyConfig.tres |
| Daño y radio de bombas | `Scripts/Package/PackageBody.gd` — `@export bomb_radius`, `bomb_damage` | Inspector del nodo bomba |
| Costo base de tienda y máx nivel | `Scripts/UI/Shop.gd` — `const MAX_VEL_LEVEL`, `MAX_CANT_LEVEL`, `MAX_HP_LEVEL`, `REVIVE_COST`, `HP_COSTS` | Editar constantes |
| Activar/desactivar modo dev tienda | `Scripts/UI/Shop.gd` — `const DEV_MODE` | Cambiar a `false` para producción |
| Bonus por nivel de tienda (velocidad) | `Scripts/SaveManager.gd` — `get_effective_move_speed()` multiplica `vel_level * 15.0` | Editar el multiplicador |
| Probabilidades SurpriseBox | `Scripts/Package/SurpriseBox.gd` — `@export chance_gold_coin`, `chance_ruby`, `chance_bomb` | Inspector del nodo SurpriseBox |

Todos editables sin tocar la lógica de juego.
