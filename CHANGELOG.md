# Changelog

## [0.5.5] - 2025 — WASD, fix flechas ayuda y sprites AtlasTexture

### Añadido

- `project.godot` — WASD mapeado en `ui_left/right/up/down` junto a flechas de cursor. El jugador puede moverse con ambos esquemas
- `ChaosMainMenu.gd` — W/S navegan el menú principal igual que flechas ↑/↓
- `HelpScreen.gd` — A/D cambian pestañas igual que flechas ←/→

### Corregido

- `HelpScreen.gd` — `_unhandled_input` → `_input` para que las flechas funcionen aunque un Button tenga foco. `release_focus()` en todos los botones al abrir
- `HelpScreen.tscn` — sprites de camiones (ids 8,9,10) usan `AtlasTexture` mostrando solo el primer frame 16×16
- `HelpScreen.tscn` — tutorial actualizado a "WASD / Flechas"
- `ChaosMainMenu.tscn` / `ChaosGame.tscn` — eliminado `BtnHelp` flotante `?`

---

## [0.5.4] - 2025 — Shield counter, batch delivery fix y preparación para demo web

### Añadido

- `ShieldLabel` en HUDPanel — label "x1", "x2"... junto al ShieldIcon, visible solo cuando hay escudos activos. Color azul claro para diferenciarlo del resto del HUD

### Modificado

- `PlayerController.gd` — `has_shield: bool` reemplazado por `shield_count: int`. El escudo ahora es acumulable (múltiples level-ups de escudo se suman)
- `PlayerHealth.gd` — al recibir daño decrementa `shield_count -= 1` en lugar de poner a `false`
- `GameManager._on_power_shield()` — incrementa `shield_count += 1`
- `GameManager._update_shield_icon()` — actualiza visibilidad y texto del `ShieldLabel`
- `ChaosMainMenu.tscn` — `DebugSavePanel` ocultado (`visible = false`) para la demo pública. El panel sigue en escena para poder reactivarlo en desarrollo
- `.gitignore` — añadido `export_presets.cfg` (contiene rutas locales, no debe commitearse)

### Notas de deploy (demo web)

- Export preset Web configurado con `index.html` como nombre de salida
- Carpeta de export: `export/web/` (fuera del proyecto, no commiteada)
- Plataforma recomendada: itch.io (soporta headers COOP/COEP requeridos por Godot 4 Web)
- Viewport configurado en itch.io: 1280×704
- DEV_MODE en Shop.gd ya estaba en `false` desde el PR anterior

---



### Añadido

- `DeliveryProgressUI.gd` — `Node2D` instanciado dinámicamente sobre el player durante entrega múltiple. Dibuja texto "Entregando Nx..." con puntos animados y barra de progreso verde. Se destruye automáticamente al terminar

### Modificado

- `PlayerCarry.gd` — `_deliver()` reemplazado por lógica batch:
  - Recopila todos los paquetes que la zona acepta (no solo el último)
  - 1 paquete: entrega instantánea sin bloqueo ni UI
  - 2+ paquetes: delay según cantidad, player inmóvil, UI de progreso visible
  - Duración: 2-3 paquetes = 0.8s, 4-5 = 1.5s, 6+ = 2.5s
  - Señales nuevas: `batch_delivery_started(count, duration)`, `batch_delivery_finished()`
  - `is_delivering()` expuesto públicamente
- `PlayerController.gd` — `set_delivery_locked(bool)` + `_delivery_locked` flag. Bloquea `_physics_process` completamente durante la entrega
- `PlayerInteraction.gd` — ignora input de E mientras `_carry.is_delivering()` es true

---



### Modificado

- `GameManager.gd` — `match_duration` reducido de 1500s a 600s (10 min). `third_package_unlock_time` ajustado a 360s (minuto 4). `endgame_duration` sin cambio (bombardeo últimos 30s = minuto 9:30)
- `Scripts/DifficultyConfig.gd` — comentarios y grupos actualizados con tiempos de 10 min. `start_at` defaults recalculados
- `Resources/DifficultyConfig.tres` — curva de dificultad recalculada para 10 minutos:

| Fase | Tiempo | start_at | Drones | Intervalo | Velocidad | Bombas | Persecución |
|---|---|---|---|---|---|---|---|
| 0 Intro | 0:00 | 600s | 3 | 5.0s | 120 | 5% | 1% |
| 1 Normal | 2:00 | 480s | 4 | 3.5s | 155 | 12% | 6% |
| 2 Presión | 4:00 | 360s | 5 | 2.5s | 190 | 22% | 12% |
| 3 Caos | 7:00 | 180s | 7 | 1.8s | 230 | 32% | 20% |
| 4 Sprint | 9:00 | 60s | 10 | 1.2s | 270 | 42% | 28% |

