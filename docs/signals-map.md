# Signals Map

## Estado

Documento de referencia. Debe mantenerse actualizado conforme se implementen los sistemas.

---

## Principio

Todos los sistemas se comunican exclusivamente mediante señales.
Ningún sistema debe llamar métodos directamente en otro sistema.

---

## Mapa de Señales por Sistema

### GameManager

| Señal | Argumentos | Escucha |
|---|---|---|
| `game_state_changed` | `new_state: GameState` | HUD, OrderGenerator, Player |
| `day_started` | `day_number: int` | HUD, OrderGenerator, EconomyManager |
| `day_ended` | `day_number: int` | HUD, EconomyManager, OrderManager |
| `day_timer_updated` | `seconds_remaining: float` | HUD |

---

### OrderManager

| Señal | Argumentos | Escucha |
|---|---|---|
| `order_added` | `order: OrderData` | HUD |
| `order_completed` | `order: OrderData` | EconomyManager, HUD |
| `order_expired` | `order: OrderData` | EconomyManager, HUD |
| `order_state_changed` | `order_id: String, new_state: OrderState` | HUD |

---

### EconomyManager

| Señal | Argumentos | Escucha |
|---|---|---|
| `money_changed` | `new_amount: int` | HUD |
| `day_earnings_calculated` | `total: int` | UpgradeShop, HUD |
| `upgrade_purchased` | `upgrade_id: String` | UpgradeManager |

---

### Player

| Señal | Argumentos | Escucha |
|---|---|---|
| `package_picked_up` | `package: PackageData` | HUD (indicador contextual) |
| `package_dropped` | `package: PackageData` | Warehouse (reposición) |
| `interaction_available` | `interactable: Node` | HUD (indicador de interacción) |
| `interaction_unavailable` | — | HUD |

---

### PackagingTable

| Señal | Argumentos | Escucha |
|---|---|---|
| `packaging_started` | `package: PackageData` | HUD, OrderManager |
| `packaging_completed` | `package: PackageData` | Player, OrderManager |

---

### DispatchZone

| Señal | Argumentos | Escucha |
|---|---|---|
| `package_dispatched` | `package: PackageData` | OrderManager |

---

### Package

| Señal | Argumentos | Escucha |
|---|---|---|
| `picked_up` | `package_data: PackageData` | Player, Shelf |
| `placed` | `package_data: PackageData` | Shelf |

---

## Reglas

1. Un sistema nunca importa la referencia de otro para llamar métodos.
2. Si un sistema necesita datos de otro, los recibe a través de argumentos de señal.
3. Los Singletons (`GameManager`, `EconomyManager`, `AudioManager`) pueden ser referenciados directamente como excepción controlada.
4. Nunca conectar señales en `_ready()` desde un sistema externo. Cada nodo conecta sus propias señales.

---

## Decisiones Pendientes

- [ ] ¿Cómo se conecta HUD a GameManager si HUD es CanvasLayer separado?
- [ ] ¿OrderManager vive en la escena del nivel o es Singleton?
- [ ] ¿PackagingTable valida el tipo de paquete o lo delega a OrderManager?
- [ ] ¿DispatchZone necesita saber qué pedido corresponde al paquete?
