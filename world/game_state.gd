extends Node

var score: int = 0

signal inventory_select_changed(int)

@export var inventory: Array[Item] = [preload("res://world/items/all/water_can_item.tres"), preload("res://world/items/all/hoe_item.tres")]
var inventory_select: int = 0:
	set(value):
		inventory_select = value
		inventory_select_changed.emit(value)
		
var active_item: Item:
	get():
		return inventory.get(inventory_select)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
