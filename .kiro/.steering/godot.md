# Godot

Este proyecto utiliza exclusivamente el motor 2D de Godot.

Siempre utilizar:

- Node2D
- CharacterBody2D
- Area2D
- CollisionShape2D
- Sprite2D
- AnimatedSprite2D
- TileMapLayer

No utilizar componentes 3D.

## Organización

Cada objeto interactuable debe ser una escena independiente.

Ejemplos:

Player.tscn

Package.tscn

Shelf.tscn

PackagingTable.tscn

DispatchZone.tscn

## Colisiones

Todas las colisiones deben implementarse utilizando CollisionShape2D.

## Cámara

Camera2D

Fija.

Sin rotación.

El mapa completo debe permanecer visible durante el MVP.