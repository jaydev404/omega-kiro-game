# Sistema de Vida y Dano

---

## Corazones y Fragmentos

- Cada corazon = 4 fragmentos.
- Vida inicial: 1 corazon = 4 fragmentos.
- Power-up permanente hp_up agrega +1 corazon al inicio de cada partida.
- Al perder todos los fragmentos de todos los corazones: GAME OVER.

---

## Recibir Dano

Cuando el jugador recibe dano:
1. Se restan X fragmentos de la vida actual.
2. Se activa invulnerabilidad por 2 segundos.
3. Visual: el sprite parpadea durante la invulnerabilidad.
4. Si fragmentos totales llegan a 0: game over.

---

## Tabla de Dano

| Fuente | Dano (fragmentos) | Radio (px) |
|---|---|---|
| Bomba inmediata | 2 | 64 |
| Bomba timer | 2 | 80 |
| Colision de paquetes (apilamiento) | 1 | 48 |

Todos los valores configurables por Resource (BombData, MatchConfig).

---

## Invulnerabilidad

- Duracion: 2.0 segundos (configurable en MatchConfig.invulnerability_duration)
- Durante la invulnerabilidad: no se recibe dano de ninguna fuente.
- Visual: parpadeo del sprite (alternar visible/invisible cada 0.1s).
- Se activa con CUALQUIER fuente de dano.

---

## Curacion

Formas de recuperar vida:
- Level up: elegir +Vida restaura 1 fragmento y aumenta max en 1.
- Regeneracion (habilidad temporal): 1 fragmento cada X segundos.
- Revivir (power-up permanente): al morir, revive con 1 corazon completo (4 fragmentos). 1 uso por partida.

---

## Game Over

Se dispara cuando:
- current_fragments llega a 0 Y current_hearts llega a 0.
- O cuando el evento final mata al jugador.

Al morir:
1. Verificar si tiene Revivir disponible -> si: revive con 4 fragmentos.
2. Si no: transicion a pantalla de GAME OVER / SUMMARY.

---

## Implementacion sugerida
RuntimePlayerStats: func take_damage(amount: int) -> void: if is_invulnerable: return current_fragments -= amount while current_fragments <= 0 and current_hearts > 0: current_hearts -= 1 current_fragments += 4 if current_hearts <= 0 and current_fragments <= 0: emit_signal("player_died") else: start_invulnerability()

Senales: damage_taken(remaining_fragments: int) player_died() revived()
