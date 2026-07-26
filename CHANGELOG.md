# Changelog

## [0.2.0] - 2025 — Core Gameplay Completo (Fases 6-11)

### Añadido

#### Economía y Persistencia (Fase 6)
- `SaveManager.gd` — Singleton autoload, fuente de verdad única para todos los datos persistentes
- Persistencia en `user://save.json` (JSON extensible, reemplaza los archivos binarios)
- Stats base parametrizables via constantes `DEFAULT_*` en `SaveManager.gd`
- Panel de debug `DebugSavePanel` en ChaosMainMenu con botón RESET SAVE
- Pantalla de Game Over muestra monedas ganadas en la run y total acumulado

#### Múltiples Tipos de Paquete (Fase 7)
- Tercer tipo de paquete: `ThirdBox.tscn` (placeholder verde, tipo 2)
- Tercer punto de entrega: `DeliveryTruckThird.tscn` (accepted_type=2)
- Desbloqueo automático del tercer paquete al minuto 5 (`third_package_unlock_time`)
- DroneSpawner refactorizado: array `_active_delivery_scenes` reemplaza el 50/50 hardcodeado

#### Drops Variados (Fase 8)
- `SurpriseBox.gd` + `SurpriseBox.tscn` — caja morada con `?`
- Al recoger con E revela aleatoriamente: GoldCoin (50%), Ruby (30%), Bomba inmediata (20%)
- Animación bounce de aparición (scale 0→1.3→1.0) con delay de recogida de 0.3s
- Flag `pickup_blocked` en `PackageBody` para prevenir auto-recogida durante animación
- `SurpriseVisual.gd` — visual placeholder morado con `?` dibujado por código

#### Curva de Dificultad (Fase 9)
- `DifficultyConfig.gd` — Resource centralizado con 5 fases de dificultad
- `Resources/DifficultyConfig.tres` — editable desde el inspector de Godot sin tocar código
- GameManager evalúa fases por tiempo y aplica parámetros via `apply_difficulty_phase()`
- Mecánica de persecución de drones activa: `chase_chance` escala con la fase

### Modificado

- `PackageBody.gd` — enum `PackageType` ampliado con `THIRDBOX` y `SURPRISE`
- `PackageBody.gd` — añadido `pickup_blocked: bool` y método `deliver()` con fade out
- `DroneSpawner.gd` — `@export difficulty_config: DifficultyConfig`, `apply_difficulty_phase()`, `enable_third_package()`
- `GameManager.gd` — `_load_save()` / `_save_run()` reemplazan los 3 métodos FileAccess dispersos
- `GameManager.gd` — `_check_difficulty_phase()` y `_show_summary()` para resumen post-partida
- `GameManager.gd` — trigger de Fase 9 por tiempo integrado en `_process()`
- `Shop.gd` — migrado a SaveManager, eliminados los bloques FileAccess directos
- `PlayerCarry.gd` — `is_instance_valid()` en todos los puntos de acceso a paquetes
- `PlayerCarry.gd` — detección de SURPRISE en `_try_pick_up()` via `has_method("reveal_at")`
- `PlayerInteraction.gd` — respeta `pickup_blocked` en auto-recogida de monedas y ruby

### Corregido

- `Bomb.tscn` — `package_type` corregido de 2 a 3 (desplazamiento por THIRDBOX en enum)
- `Ruby.tscn` — `package_type` corregido de 3 a 4
- `GoldCoin.tscn` — `package_type` corregido de 4 a 5
- `SilverCoin.tscn` — `package_type` corregido de 5 a 6
- Bomba sostenida que explota ya no deja referencia sucia en `PlayerCarry._carried_packages`
- Bomba revelada por SurpriseBox explota inmediatamente (pick_up + drop)
- Moneda dorada de SurpriseBox apunta a `Packages/GoldCoin.tscn` (recogible) en vez de `Items/GoldCoin.tscn`

---

## [0.1.0] - 2025 — Core Loop y Sistemas Base (Fases 1-5)

### Añadido

- Player: movimiento WASD, sprint (Shift), carry stack, interacción (E)
- PackageBody: física de empuje, estados FREE/CARRIED, z-index al cargar
- DroneSpawner: spawn periódico, detección de posición libre, modo persecución
- DeliveryTruck: StaticBody2D + DeliveryZone con accepted_type por camión
- PlayerHealth: corazones, fragmentos x4, invulnerabilidad 2s con parpadeo
- Bombas: BombImmediate y BombTimer con daño en radio, recogible/lanzable
- GameManager: timer 25 min, estados PLAYING→ENDGAME→GAME_OVER, evento final
- PlayerXP: barra XP, level up con selección de power-up temporal
- Drops: GoldCoin, SilverCoin, Ruby con auto-recogida al tocar
- Destrucción por apilamiento: DirtyExplosion al caer sobre otro paquete
