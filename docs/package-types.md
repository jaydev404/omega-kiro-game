# Package Types

## Estado

Pendiente de spec formal. Este documento define los tipos de paquetes necesarios para el MVP y sus propiedades.

---

## Responsabilidad

Los paquetes son la entidad central del juego. Cada paquete:
- Existe físicamente en una estantería del Warehouse.
- Es solicitado por un Order (por tipo).
- Es recogido por el Player.
- Pasa por la PackagingTable.
- Es entregado en la DispatchZone.

---

## Estructura de Datos (PackageData Resource)

```
PackageData
├── id: String          → identificador único de instancia
├── type: PackageType   → enum con el tipo de paquete
├── display_name: String
├── placeholder_color: Color
├── base_reward: int    → recompensa base del pedido asociado
```

---

## Tipos de Paquete (MVP)

El MVP requiere mínimo 3 tipos para que el sistema sea no-trivial.

### Tipo A — Pequeño
- Nombre: "Pequeño"
- Placeholder: rectángulo rojo oscuro (32×32 px)
- Estantería: Estantería 1 (izquierda)
- Recompensa base: $10
- Tiempo de embalaje: rápido (2 segundos)

### Tipo B — Mediano
- Nombre: "Mediano"
- Placeholder: rectángulo naranja (40×32 px)
- Estantería: Estantería 2 (centro)
- Recompensa base: $20
- Tiempo de embalaje: normal (4 segundos)

### Tipo C — Grande
- Nombre: "Grande"
- Placeholder: rectángulo marrón (48×40 px)
- Estantería: Estantería 3 (derecha)
- Recompensa base: $35
- Tiempo de embalaje: lento (6 segundos)

---

## Escena Package.tscn

```
Package.tscn

Area2D
├── Sprite2D          → placeholder de color según tipo
├── CollisionShape2D  → RectangleShape2D
└── Label             → nombre del tipo (debug, desactivar en release)
```

Script: `PackageInteractable.gd`

El paquete debe:
- Implementar la interfaz `Interactable` (método `interact()`).
- Emitir señal `picked_up(package_data)` al ser recogido.
- Desactivarse visualmente al ser cargado por el Player.
- Reactivarse si el Player lo suelta sin completar el ciclo.

---

## Relación con Orders

Un `OrderData` referencia el tipo de paquete mediante el enum `PackageType`.

```
OrderData
└── required_package_type: PackageType
```

El Player recoge cualquier paquete disponible. La validación de que el paquete es el correcto ocurre en la `PackagingTable` o en el `OrderManager`.

TODO: Definir quién valida la coincidencia tipo-orden (PackagingTable vs OrderManager).

---

## Stock en Estanterías

Cada estantería mantiene un stock de paquetes de su tipo.

- Stock inicial por tipo: 5 unidades (sugerido).
- Reposición: automática tras un tiempo fijo o al inicio de cada jornada.
- TODO: Definir si el stock puede agotarse y qué ocurre en ese caso.

---

## Decisiones Pendientes

- [ ] ¿Cuántos tipos de paquete en el MVP? (mínimo 3 confirmado)
- [ ] ¿Quién valida que el paquete coincide con el pedido?
- [ ] ¿El stock puede agotarse? ¿Cómo se repone?
- [ ] ¿Los paquetes urgentes son un tipo diferente o una propiedad del Order?
- [ ] ¿Los valores de recompensa base son los correctos?
