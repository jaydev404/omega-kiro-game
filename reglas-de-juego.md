# Reglas del Juego - Startup Logistics

> Documento maestro de diseno. Define todas las mecanicas, entidades y comportamientos.

---

## Concepto

Arcade survival de recoleccion y entrega. El jugador recoge paquetes lanzados por drones y los entrega en puntos especificos. La partida dura max 25 minutos y termina al perder toda la vida o acabarse el tiempo.

---

## Estructura de una Partida

[Inicio] > [Gameplay: 25 min max] > [Evento Final: Bombardeo] > [Game Over] > [Resumen + Tienda]

- La partida inicia con el jugador en el escenario.
- Los drones entregan paquetes, monedas, power-ups y bombas.
- El jugador recoge y entrega para ganar dinero y XP.
- A los 25 minutos: bombardeo masivo (game over forzado).
- Si pierde todas sus vidas antes: game over anticipado.
- Al terminar: pantalla de resumen. El dinero se acumula entre partidas.

---

## Jugador

### Estadisticas Base (nivel 1, sin power-ups)

| Stat | Valor inicial | Descripcion |
|---|---|---|
| Vida | 1 corazon (4 fragmentos) | Cada corazon = 4 fragmentos |
| Velocidad | 150 px/s (configurable) | Velocidad de movimiento base |
| Fuerza | 1.0 | floor(fuerza) = paquetes simultaneos |
| Nivel | 1 | Nivel actual de la partida |
| XP | 0 | Experiencia acumulada en la partida |
| Dinero (partida) | 0 | Dinero ganado durante esta partida |

### Vida y Corazones

- Cada corazon = 4 fragmentos.
- Vida inicial: 1 corazon = 4 fragmentos totales.
- Al perder todos los fragmentos: game over.
- Power-ups permanentes agregan corazones al inicio.

### Fuerza y Capacidad de Carga

- capacidad_de_carga = floor(fuerza)
- Fuerza 1.0 = carga 1 paquete.
- Fuerza 1.5 = carga 1 (floor = 1).
- Fuerza 2.0 = carga 2 paquetes.
- Se acumula por fracciones al subir de nivel.

### Invulnerabilidad

- Al recibir dano: 2 segundos de invulnerabilidad.
- Visual: parpadeo del sprite.

---

## Sistemas de Progresion

### XP y Level Up (temporal, solo la partida)

| Nivel | XP requerida | XP acumulada |
|---|---|---|
| 1-2 | 50 | 50 |
| 2-3 | 100 | 150 |
| 3-4 | 150 | 300 |
| 4-5 | 200 | 500 |
| 5-6 | 250 | 750 |
| 6-7 | 300 | 1050 |
| 7-8 | 350 | 1400 |
| 8-9 | 400 | 1800 |
| 9-10 | 450 | 2250 |
| 10+ | 500 (fijo) | - |

Formula: xp_para_nivel(n) = min(50 * n, 500)
Parametizable via Resource o export.

Al subir de nivel: ventana de seleccion. Elige UNA mejora temporal:
- +1 fragmento de vida (cura y aumenta max)
- +velocidad de movimiento
- +0.5 fuerza (fraccion configurable)
- Sprint (habilidad)
- Regeneracion de vida (lenta)
- Habilidad de lanzamiento (lanzar paquetes/bombas)

Las mejoras de level up son TEMPORALES: se pierden al terminar la partida.

### Dinero (persistente entre partidas)

- Se gana al entregar paquetes.
- Se acumula entre partidas.
- Se gasta en la Tienda de Power-ups.

### Power-ups Permanentes (Tienda)

| ID | Nombre | Efecto | Notas |
|---|---|---|---|
| hp_up | Vida Extra | +1 corazon al inicio | Acumulable |
| speed_up | Velocidad | +% velocidad base | Niveles |
| force_up | Fuerza | +fuerza base | Niveles |
| revive | Revivir | Al morir revive con 1 corazon (1 uso/partida) | Unico |
| ally_drone | Dron Aliado | Dron NPC que recoge y entrega | Unico |

