# Drone Spawner

## Objetivo

Generar cajas nuevas de forma continua y automática mediante un dron que llega,
deposita una caja en un punto fijo, y se retira.

## Funcionalidades

### Spawn automático
- El dron aparece desde fuera de la pantalla a intervalos regulares.
- Vuela hasta el punto de depósito (DropPoint).
- Deposita una caja y se retira por donde vino.
- Una vez fuera de pantalla, el dron se destruye.

### Límite de cajas
- El spawner mantiene un conteo de cajas activas en escena.
- Si se alcanza el límite máximo, el próximo spawn se pospone hasta que
  el conteo baje por debajo del límite.
- Cuando una caja es recogida por el player, el conteo se reduce.

### Indicador visual del dron (placeholder)
- Rectángulo gris oscuro que se mueve en línea recta hacia el DropPoint
  y regresa al punto de origen.

## Restricciones
- Solo puede haber un dron en vuelo a la vez.
- El dron no colisiona con el player ni con las cajas durante el vuelo.
- No puede depositar una caja si el DropPoint está ocupado por otra caja.

## MVP
- Spawn periódico con intervalo configurable.
- Límite máximo de cajas configurable.
- Animación de llegada y salida del dron (movimiento lineal).
- Placeholder visual para el dron.
