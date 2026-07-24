# Changelog - Omega Kiro Game

## Resumen de todos los cambios y ajustes realizados

---

## Sistema de Drones (DroneSpawner / Drone)

### Spawn desde cualquier lado
- Los drones ahora aparecen desde cualquier borde de la pantalla (arriba, abajo, izquierda, derecha) de forma aleatoria.
- Se eliminaron los markers fijos `SpawnOrigin` y `DropPoint` de la escena `DroneSpawner.tscn`.
- Toda la lógica de posición es dinámica basada en el viewport.

### Drop inteligente
- El dron elige posición de drop aleatoria dentro del área de juego.
- Evita soltar objetos sobre los camiones (radio de exclusión de 100px).
- 30% de probabilidad de apuntar al player (`target_player_chance`).
- Si no encuentra posición libre, usa una aleatoria de todas formas (nunca se bloquea).

### Múltiples objetos
- El drone alterna entre 3 tipos de objetos: Box, BluePot y Bomb.
- 90% probabilidad de Box/BluePot (50/50 entre ellos).
- 10% probabilidad de Bomb (aumenta 1% por cada entrega, máximo 50%).

### Bomba
- Cuando el drone lleva una bomba, siempre apunta a la posición actual del player.
- La bomba explota al caer: ejecuta efecto `BombExplosion`.
- Objetos pegados a la bomba (radio 48px - lados y diagonales) son destruidos con efecto `DirtyExplosion`.
- Las bombas no cuentan como paquetes activos.

### Dificultad progresiva
- Cada 10 segundos: velocidad del drone +30px/s, intervalo de spawn -0.3s (mínimo 1s).
- Cada 2 puntos de puntaje: +1 drone concurrente.
- Intervalo inicial: 1 segundo.
- Drones concurrentes iniciales: 3.
- Un nuevo drone solo sale cuando otro desaparece (control por `_drones_in_flight`).

### Corrección de bugs
- Eliminado `await` que causaba drones congelados al soltar objetos.
- Implementado timer interno (`_drop_wait`) para el estado DROPPING.
- `_move_to()` detecta "pasó de largo" para evitar oscilación con velocidades altas.
- Timeout de seguridad: drone se autodestruye a los 15 segundos si se queda pegado.
- Validaciones en `_try_release_package()` para paquetes inválidos o escena nula.

---

## Player

### Sprite animado
- Reemplazado placeholder circular por `AnimatedSprite2D`.
- Usa sprite sheets de `Assets/Player/Move/` (sprZinkWalk E/W/N/S).
- Cada sheet es 96x48 (2 frames de 48x48).
- 4 animaciones de caminar: `walk_up`, `walk_down`, `walk_left`, `walk_right`.
- Scale: 2x para igualar el tamaño visual de las cajas.
- Al detenerse en dirección lateral, muestra el frame con pies quietos (frame 1).

### Animación de carry
- Agregadas 4 animaciones de carry usando `Assets/Player/Action/` (sprZinkCarry E/W/N/S).
- `PlayerVisual.gd` alterna entre prefijo `walk_` y `carry_` según estado.
- `PlayerCarry` notifica al visual al agarrar/soltar (`set_carrying(true/false)`).

### Sistema de carry
- El objeto cargado siempre queda arriba del player (`Vector2.UP * carry_distance`).
- Al soltar, el objeto se coloca en la dirección donde mira el player con offset.
- No suelta si hay un objeto bloqueando la posición de drop (radio 18px, layers 4 y 1).
- No suelta/entrega si el camión es el equivocado (el player se queda con el objeto).
- Colisión se desactiva inmediatamente al agarrar (no `set_deferred`) para evitar empujar al player.
- `pick_up()` se llama ANTES de `reparent` para evitar desplazamiento.

### Eliminación del sistema de empuje
- El player ya no empuja objetos al colisionar.
- Se eliminaron: `push_force`, `max_push_count`, `_count_packages_ahead`, `_apply_push_to_colliders`.
- Se eliminó del PackageBody: `push()`, `_push_velocity`, `_propagate_push_to_packages`, `_physics_process`.
- El `InteractionArea` se redujo de 40px a 20px para que solo agarre estando pegado.

