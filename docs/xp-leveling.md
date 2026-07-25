# XP y Level Up

Sistema de experiencia temporal que solo dura la partida actual.

---

## Como funciona

- El jugador gana XP al entregar paquetes en los puntos de entrega.
- Al acumular suficiente XP, sube de nivel.
- Al subir de nivel se abre una ventana de seleccion.
- El jugador elige UNA mejora temporal de una lista.
- Las mejoras se pierden al terminar la partida.

---

## Tabla de XP por Nivel

| Nivel | XP necesaria | XP acumulada total |
|---|---|---|
| 1 -> 2 | 50 | 50 |
| 2 -> 3 | 100 | 150 |
| 3 -> 4 | 150 | 300 |
| 4 -> 5 | 200 | 500 |
| 5 -> 6 | 250 | 750 |
| 6 -> 7 | 300 | 1050 |
| 7 -> 8 | 350 | 1400 |
| 8 -> 9 | 400 | 1800 |
| 9 -> 10 | 450 | 2250 |
| 10+ | 500 (fijo) | - |

Formula: xp_para_nivel(n) = min(50 * n, 500)

---

## Fuentes de XP

| Accion | XP ganada |
|---|---|
| Entregar paquete tipo A | Definido en PackageTypeData.xp_reward |
| Entregar paquete tipo B | Definido en PackageTypeData.xp_reward |
| Entregar paquete tipo C | Definido en PackageTypeData.xp_reward |

Valores configurables por Resource.

---

## Opciones de Level Up (mejoras temporales)

| Opcion | Efecto | Notas |
|---|---|---|
| +Vida | +1 fragmento de corazon (cura y aumenta max) | Siempre disponible |
| +Velocidad | +speed_increment al current_speed | Siempre disponible |
| +Fuerza | +force_increment al current_force | Siempre disponible |
| Sprint | Desbloquea habilidad de sprint (Shift) | Solo aparece si no la tiene |
| Regeneracion | Regenera 1 fragmento cada X segundos | Solo aparece si no la tiene |
| Lanzamiento | Puede lanzar paquetes/bombas | Solo aparece si no la tiene |

Las opciones son configurables. Se presentan 3 opciones aleatorias de las disponibles.

---

## Implementacion sugerida

- LevelUpConfig como Resource editable.
- RuntimePlayerStats.add_xp(amount) -> verifica si sube de nivel.
- Senal: level_up(new_level) -> abre UI de seleccion.
- Senal: level_up_choice_made(choice_id) -> aplica mejora.
- El juego se PAUSA mientras la ventana esta abierta.

---

## Valores por defecto (configurables)
force_increment: 0.5 speed_increment: 20.0 px/s health_fragment_increment: 1 regen_interval: 10.0 segundos
