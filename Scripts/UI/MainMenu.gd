class_name MainMenu
extends Control

@onready var _btn_start: Button = $VBoxContainer/BtnStart
@onready var _btn_shop: Button = $VBoxContainer/BtnShop
@onready var _btn_exit: Button = $VBoxContainer/BtnExit

func _ready() -> void:
	_btn_start.pressed.connect(_on_start)
	_btn_shop.pressed.connect(_on_shop)
	_btn_exit.pressed.connect(_on_exit)

func _on_start() -> void:
	get_tree().change_scene_to_file("res://Scenes/TestLevel/TestLevel.tscn")

func _on_shop() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/Shop.tscn")

func _on_exit() -> void:
	get_tree().quit()
