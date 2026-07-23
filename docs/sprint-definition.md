# Sprint Definition

## Estado

Decisión de diseño pendiente. Debe resolverse antes de implementar `PlayerController.gd`.

---

## Contexto

El juego incluye sprint mediante la tecla `Shift`. Esta decisión afecta directamente el game feel, el balance de dificultad y la necesidad (o no) de una barra de stamina en el HUD.

---

## Opciones

### Opción A — Sprint Infinito (recomendada para MVP)

El sprint no tiene límite. El jugador puede correr siempre que mantenga Shift.

**Ventajas:**
- Implementación simple.
- Sin UI adicional (no requiere barra de stamina).
- Foco en la toma de decisiones de ruta, no en gestionar stamina.
- Coherente con juegos de referencia (Overcooked, PlateUp!).

**Desventajas:**
- Reduce el desafío físico.
- Hace la velocidad normal casi irrelevante.

---

### Opción B — Sprint con Stamina

El sprint consume una barra de stamina que se recarga al caminar.

**Ventajas:**
- Añade una capa de gestión de recursos.
- La mejora de velocidad base tiene más valor.

**Desventajas:**
- Requiere barra de stamina en el HUD.
- Añade complejidad al MVP.
- Puede frustrar al jugador en situaciones de alta presión.

---

### Opción C — Sprint sin Stamina pero con Cooldown

El sprint dura un tiempo fijo y luego entra en cooldown corto.

**Ventajas:**
- Más dinámico que la opción A sin la complejidad de la opción B.

**Desventajas:**
- Requiere indicador visual del cooldown.
- Introduce microgestión no alineada con la filosofía del juego.

---

## Recomendación

**Opción A para el MVP.** La filosofía del juego prioriza decisiones rápidas sobre mecánicas complejas. El sprint infinito permite al jugador centrarse en la optimización de rutas sin gestionar un recurso adicional.

Si el playtest revela que el juego es demasiado fácil, se puede introducir stamina en una iteración posterior.

---

## Valores de Sprint (si se aprueba Opción A)

```
move_speed: 150.0       → velocidad base (píxeles/segundo)
sprint_multiplier: 1.6  → multiplicador al mantener Shift
```

> Valores sugeridos. Ajustar en playtest.

---

## Impacto en otros Sistemas

- **HUD:** Sin barra de stamina necesaria en el MVP.
- **PlayerStats:** `sprint_multiplier` debe ser un valor exportable para ajuste rápido.
- **Upgrades:** La mejora "Mayor velocidad" aumenta `move_speed`, no `sprint_multiplier`.

---

## Decisión Requerida

- [ ] ¿Qué opción se implementa en el MVP? (recomendada: A)
- [ ] ¿Cuál es el multiplicador de sprint? (sugerido: ×1.6)
- [ ] ¿La mejora de velocidad afecta también al sprint o solo al movimiento base?