---

## Paquetes (PackageBody)

### Tipos de paquete
- Enum `PackageType { BOX, BLUEPOT, BOMB }`.
- Export `package_type` configurable por escena.

### Colisión entre paquetes
- Cuando un paquete (no bomba) cae sobre otro paquete (no bomba), ambos se destruyen con efecto `DirtyExplosion`.
- Se verifica con `_check_landing_collision()` via `call_deferred`.

### Escenas
- `Scenes/Packages/Package.tscn` — Box (sprBox.png, scale 2x, type 0).
- `Scenes/Packages/BluePot.tscn` — BluePot (sprBluePot.png, scale 2x, type 1).
- `Scenes/Packages/Bomb.tscn` — Bomb (sprIconBomb.png, scale 2x, type 2).

---

## Camiones (DeliveryTruck)

### Dos camiones con tipos
- `DeliveryTruck` (verde, texto "CAMION") — acepta solo Box (`accepted_type = 0`).
- `DeliveryTruckBluePot` (azul, texto "POCION") — acepta solo BluePot (`accepted_type = 1`).

### Validación
- `DeliveryZone.accepts(package)` verifica que el tipo coincida.
- Si no acepta, el player se queda con el paquete (no lo suelta).

---

## Drone Visual

### Sprite animado
- Reemplazado placeholder dibujado a mano por `AnimatedSprite2D`.
- Usa `Assets/drone/drone dog.png` (128x128, grid 2x2).
- 3 frames de animación "fly" a 8 FPS (se eliminó el 4to frame vacío).
- Scale 1.0 (64x64 en pantalla).

---

## Caja Visual

### Sprite
- Reemplazado `PackageVisual` (rectángulo dibujado) por `Sprite2D`.
- Usa `Assets/Objects/Box/sprBox.png` (16x16, scale 2x = 32x32 en pantalla).
- `PackageVisual.gd` ahora extiende `Sprite2D`.

---

## Efectos

### BombExplosion
- `Scenes/Effects/BombExplosion.tscn`
- Sprite sheet 192x32 → 6 frames de 32x32, scale 2x.
- Animación "explode" a 12 FPS, sin loop.
- Se autodestruye a los 0.6s.

### DirtyExplosion
- `Scenes/Effects/DirtyExplosion.tscn`
- Sprite sheet 64x16 → 4 frames de 16x16, scale 2x.
- Animación "explode" a 10 FPS, sin loop.
- Se autodestruye a los 0.5s.

---

## Puntaje (GameManager)

- Nodo `GameManager` en TestLevel con `ScoreLabel`.
- +1 punto por cada entrega exitosa a cualquier camión.
- Cada entrega aumenta `bomb_chance` en 1% (máximo 50%).
- Cada 2 puntos: +1 drone concurrente.
- Label centrado arriba: "Puntaje: X".

---

## TileMap

- Creado recurso `Resources/IceZoneTileSet.tres` con `tileIceZoneTileset.png` (640x384, tiles 16x16).
- Agregado nodo `TileMapLayer` en TestLevel para pintar el escenario.

---

## Background

- Color de fondo cambiado de rojo a azul (`Color(0.1, 0.1, 0.8, 1)`).

---

## Archivos creados/modificados

### Scripts nuevos
- `Scripts/GameManager.gd`
- `Scripts/DeliveryTruck/TruckVisualBluePot.gd`

### Scripts modificados
- `Scripts/Drone/DroneSpawner.gd`
- `Scripts/Drone/Drone.gd`
- `Scripts/Drone/DroneVisual.gd`
- `Scripts/Player/PlayerController.gd`
- `Scripts/Player/PlayerVisual.gd`
- `Scripts/Player/PlayerCarry.gd`
- `Scripts/Package/PackageBody.gd`
- `Scripts/Package/PackageVisual.gd`
- `Scripts/DeliveryTruck/DeliveryZone.gd`

