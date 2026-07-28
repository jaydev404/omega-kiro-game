## Botón de mute — alterna entre sonido on/off.
## Busca el AudioStreamPlayer "Music" en el padre de la escena.
extends TextureButton

@export var icon_on: Texture2D
@export var icon_off: Texture2D

var _muted: bool = false

func _ready() -> void:
	# Restaurar estado de mute desde bus de audio
	_muted = AudioServer.is_bus_mute(AudioServer.get_bus_index("Master"))
	_update_icon()
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	_muted = not _muted
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), _muted)
	_update_icon()

func _update_icon() -> void:
	if _muted:
		texture_normal = icon_off
	else:
		texture_normal = icon_on
