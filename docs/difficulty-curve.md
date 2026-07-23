# Difficulty Curve

## Estado

Pendiente de validación. Este documento propone valores concretos de dificultad por jornada para el MVP.

---

## Principio

La dificultad nunca aumenta mediante enemigos ni mecánicas nuevas.
Solo escala mediante:

- Más pedidos simultáneos.
- Menor tiempo de jornada.
- Mayor porcentaje de pedidos urgentes.
- Mayor variedad de tipos de paquete.

---

## Parámetros Controlables

| Parámetro | Descripción |
|---|---|
| `max_active_orders` | Máximo de pedidos simultáneos en pantalla |
| `order_interval` | Segundos entre la generación de pedidos |
| `day_duration` | Duración total de la jornada en segundos |
| `urgent_chance` | Probabilidad de que un pedido sea urgente (0.0 a 1.0) |
| `order_time_limit` | Tiempo base que tiene cada pedido antes de expirar |

---

## Curva por Jornada (MVP — 5 jornadas)

| Jornada | Duración | Max pedidos | Intervalo | % Urgentes | Tiempo por pedido |
|---|---|---|---|---|---|
| 1 | 180s | 2 | 20s | 0% | 60s |
| 2 | 180s | 3 | 15s | 10% | 50s |
| 3 | 200s | 4 | 12s | 20% | 45s |
| 4 | 200s | 5 | 10s | 30% | 40s |
| 5 | 220s | 6 | 8s | 40% | 35s |

> Todos los valores son sugeridos. Deben ajustarse con playtest.

---

## Cómo se Aplica

Los parámetros de dificultad por jornada se definen como un Resource (`DifficultyData`) o como un Dictionary en `GameManager`.

`OrderGenerator` consulta los parámetros activos para:
- Definir el intervalo entre pedidos.
- Decidir si un pedido nuevo es urgente.
- Establecer el tiempo límite del pedido.

---

## Pedidos Urgentes

Los pedidos urgentes son pedidos normales con:
- `is_urgent = true`
- Tiempo límite reducido (sugerido: -30% del tiempo base).
- Recompensa aumentada (×1.5, ver `economy.md`).
- Indicador visual destacado en el HUD.

---

## Ajuste Post-Playtest

Estas variables deben quedar expuestas en el inspector de Godot (via `@export`) para facilitar el ajuste sin tocar código.

---

## Decisiones Pendientes

- [ ] ¿La duración de la jornada aumenta o disminuye con las jornadas?
- [ ] ¿Existe un límite máximo de jornadas en el MVP o es infinito?
- [ ] ¿La dificultad se resetea si el jugador cierra y reabre el juego?
- [ ] ¿Los valores de la tabla son los definitivos para el MVP?
- [ ] ¿Los pedidos urgentes tienen tiempo límite reducido o solo más recompensa?
