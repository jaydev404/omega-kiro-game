# Startup Logistics — Documento de Concepto

> Nota: Este documento es el concepto original del juego. La referencia técnica actualizada se encuentra en `.kiro/.steering/project.md`.

---

## Descripción

Juego de gestión arcade donde el jugador comienza como el único empleado de una pequeña empresa de envíos. Su objetivo es preparar y despachar la mayor cantidad de pedidos posible antes de que termine la jornada, obteniendo dinero para mejorar tanto al personaje como al almacén. El enfoque está en la toma de decisiones rápidas, la optimización de rutas y la gestión de prioridades.

---

## Vista y Cámara

- Perspectiva: 2D Isométrico (2.5D).
- Cámara: Camera2D fija durante toda la partida.
- Rotación: No disponible en el MVP.
- Zoom: Fijo. El almacén completo debe ser visible en pantalla.
- Movimiento: El jugador se desplaza libremente con WASD sobre un plano 2D.

La cámara debe permitir ver todo el almacén sin necesidad de moverla, favoreciendo la lectura rápida del escenario.

---

## Escenario Inicial

Un pequeño almacén compuesto por:

- Zona de recepción de pedidos.
- Estanterías con paquetes.
- Mesa de embalaje.
- Zona de despacho/salida.
- Espacios libres para futuras mejoras.

Todo el gameplay ocurre en un único mapa construido con TileMap y escenas 2D.

---

## Gameplay Principal

El jugador recibe pedidos de forma continua y debe completar el siguiente ciclo antes de que expire el tiempo:

1. Recibir un pedido.
2. Identificar el paquete correcto.
3. Recogerlo de la estantería.
4. Llevarlo a la mesa de embalaje.
5. Empacarlo.
6. Llevarlo a la zona de despacho.
7. Cobrar la recompensa.

Mientras realiza estas acciones siguen llegando nuevos pedidos, obligando al jugador a decidir cuáles atender primero.

---

## Mecánicas Básicas (MVP)

### Movimiento
- WASD.
- Sprint opcional (Shift).

### Interacción
Una sola tecla (E). Con ella el jugador puede:
- Recoger paquetes.
- Colocarlos.
- Empacar.
- Entregar.

### Pedidos
Cada pedido contiene:
- Tipo de paquete.
- Tiempo restante.
- Recompensa.
- Prioridad (normal o urgente).

### Temporizador
Cada pedido tiene un tiempo límite.
- Entrega perfecta → recompensa completa.
- Entrega tardía → recompensa reducida.
- No entregado → pedido perdido.

---

## Economía

Cada entrega genera dinero. El dinero únicamente sirve para comprar mejoras permanentes al finalizar la jornada.

### Mejoras Iniciales

**Personaje**
- Mayor velocidad.
- Empacado más rápido.
- Mayor capacidad de carga.

**Almacén**
- Mejor mesa de embalaje.
- Estanterías organizadas.
- Carrito de transporte.
- Cinta transportadora (futuro, post-MVP).

---

## Dificultad

La dificultad aumenta únicamente mediante:
- Más pedidos simultáneos.
- Menor tiempo disponible.
- Mayor distancia entre estaciones.
- Aparición de pedidos urgentes.

No habrá enemigos ni combate.

---

## Interfaz (HUD)

| Posición | Contenido |
|---|---|
| Superior | Tiempo restante de la jornada |
| Izquierda | Dinero actual |
| Derecha | Lista de pedidos (icono, tiempo, recompensa) |
| Centro | Indicadores contextuales de interacción |

---

## Objetivo de una Partida

Completar la mayor cantidad de pedidos antes de finalizar la jornada para obtener el mayor beneficio posible y desbloquear mejoras. Cada nueva jornada comienza con un almacén ligeramente más eficiente gracias a las mejoras adquiridas.

---

## Sensación que Debe Transmitir

- Ritmo rápido.
- Estrés controlado.
- Optimización constante.
- Progresión visible.
- "Solo un pedido más."

El jugador debe sentir que comenzó en un pequeño garaje improvisado y, con cada mejora, está construyendo una empresa logística cada vez más eficiente. Ese crecimiento visual y funcional será el principal incentivo para seguir jugando.
