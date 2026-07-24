## Visual del player usando AnimatedSprite2D.
## Reproduce animaciones de caminar y carry en 4 direcciones usando sprite sheets.
class_name PlayerVisual
extends AnimatedSprite2D

var _facing := Vector2.DOWN
var _is_moving := false
var _is_carrying := false

func _ready() -> void:
	play("walk_down")
	stop()

func set_carrying(carrying: bool) -> void:
	_is_carrying = carrying
	# Actualizar animación actual según el estado
	if _is_moving:
		var anim_name := _get_animation_name(_facing)
		if animation != anim_name:
			play(anim_name)
	else:
		var anim_name := _get_animation_name(_facing)
		animation = anim_name
		stop()
		if _is_lateral(animation):
			set_frame_and_progress(1, 0.0)

func set_facing(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		_is_moving = false
		stop()
		# Al detenerse en izquierda/derecha, mostrar frame con pies quietos (frame 1)
		if _is_lateral(animation):
			set_frame_and_progress(1, 0.0)
		return

	_is_moving = true
	_facing = direction

	var anim_name := _get_animation_name(direction)
	if animation != anim_name:
		play(anim_name)
	elif not is_playing():
		play(anim_name)

func _get_animation_name(direction: Vector2) -> StringName:
	var prefix := &"carry_" if _is_carrying else &"walk_"

	if abs(direction.x) >= abs(direction.y):
		if direction.x > 0:
			return prefix + &"right"
		else:
			return prefix + &"left"
	else:
		if direction.y > 0:
			return prefix + &"down"
		else:
			return prefix + &"up"

func _is_lateral(anim: StringName) -> bool:
	return anim == &"walk_left" or anim == &"walk_right" \
		or anim == &"carry_left" or anim == &"carry_right"