### Escenas nuevas
- `Scenes/Packages/BluePot.tscn`
- `Scenes/Packages/Bomb.tscn`
- `Scenes/DeliveryTruck/DeliveryTruckBluePot.tscn`
- `Scenes/Effects/BombExplosion.tscn`
- `Scenes/Effects/DirtyExplosion.tscn`

### Escenas modificadas
- `Scenes/TestLevel/TestLevel.tscn`
- `Scenes/Player/Player.tscn`
- `Scenes/Drone/Drone.tscn`
- `Scenes/Drone/DroneSpawner.tscn`
- `Scenes/Packages/Package.tscn`
- `Scenes/DeliveryTruck/DeliveryTruck.tscn`

### Recursos nuevos
- `Resources/IceZoneTileSet.tres`


---

## Cambios adicionales (sesión continuada)

---

## Ruby / Power-Ups

### Item Ruby
- Nueva escena `Scenes/Packages/Ruby.tscn` usando sprite `Assets/Objects/Items/sprRuby.png` (80x16, 5 frames de 16x16, scale 2x).
- Tipo `RUBY` agregado al enum `PackageType` (valor 3).
- Animación "idle" en loop a 8 FPS.
- El Ruby se comporta como un paquete normal (se destruye con bombas, dirty explosion si cae sobre otro objeto).

### Aparición del Ruby
- Cada 5 puntos NUEVOS (umbral progresivo, no se repite si pierde y recupera puntos), un drone trae un Ruby.
- Usa sistema `_next_ruby_at` que incrementa +5 cada vez que se alcanza.
- El Ruby solo se puede recoger cuando ya cayó al suelo (estado FREE).

### Recolección automática
- Al tocar el Ruby el player lo recoge automáticamente (sin presionar interact).
- Se detecta en `PlayerInteraction._on_body_entered` verificando `PackageType.RUBY`.

### Menú de Power-Up
- Al recoger un Ruby, el juego se pausa y aparece un menú centrado con fondo oscuro.
- 3 opciones:
  - **+Vel**: aumenta la velocidad del player en +30.
  - **+Cant**: aumenta la cantidad de objetos que puede cargar en +1.
  - **Escudo**: protege al player de la próxima bomba que caiga encima.
- El menú tiene `process_mode = ALWAYS` para funcionar durante la pausa.
- Al elegir una opción, el menú se cierra y el juego se reanuda.

---

## Sistema de Carry múltiple

### Apilamiento de objetos
- El player ahora puede cargar múltiples objetos según `max_carry` (empieza en 1).
- Los paquetes se apilan visualmente uno encima del otro (20px de separación vertical).
- Se usa un array `_carried_packages` en vez de una sola variable.

### Agarrar/Soltar
- Al agarrar: verifica que no se exceda `max_carry`, agrega al stack.
- Al soltar: suelta el paquete de arriba (último agarrado).
- Al entregar: entrega el paquete de arriba al camión (si es del tipo correcto).
- Se puede agarrar mientras se está cargando (si hay espacio).

---

## Escudo

### Protección contra bombas
- Variable `has_shield` en `PlayerController`.
- Si una bomba explota cerca del player y tiene escudo: el escudo se consume, la bomba se destruye, no se dañan objetos cercanos.
- Si no tiene escudo y una bomba cae encima: Game Over.

---

## Game Over

### Condición
- Si una bomba cae sobre el player (radio 48px) y no tiene escudo, se activa Game Over.

### Pantalla de Game Over
- Menú con fondo rojo oscuro semi-transparente.
- Muestra "GAME OVER" y el puntaje final.
- Botón "Reiniciar" que recarga la escena completa.
- `process_mode = ALWAYS` para funcionar durante la pausa.

---

## Pérdida de puntos