---



### Modificado

- `GameManager.gd` — timer del HUD ahora muestra tiempo transcurrido (00:00 → 25:00) en lugar de cuenta regresiva. `_elapsed_time` sube desde 0; `_match_timer` sigue contando hacia abajo internamente para las fases de dificultad y el evento final
- `ChaosGame.tscn` — TimerLabel inicia en "00:00"
- `ChaosGame.tscn` — hint "↑ ↓ mover  •  Enter / Espacio seleccionar" añadido al pie del PowerUpMenu

---



### Añadido

#### Pantalla de Ayuda (HelpScreen)
- `HelpScreen.tscn` + `HelpScreen.gd` — pantalla reutilizable instanciada en el menú principal y en el HUD del juego
- Dos pestañas navegables con botones `◀ ▶` y flechas izquierda/derecha del teclado:
  - **CÓMO JUGAR**: descripción del juego, controles (WASD/Shift/E/Esc) y objetivo
  - **ITEMS**: cada item con icono (TextureRect + AtlasTexture para sprites animados), nombre y descripción en filas `HBoxContainer`
- Sprites con múltiples frames (GoldCoin/SilverCoin/Ruby/Bomb) recortados al primer frame 16×16 usando `AtlasTexture` como sub-recurso
- Hint de navegación al pie de la pestaña CÓMO JUGAR: "Navega con ↑ ↓  •  Confirma con Enter o Espacio"
- Cerrar con botón "Cerrar [Esc]" o tecla Esc; consume todo el input de teclado mientras está visible

#### Botón Ayuda en menú principal
- `BtnHelpSprite` — cuarto botón del menú principal usando el mismo `AnimatedSprite2D` que los demás
- Orden final: Comenzar → Tienda → Ayuda → Salir
- Navegación por teclado actualizada a 4 opciones
- `HelpScreen` envuelta en `CanvasLayer` en ambas escenas para centrarse en viewport correctamente

### Corregido

- `ChaosMainMenu._is_over()` — ahora usa `get_viewport().get_canvas_transform()` para convertir coordenadas mundo a viewport; corrige que el click en botones no funcionaba
- `HelpScreen` — Space/Enter ya no cierran la pantalla (solo Esc); evita conflicto con la navegación del menú principal
- `HelpScreen` — `set_input_as_handled()` consume todo el input de teclado mientras está visible; evita que llegue al menú de fondo
- Items tab — `Sprite2D` reemplazado por `TextureRect` para participar correctamente en el layout `HBoxContainer`



### Añadido

#### Navegación por teclado en menús
- `PowerUpMenu.gd` — script para el menú de power-ups en partida:
  - Flecha `▶` aparece solo cuando el jugador presiona ↑/↓ por primera vez
  - Enter/Space confirma la selección
  - Al abrir el menú se enfoca el primer botón automáticamente
  - Mouse sigue funcionando en paralelo
- `KeyboardMenu.gd` — script genérico reutilizable para menús con `Button` de Godot:
  - Adjuntado a GameOverMenu, ReviveMenu y PauseMenu en ChaosGame.tscn
  - Detecta botones del VBoxContainer automáticamente
  - Flecha `▶` oculta hasta primera pulsación de teclado
  - Mouse desactiva la flecha al mover
- `ChaosMainMenu.gd` — navegación por teclado en menú principal:
  - Funciona con los `AnimatedSprite2D` custom (no usa Button de Godot)
  - ↑/↓ navega entre Comenzar/Tienda/Salir, muestra flecha `▶` al activarse
  - Enter/Space confirma, mouse desactiva la flecha

### Corregido

- `SurpriseBox.gd` — fix definitivo del bug de monedas/ruby no recogibles:
  - Durante la animación de aparición (0.3s) se desactivan las colisiones físicas del item
  - Al terminar la animación se reactivan — Godot dispara `body_entered` como una entrada nueva
  - Eliminado el enfoque fallido de `force_collect` que causaba el bloqueo total
- `ChaosMainMenu.gd` / `KeyboardMenu.gd` — fix `set_input_as_handled()` sobre viewport nulo al cambiar escena

### Documentado (PR #8 del compañero)

- Fase 13 (Dron Aliado) marcada como completada en roadmap
- `HelperDroneCat.gd`: estados IDLE→MOVING_TO_PACKAGE→PICKING_UP→MOVING_TO_DELIVERY→DELIVERING→WAITING
- Shop rediseñada con barras ColorRect custom, DEV_MODE=false en producción
- DebugSavePanel con botones ±inline para cada stat



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
