# Delivery Truck

## Objetivo

Zona de entrega donde el player deposita cajas para completar entregas.
El camión actúa como destino final del loop de gameplay.

## Funcionalidades

### Zona de entrega (DeliveryZone)
- El player se acerca al camión cargando una caja.
- Al presionar E dentro de la zona, la caja se entrega al camión.
- La caja desaparece inmediatamente con una animación simple (flash/fade).
- El contador de entregas se incrementa en 1.

### Contador de entregas
- Lleva el total de cajas entregadas durante la sesión.
- Emite señal cada vez que cambia para que la UI pueda mostrarlo.

### Prioridad de interacción
- Si el player está en la zona del camión cargando una caja,
  el camión tiene prioridad sobre soltar la caja al suelo.
- Si el player no carga nada, entrar en la zona no hace nada.

## Restricciones
- Solo acepta cajas (PackageBody). No acepta otros interactuables.
- El player debe estar cargando activamente para poder entregar.
- No hay límite de entregas por jornada.

## MVP
- Zona de entrega con colisión tipo Area2D.
- Detección de entrada del player con caja.
- Entrega con tecla E → caja desaparece → contador +1.
- Señal `package_delivered(count)` para conectar a UI futura.
- Placeholder visual: rectángulo verde oscuro con label "CAMIÓN".
