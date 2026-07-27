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

## Curva por Jornada (10 minutos)

| Fase | Tiempo | Drones | Intervalo | Velocidad | % Bombas | % Persecución |
|---|---|---|---|---|---|---|
| 0 — Intro | 0:00 - 2:00 | 3 | 5.0s | 120 | 5% | 1% |
| 1 — Normal | 2:00 - 4:00 | 4 | 3.5s | 155 | 12% | 6% |
| 2 — Presión | 4:00 - 7:00 | 5 | 2.5s | 190 | 22% | 12% |
| 3 — Caos | 7:00 - 9:00 | 7 | 1.8s | 230 | 32% | 20% |
| 4 — Sprint | 9:00 - 9:30 | 10 | 1.2s | 270 | 42% | 28% |
| Bombardeo | 9:30 - fin | masivo | 0.3s | — | 80% | — |

> Todos los valores configurables en `Resources/DifficultyConfig.tres` sin tocar código.

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
