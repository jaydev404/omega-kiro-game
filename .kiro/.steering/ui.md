# UI

## Filosofía

La UI debe ser minimalista. Priorizar legibilidad sobre decoración.

## Estructura de Nodos

La UI se implementa con un `CanvasLayer` raíz que contiene un nodo `Control` principal.

```
CanvasLayer
└── HUD (Control)
    ├── TopBar (HBoxContainer)      → tiempo restante de la jornada
    ├── LeftPanel (VBoxContainer)   → dinero actual
    ├── RightPanel (VBoxContainer)  → lista de pedidos activos
    └── InteractionHint (Label)     → indicadores contextuales (centro)
```

## HUD

| Zona | Contenido |
|---|---|
| Superior | Tiempo restante de la jornada |
| Izquierda | Dinero actual |
| Derecha | Pedidos activos (icono, tiempo restante, recompensa) |
| Centro | Indicador contextual de interacción disponible |

## Señales que Escucha

- `GameManager.day_timer_updated` → actualiza TopBar
- `EconomyManager.money_changed` → actualiza LeftPanel
- `OrderManager.order_added` → añade entrada a RightPanel
- `OrderManager.order_completed` → elimina entrada de RightPanel
- `OrderManager.order_expired` → marca entrada como perdida en RightPanel
- `Player.interaction_available` → muestra InteractionHint
- `Player.interaction_unavailable` → oculta InteractionHint

## Reglas

- No usar nodos 3D.
- Todos los elementos UI son nodos `Control` de Godot.
- Los textos se actualizan reactivamente mediante señales, no por polling.
- El `CanvasLayer` garantiza que la UI siempre queda sobre el mundo 2D.
