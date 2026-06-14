extends Node

var score: int = 0

# Inventory related variables
signal inventory_select_changed(int)

var inventory: Array[InventorySlot] = [InventorySlot.new(preload("res://world/items/all/hoe_item.tres")), InventorySlot.new(preload("res://world/items/all/water_can_item.tres")), InventorySlot.new(preload("res://world/items/all/wheat_seed.tres"), 5)]

var inventory_select: int = 0:
	set(value):
		inventory_select = value
		inventory_select_changed.emit(value)
		
var active_item: Item:
	get():
		return inventory.get(inventory_select).item

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
