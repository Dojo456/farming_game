@tool
extends Control

class_name InventorySlotDisplay

@export var slot: InventorySlot
@export var active: bool = false

@onready var _texture = $MarginContainer/TextureRect
@onready var _label = $Label
@onready var _panel = $Panel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if self.slot:
		_texture.texture = slot.item.sprite
		_label.text = str(slot.count) if slot.item.stackable else ""
	else:
		_texture.texture = null
		_label.text = ""
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_panel.visible = self.active

signal pressed

func _on_button_button_down() -> void:
	pressed.emit()
