# Evento Final - Bombardeo (25 minutos)

---

## Descripcion

A los 25 minutos de partida se activa un evento de bombardeo masivo que garantiza el fin de la partida. Es un game over forzado pero da bonus de dinero por supervivencia.

---

## Secuencia

1. Timer de partida llega a 25:00 (1500 segundos).
2. GameManager emite senal: endgame_started()
3. Todos los drones normales desaparecen.
4. Los paquetes en el suelo permanecen pero ya no se pueden entregar.
5. Los puntos de entrega se desactivan visualmente.
6. Aparecen drones de bombardeo (mas rapidos, solo cargan bombas).
7. La frecuencia de bombas aumenta cada 5 segundos.
8. El jugador solo puede moverse y esquivar.
9. Cuando el jugador muere: fin del evento.

---

## Parametros configurables

| Parametro | Valor sugerido | Descripcion |
|---|---|---|
| endgame_start_time | 1500.0 | Segundo en que inicia |
| endgame_drone_count | 20 | Drones de bombardeo simultaneos |
| endgame_drone_speed | 400.0 | Velocidad de los drones de bombardeo |
| endgame_initial_interval | 1.0 | Intervalo inicial entre bombas (segundos) |
| endgame_min_interval | 0.2 | Intervalo minimo (se acelera con el tiempo) |
| endgame_acceleration | 0.05 | Reduccion del intervalo por segundo |
| endgame_bonus_multiplier | 2.0 | Multiplicador de bonus |

---

## Bonus por Supervivencia

Formula:
bonus_dinero = segundos_sobrevividos_en_evento * endgame_bonus_multiplier


Ejemplo: si el jugador sobrevive 15 segundos con multiplicador 2.0:
- bonus = 15 * 2.0 = 30 monedas extra.

El bonus se suma al dinero total de la partida antes de ir al resumen.

---

## Visual

- Fondo cambia de color (mas oscuro/rojo).
- HUD muestra "BOMBARDEO" o indicador de evento final.
- Timer del HUD cambia a mostrar "tiempo sobrevivido en evento".
- Los drones de bombardeo son visualmente diferentes (rojos, mas grandes).

---

## Estados del GameManager durante el evento
PLAYING -> ENDGAME -> GAME_OVER -> SUMMARY


En ENDGAME:
- Player controlable (puede moverse y esquivar).
- OrderManager desactivado.
- DeliveryPoints desactivados.
- DroneSpawner reemplazado por EndgameBomber.
- Solo bombas inmediatas (no timer, para maximizar presion).

---

## Senales
endgame_started() endgame_survived(seconds: float) endgame_bonus_earned(amount: int)


