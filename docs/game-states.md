# Game States

## Estado

Pendiente de spec formal. Este documento reúne las decisiones de diseño necesarias antes de escribir el spec de `game-manager`.

---

## Responsabilidad

GameManager controla el ciclo de vida completo de la sesión de juego. Es el único Singleton autorizado para gestionar transiciones de estado.

---

## Diagrama de Estados

```
[MENU]
   │
   │ Jugador presiona "Iniciar"
   ▼
[PLAYING]
   │
   │ Temporizador de jornada llega a 0
   ▼
[DAY_END]
   │
   │ Pantalla de resultados mostrada
   ▼
[UPGRADE_SHOP]
   │
   │ Jugador confirma compras
   ▼
[NEW_DAY]
   │
   │ Escena reiniciada con mejoras aplicadas
   ▼
[PLAYING]  ← reinicia el ciclo
```

---

## Descripción de Cada Estado

### MENU
- Pantalla de inicio.
- Ningún sistema de gameplay activo.
- Muestra: nombre del juego, botón de inicio, resumen de jornada anterior (si existe).

### PLAYING
- Gameplay activo.
- OrderGenerator genera pedidos.
- Temporizador de jornada corriendo.
- Player controlable.
- HUD visible y activo.

### DAY_END
- Gameplay detenido.
- Player no controlable.
- OrderGenerator pausado.
- Pedidos activos cancelados o marcados como perdidos.
- Pantalla de resumen: pedidos completados, dinero ganado, mejor racha.

### UPGRADE_SHOP
- Muestra el catálogo de mejoras disponibles.
- Economy activo para gestionar compras.
- Player no controlable.

### NEW_DAY
- Aplica las mejoras compradas.
- Reinicia el Warehouse si corresponde.
- Incrementa parámetros de dificultad.
- Transiciona a PLAYING.

---

## Señales de GameManager

```
game_state_changed(new_state: GameState)
day_started(day_number: int)
day_ended(day_number: int)
day_timer_updated(seconds_remaining: float)
```

---

## Temporizador de Jornada

- Duración base del MVP: a definir (sugerido: 180 segundos).
- Solo corre en estado `PLAYING`.
- Al llegar a 0 emite señal y transiciona a `DAY_END`.

---

## Decisiones Pendientes

- [ ] ¿Cuánto dura la jornada en el MVP? (sugerido: 3 minutos)
- [ ] ¿Existe estado `PAUSED`? ¿Se puede pausar durante el MVP?
- [ ] ¿GameManager es Singleton o nodo raíz de la escena principal?
- [ ] ¿NEW_DAY cambia la escena completa o solo reinicia nodos?
- [ ] ¿El número de jornada se muestra en el HUD?