### Objeto cae sobre el player
- Si un box o bluepot cae encima del player (radio 30px), el player pierde 2 puntos.
- Se ejecuta efecto `DirtyExplosion` y se destruye el objeto.
- El puntaje no baja de 0.
- La velocidad y cantidad de drones NO se afectan (solo baja el puntaje).

---

## Drone persecución

### Modo Chase
- 5% de probabilidad de que un drone con box o bluepot entre en modo persecución.
- El drone primero vuela a un punto intermedio en pantalla.
- Luego cambia a estado `CHASING`: sigue la posición del player.
- Cuando está encima del player (distancia < 20px), suelta el objeto.
- No aplica a drones con bomba ni ruby.
- Nuevo estado `State.CHASING` en `Drone.gd`.

---

## Zonas bloqueadas para drop

### Tiles prohibidos
- Los drones no pueden soltar objetos en los tiles con coordenadas: (0,16), (1,16), (3,16), (0,17), (3,17), (0,18), (1,18), (3,18).
- Función `_is_on_blocked_tile()` convierte posición mundo a coordenada de tile (16x16) y la compara.
- La verificación se aplica en `_choose_drop_position()`.

---

## HUD actualizado

### Esquina superior derecha
- Icono del drone animado (AnimatedSprite2D, 3 frames a 8 FPS, 64x64).
- Label "xN" con la cantidad de drones concurrentes actuales.

### Esquina superior izquierda
- "Vel: X" — velocidad actual del player.
- "Cant: X" — cantidad de objetos que puede cargar.

### Centro superior
- "Puntaje: X" — puntaje actual.

---

## Archivos nuevos (sesión continuada)

### Scripts
- `Scripts/GameManager.gd` (reescrito con power-ups, game over, lose_points)

### Escenas
- `Scenes/Items/Ruby.tscn` (versión standalone sin PackageBody)
- `Scenes/Packages/Ruby.tscn` (versión paquete con PackageBody)
- Nodos de menú PowerUpMenu y GameOverMenu en TestLevel.tscn

### Assets utilizados
- `Assets/Objects/Items/sprRuby.png` (80x16, 5 frames)


---

## Ajustes de balanceo (últimos cambios)

### Spawn masivo de drones
- `_try_spawn()` ahora lanza todos los drones necesarios de golpe para llenar el máximo concurrente.
- Antes solo lanzaba 1 por intervalo, ahora si `_max_concurrent_drones` es 23 y hay 5 en vuelo, lanza 18 de una vez.

### Incremento de drones cada 3 puntos
- Cambiado de cada 2 puntos a cada 3 puntos para que la dificultad escale más gradualmente.


---

## Menú Principal y Navegación

### MainMenu
- Nueva escena `Scenes/UI/MainMenu.tscn` como escena principal del juego.
- Título "Chaos Delivery" centrado.
- 3 botones: Comenzar, Tienda, Salir.
- `project.godot` actualizado con `run/main_scene` apuntando al menú.

### Menú de Pausa (ESC)
- Al presionar ESC durante el juego, se pausa y aparece menú con:
  - **Reanudar** — cierra el menú y continúa.
  - **Volver al Menu** — regresa al menú principal SIN guardar monedas de la partida.
  - **Salir** — cierra el juego.
- ESC de nuevo también reanuda. No se activa si hay otro menú abierto (power-up o game over).
- `GameManager` tiene `process_mode = ALWAYS` para detectar input durante pausa.
- Acción "pause" agregada al input map (`physical_keycode = 4194305` = Escape).

### Game Over actualizado
- Ahora tiene 3 botones: Reiniciar, Volver al Menu, Salir.
- Al perder, las monedas de la partida se guardan antes de mostrar el menú.
- "Volver al Menu" desde game over sí conserva las monedas (ya se guardaron al perder).

---

## Sistema de Monedas (Coins)

