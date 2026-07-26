# Changelog

## [0.3.0] - 2025 — Tienda Completa y MVP Cerrado (Fase 10-12)

### Añadido

#### Tienda de Power-ups Permanentes (Fase 10)
- **Corazones** (max 3): precios fijos $10/$20/$50 por nivel, +1 corazón permanente por nivel
  - `PlayerHealth.init_hearts()` — método público para aplicar corazones desde save con recálculo de fragmentos y actualización de HUD
  - `call_deferred` garantiza que el HUD esté listo al iniciar partida
- **Revivir** ($100, 1 compra única): se activa 1 vez por partida al morir
  - `ReviveMenu` en ChaosGame.tscn — pantalla de revive (fondo azul) con botón "Revivir" y "Volver al Menú"
  - Al revivir: vida completa restaurada, puntaje/tiempo/estadísticas conservados, juego reanuda
  - `SaveManager.revive_used` se resetea al inicio de cada partida (no persiste)
- **Dev Mode** en Shop.gd (`const DEV_MODE := true`):
  - Todas las compras son gratis
  - Botón MAX TODO: sube todos los upgrades al máximo instantáneamente
  - Label en tiempo real: `Vel: xN  Cant: xN  HP: xN  Rev: SI/NO`
- Límites ajustados: Velocidad max nivel 5, Capacidad max nivel 3

### Modificado

- `SaveManager.gd` — añadidos `hp_level`, `has_revive`, `revive_used`; `get_effective_max_hearts()` retorna `base_max_hearts + hp_level`
- `Shop.gd` — reescrito con `MAX_VEL_LEVEL=5`, `MAX_CANT_LEVEL=3`, filas HpRow y ReviveRow, dev mode completo
- `Shop.tscn` — añadidas filas HpRow (barra max 3) y ReviveRow (precio $100, descripción "1 uso por partida")
- `GameManager.gd` — `game_over()` bifurca entre ReviveMenu y GameOverMenu según disponibilidad del revive; `_on_revive()` restaura vida y reanuda
- `PlayerHealth.gd` — nuevo método `init_hearts(hearts)` para inicialización desde save
- `ChaosGame.tscn` — añadido nodo `ReviveMenu` con Panel, VBoxContainer, BtnRevive y BtnGoMenu
- `docs/dev-roadmap.md` — Fases 10 y 12 marcadas como completadas; MVP cerrado (Fase 13 post-MVP)

---

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
- `Shop.gd` — migrado a SaveManager, eliminados los bloques FileAccess directos
- `PlayerCarry.gd` — `is_instance_valid()` en todos los puntos de acceso a paquetes
- `PlayerInteraction.gd` — respeta `pickup_blocked` en auto-recogida de monedas y ruby

### Corregido

- `Bomb.tscn` — `package_type` corregido de 2 a 3 (desplazamiento por THIRDBOX en enum)
- `Ruby.tscn` — `package_type` corregido de 3 a 4
- `GoldCoin.tscn` — `package_type` corregido de 4 a 5
- `SilverCoin.tscn` — `package_type` corregido de 5 a 6
- Bomba sostenida que explota ya no deja referencia sucia en `PlayerCarry._carried_packages`
- Bomba revelada por SurpriseBox explota inmediatamente (pick_up + drop)
- Moneda dorada de SurpriseBox apunta a `Packages/GoldCoin.tscn` (recogible)

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
