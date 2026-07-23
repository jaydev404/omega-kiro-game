# Package

## Objetivo

Representar físicamente una caja en el mundo del juego que el jugador pueda empujar y transportar.

## Funcionalidades

### Colisión física
- La caja no puede ser atravesada por el Player.
- El Player puede empujarla caminando contra ella.

### Interacción — Recoger (tecla E)
- Al presionar E estando cerca, el Player recoge la caja.
- La caja se adhiere al CarryPoint del Player y se mueve con él.
- El Player solo puede cargar una caja a la vez.

### Interacción — Soltar (tecla E)
- Si el Player ya carga una caja, presionar E la suelta en la posición actual.
- La caja recupera su colisión física al soltarse.

### Estados
- `FREE` → en el suelo, colisión activa, puede ser empujada.
- `CARRIED` → adherida al CarryPoint del Player, colisión desactivada.

## Restricciones
- Una caja no puede ser recogida si el Player ya carga otra.
- La caja no atraviesa paredes ni obstáculos cuando está en estado FREE.

## MVP
- Colisión física sólida.
- Empuje por contacto.
- Recoger y soltar con tecla E.
- Moverse con el Player al ser cargada.
- Placeholder visual (rectángulo de color).