### Gold Coin y Silver Coin
- Nuevos tipos `GOLD_COIN` (valor 4) y `SILVER_COIN` (valor 5) en enum `PackageType`.
- **Gold Coin**: aparece cada 30 segundos, al tocar suma +5 monedas.
- **Silver Coin**: aparece cada 10 segundos, al tocar suma +1 moneda.
- Se recogen automáticamente al contacto (igual que el ruby).
- NO abren el menú de power-up, solo suman dinero.
- Se destruyen con bombas y dirty explosion como los demás paquetes.
- NO son perseguidas por drones en modo chase.

### Persistencia de monedas
- Las monedas solo se guardan cuando el jugador pierde (game over).
- Si vuelve al menú desde pausa (ESC), las monedas de esa partida se pierden.
- Variable `_coins_this_run` separa las monedas ganadas en la partida actual de las guardadas.
- Se guardan en `user://coins.save`.

### HUD de monedas
- Esquina inferior izquierda: "$ X" mostrando monedas guardadas + las de la partida actual.

---

## Tienda (Shop)

### Escena y script
- `Scenes/UI/Shop.tscn` y `Scripts/UI/Shop.gd`.
- Accesible desde el botón "Tienda" del menú principal.
- Botón "Volver" regresa al menú principal.

### Opciones de mejora
- **Vel** (velocidad): barra de progreso 0-10, botón "Comprar", costo al lado.
- **Cant** (capacidad): barra de progreso 0-10, botón "Comprar", costo al lado.
- Máximo 10 niveles por stat.

### Progresión de niveles
- **Niveles 1-5**: se necesitan 2 compras para subir de nivel.
- **Niveles 6-10**: se necesitan 3 compras para subir de nivel.
- Aplica tanto para Vel como para Cant.

### Costo progresivo
- Costo base: 10 monedas.
- Cada compra siguiente cuesta: valor actual + la mitad (redondeado hacia abajo).
- Ejemplo: 10 → 15 → 22 → 33 → 49 → 73 → ...
- Se muestra el costo actual: "($X)" al lado de cada botón.
- Botón se desactiva si no hay monedas suficientes o ya está al máximo.

### Efecto en el juego
- Cada nivel de Vel comprado = +15 velocidad base al iniciar partida.
- Cada nivel de Cant comprado = +1 capacidad de carry al iniciar partida.
- Se acumulan con power-ups del ruby obtenidos durante la partida.
- Upgrades guardados en `user://upgrades.save`.

---

## Drone persecución (ajuste)

### Exclusiones
- Los drones con coins (Gold/Silver) y Ruby ya NO entran en modo persecución.
- Solo los drones con Box o BluePot tienen 5% de probabilidad de perseguir al player.

---

## Archivos nuevos (esta sección)

### Scripts
- `Scripts/UI/MainMenu.gd`
- `Scripts/UI/Shop.gd`

### Escenas
- `Scenes/UI/MainMenu.tscn`
- `Scenes/UI/Shop.tscn`
- `Scenes/Items/GoldCoin.tscn` (standalone AnimatedSprite2D)
- `Scenes/Items/SilverCoin.tscn` (standalone AnimatedSprite2D)
- `Scenes/Packages/GoldCoin.tscn` (paquete con PackageBody)
- `Scenes/Packages/SilverCoin.tscn` (paquete con PackageBody)

### Assets utilizados
- `Assets/Objects/Items/sprGoldCoin.png` (64x16, 4 frames)
- `Assets/Objects/Items/sprSilverCoin.png` (64x16, 4 frames)


---

## Tienda - Ajuste de costo

### Costo no sube hasta completar nivel
- El precio de compra se mantiene constante durante todas las compras del mismo nivel.
- Solo sube cuando se completa el nivel entero (todas las compras necesarias para ese nivel).
- Ejemplo: nivel 1 de cant (necesita 2 compras) → ambas cuestan 10. Al completar, nivel 2 cuesta 15.
- `_get_cost()` ahora recibe el nivel completado, no las compras totales.

### Reset de datos
- Se eliminaron `coins.save` y `upgrades.save` del directorio de usuario.
- Dinero reiniciado a 0, tienda reiniciada a nivel 0 en ambos stats.
