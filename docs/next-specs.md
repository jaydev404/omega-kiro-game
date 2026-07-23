# Próximos Specs a Desarrollar

Lista priorizada de specs pendientes basada en dependencias del gameplay.

---

## Prioridad 1 — Bloquean el MVP

### 1. `package`
Entidad central del juego. Conecta Warehouse, Orders y Player.
Sin este spec no se puede integrar ningún sistema.

Debe definir:
- Tipos de paquete disponibles en el MVP.
- Propiedades: ID, tipo, estado, posición en estantería.
- Escena: `Package.tscn`
- Cómo se referencia desde un Order.
- Cómo lo recoge el Player.

Referencia: `docs/package-types.md`

---

### 2. `game-manager`
Define el ciclo de vida completo de la jornada.
Sin este spec ningún sistema sabe cuándo iniciarse, pausarse o detenerse.

Debe definir:
- Estados: `MENU → PLAYING → DAY_END → UPGRADE_SHOP → NEW_DAY`
- Quién controla las transiciones.
- Qué sistemas se activan/desactivan en cada estado.
- Temporizador global de jornada.

Referencia: `docs/game-states.md`

---

## Prioridad 2 — Necesarios para el loop completo

### 3. `hud`
La UI conecta datos de tres sistemas: GameManager (tiempo), Economy (dinero) y Orders (pedidos activos).

Debe definir:
- Estructura de nodos: `CanvasLayer > Control`
- Señales que escucha.
- Qué actualiza y cuándo.
- Indicadores contextuales de interacción (centro de pantalla).

Referencia: `docs/signals-map.md`

---

### 4. `economy`
Gestiona el dinero durante la jornada y la tienda de mejoras al final.

Debe definir:
- Fórmula de recompensa por entrega.
- Penalización por entrega tardía o pedido perdido.
- Nodo o sistema que almacena el dinero.
- Señales hacia HUD y Upgrades.

Referencia: `docs/economy.md`

---

## Prioridad 3 — Post-loop básico

### 5. `upgrades`
Sistema de mejoras permanentes entre jornadas.
Requiere que Economy esté implementado.

Debe definir:
- Catálogo de mejoras disponibles.
- Cómo modifican los stats del Player y del Warehouse.
- Sistema de Stats consultable por otros sistemas.

Referencia: `docs/upgrades-catalog.md`

---

### 6. `save-manager`
Persistencia de mejoras entre sesiones.
Debe diseñarse antes de implementarse para no acoplarse a la escena.

Debe definir:
- Qué datos se persisten (stats, dinero, jornada actual).
- Formato de guardado (JSON o Resource de Godot).
- Cuándo se guarda y cuándo se carga.

---

## Resumen de Orden

```
1. package          → entidad base
2. game-manager     → flujo de estados
3. hud              → UI funcional
4. economy          → dinero y recompensas
5. upgrades         → progresión entre jornadas
6. save-manager     → persistencia
```
