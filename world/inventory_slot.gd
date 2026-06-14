extends Resource

class_name InventorySlot

@export var item: Item
@export var count: int = 0

func _init(item: Item, count = 0) -> void:
	self.item = item
	
	if item.stackable and count > 0:
		self.count = count
	else:
		self.count = 1