Costos por definir. Configurables por Resource.

---

## Entidades del Escenario

### Drones

- Llegan desde fuera del escenario.
- Dejan drops en posiciones aleatorias.
- No colisionan con el jugador.
- Cantidad y velocidad aumenta con el tiempo.
- Pueden cargar: paquetes, monedas, power-ups, bombas.
- Si dejan paquete donde ya hay otro: ambos se destruyen + dano en radio.

### Puntos de Entrega

- Cada tipo de paquete tiene su punto de entrega fijo.
- Todos presentes desde el inicio.
- Nuevos tipos se desbloquean con el avance.

### Tipos de Drop

| Drop | Recogida | Efecto |
|---|---|---|
| Paquete (A, B, C...) | Tecla E | Entrega en punto fijo: XP + dinero |
| Moneda | Auto al tocar | Dinero inmediato |
| Power-up | Auto al tocar | Ventana de seleccion de stat |
| Bomba inmediata | No se recoge | Explota al caer |
| Bomba timer | Recoger y lanzar | Explota tras X segundos |
| Paquete sorpresa | Tecla E | Se revela: moneda, power-up o bomba |

### Bombas

Bomba Inmediata:
- Explota al contacto con el suelo.
- Dano: 2 fragmentos.
- Radio: 64 px (configurable).

Bomba Timer:
- Countdown al llegar al suelo.
- Timer: 3 segundos (configurable).
- Parpadeo que se acelera.
- Dano: 2 fragmentos.
- Radio: 80 px (configurable).
- El jugador puede recogerla y lanzarla.

### Destruccion por Apilamiento

- Dron deja paquete donde ya hay otro: ambos se destruyen.
- Dano si jugador en radio: 1 fragmento.
- Radio: 48 px (configurable).

---

## Tabla de Dano

| Fuente | Dano (fragmentos) | Radio | Invulnerabilidad |
|---|---|---|---|
| Bomba inmediata | 2 | 64 px | 2s |
| Bomba timer | 2 | 80 px | 2s |
| Colision paquetes | 1 | 48 px | 2s |

---

## Evento Final (25 minutos)

- A los 25:00 drones normales desaparecen.
- Drones de bombardeo masivo aparecen.
- Bombas continuas y aceleradas.
- Solo sobrevivir (no se puede entregar).
- Bonus: segundos_sobrevividos * multiplicador.
- Termina cuando el jugador muere.

---

## Curva de Dificultad

| Tiempo | Paquetes | Drones | Velocidad | Bombas |
|---|---|---|---|---|
| 0:00 - 2:00 | Solo A | 2 | Lenta | Ninguna |
| 2:00 - 5:00 | A + B | 3 | Normal | Alguna timer |
| 5:00 - 10:00 | A + B + C | 4-5 | Normal+ | Timer + inmediatas |
| 10:00 - 18:00 | Todos | 5-8 | Rapida | Frecuentes |
| 18:00 - 25:00 | Todos + sorpresas | 8-12 | Muy rapida | Muchas |
| 25:00+ | Evento Final | Bombardeo | - | Solo bombas |

Todos los valores parametrizables.

---

## Pantalla de Inicio

- Dinero acumulado visible.
- Jugar: inicia partida.
- Power-ups: tienda permanente.
- Salir: cierra el juego.

---

## HUD en Partida

| Posicion | Contenido |
|---|---|
| Superior izquierda | Corazones (fragmentos) |
| Superior centro | Timer (25:00 countdown) |
| Superior derecha | Nivel + barra XP |
| Inferior izquierda | Dinero partida |
| Inferior derecha | Carga (paquetes/capacidad) |
| Centro | Indicador interaccion |

---

## Dron Aliado (power-up permanente)

- NPC autonomo.
- Recoge paquetes automaticamente.
- Entrega en punto correcto.
- Mas lento que el jugador.
- No recoge monedas ni power-ups.
- No recibe dano.
- Prioriza paquete mas cercano.
