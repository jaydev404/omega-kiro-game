# Economy

## Estado

Pendiente de spec formal. Este documento reúne las decisiones de diseño necesarias antes de escribir el spec.

---

## Responsabilidad

El sistema de Economy gestiona:
- El dinero acumulado durante la jornada.
- Las recompensas por entrega.
- Las penalizaciones por entregas tardías o pedidos perdidos.
- La tienda de mejoras al finalizar la jornada.

---

## Flujo de Dinero

```
Order completado
    ↓
Economy.add_reward(amount)
    ↓
HUD actualiza dinero visible
    ↓
[Fin de jornada]
    ↓
UpgradeShop muestra saldo disponible
    ↓
Jugador compra mejoras
    ↓
Economy.spend(amount)
    ↓
Upgrades aplica cambios
    ↓
SaveManager persiste
```

---

## Recompensas

### Entrega a tiempo
- Recompensa completa definida en `OrderData`.

### Entrega tardía
- Recompensa reducida.
- Fórmula sugerida (pendiente de validación):
  `recompensa_final = recompensa_base * (tiempo_restante / tiempo_total)`
- Mínimo garantizado: 25% de la recompensa base.
- TODO: Confirmar si existe un mínimo garantizado o puede ser 0.

### Pedido perdido (expirado)
- Sin recompensa.
- TODO: Definir si hay penalización económica (multa) o solo pérdida de ganancia.

### Pedido urgente completado
- Multiplicador de recompensa.
- Sugerido: ×1.5 sobre la recompensa base.
- TODO: Confirmar multiplicador exacto.

---

## Nodo Responsable

`EconomyManager` (Singleton o nodo hijo de GameManager).

Señales que emite:
- `money_changed(new_amount: int)`
- `day_earnings_calculated(total: int)`

---

## Tienda de Mejoras

Se activa al finalizar la jornada (estado `UPGRADE_SHOP`).

Muestra:
- Saldo disponible.
- Catálogo de mejoras con costo.
- Confirmación de compra.

Al confirmar compra:
- `Economy.spend(cost)`
- `Upgrades.apply(upgrade_id)`

---

## Decisiones Pendientes

- [ ] ¿Existe penalización por pedido perdido?
- [ ] ¿Cuál es el multiplicador exacto para pedidos urgentes?
- [ ] ¿El mínimo de entrega tardía es 25% o puede llegar a 0?
- [ ] ¿EconomyManager es Singleton o hijo de GameManager?
- [ ] ¿El dinero se resetea entre jornadas o se acumula indefinidamente?
