# Upgrades Catalog

## Estado

Pendiente de spec formal. Este documento define el catálogo de mejoras del MVP y su relación con los sistemas del juego.

---

## Responsabilidad

El sistema de mejoras permite al jugador invertir el dinero de la jornada en ventajas permanentes que persisten entre jornadas.

Afecta a dos categorías: el Player y el Warehouse.

---

## Cómo Funciona

1. Al finalizar la jornada (`DAY_END`), el juego transiciona a `UPGRADE_SHOP`.
2. Se muestra el catálogo con las mejoras disponibles y su costo.
3. El jugador compra las que pueda pagar.
4. Al iniciar la siguiente jornada (`NEW_DAY`), las mejoras se aplican.

Las mejoras son permanentes durante la sesión. Con `SaveManager` se pueden persistir entre sesiones.

---

## Catálogo MVP

### Mejoras de Personaje

| ID | Nombre | Descripción | Costo | Efecto | Niveles |
|---|---|---|---|---|---|
| `player_speed_1` | Zapatillas | +20% velocidad de movimiento | $30 | `move_speed * 1.2` | 1 |
| `player_speed_2` | Zapatillas Pro | +40% velocidad de movimiento | $60 | `move_speed * 1.4` | 2 (requiere nivel 1) |
| `pack_speed_1` | Cinta de embalaje | -25% tiempo de empacado | $40 | `pack_time * 0.75` | 1 |
| `pack_speed_2` | Empacadora manual | -50% tiempo de empacado | $80 | `pack_time * 0.5` | 2 (requiere nivel 1) |

### Mejoras de Almacén

| ID | Nombre | Descripción | Costo | Efecto | Niveles |
|---|---|---|---|---|---|
| `table_upgrade_1` | Mesa reforzada | -15% tiempo de empacado adicional | $50 | Multiplica sobre `pack_speed` del jugador | 1 |
| `shelf_org_1` | Estanterías organizadas | Indicadores visuales de ubicación de paquetes | $35 | UI highlight en estantería correcta | 1 |
| `cart_1` | Carrito de transporte | El jugador puede cargar 2 paquetes | $90 | `carry_capacity = 2` | 1 |

---

## Sistema de Stats

Para que las mejoras funcionen, los valores modificables deben estar centralizados en un `PlayerStats` Resource o nodo:

```
PlayerStats
├── move_speed: float       → velocidad base de movimiento
├── sprint_multiplier: float
├── pack_time: float        → tiempo base de empacado
├── carry_capacity: int     → paquetes que puede cargar (default 1)
```

`PlayerController.gd` y `PlayerCarry.gd` leen de `PlayerStats` en lugar de tener los valores hardcodeados.

---

## Señales

```
upgrade_purchased(upgrade_id: String)
upgrade_applied(upgrade_id: String)
stats_changed(stat_name: String, new_value: float)
```

---

## Decisiones Pendientes

- [ ] ¿Los costos del catálogo son los definitivos para el MVP?
- [ ] ¿Las mejoras de nivel 2 requieren nivel 1 o son independientes?
- [ ] ¿Existe un límite de mejoras por jornada?
- [ ] ¿`PlayerStats` es un Resource o un nodo hijo del Player?
- [ ] ¿El carrito de transporte requiere una escena nueva o solo cambia una variable?
- [ ] ¿Las mejoras de almacén afectan a la escena actual o se cargan al inicio de la jornada?
