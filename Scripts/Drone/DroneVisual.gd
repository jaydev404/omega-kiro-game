## Visual del dron usando AnimatedSprite2D.
## Usa sprite sheet de 128x128 (4 frames en grid 2x2, cada frame 64x64).
class_name DroneVisual
extends AnimatedSprite2D

func _ready() -> void:
	play("fly")
