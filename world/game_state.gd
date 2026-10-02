extends Node
class_name ClassGameState

var score: int = 0

# Inventory related variables
signal inventory_changed

var inventory: Array[InventorySlot] = [InventorySlot.new(preload("res://world/items/all/hoe_item.tres")), InventorySlot.new(preload("res://world/items/all/water_can_item.tres")), InventorySlot.new(preload("res://world/items/all/wheat_seed.tres"), 5),
InventorySlot.new(preload("res://world/items/all/sickle.tres"))]

var inventory_size = 8:
	set(val):
		_resize_inventory()

var inventory_select: int = 0:
	set(value):
		inventory_select = value
		inventory_changed.emit()
		
var active_item: Item:
	get():
		if inventory_select < inventory.size():
			var select = inventory.get(inventory_select)
			return select.item if select else null
		else:
			return null
			
func _resize_inventory():
	inventory.resize(inventory_size)
	
	for i in inventory.size():
		if inventory[i] == null:
			inventory[i] = InventorySlot.new(null, 0)

## Add an item to the player's inventory with an optional count variable.
## [br][br]
## @arg item: Item to be added [br]
## @arg count: count of the item to add, if item is not stackable, this is ignored
## [br][br]
## @returns true if item added, false if not
func add_item_to_inventory(item: Item, count: int = 1) -> bool:
	var changed = false
	
	# if item is stackable, search for existing not-full stack
	if item.stackable:
		var first_empty = null
		
		for slot in inventory:
			if first_empty == null and slot.item == null:
				first_empty = slot
				
			if is_same(slot.item, item):
				slot.count += count
				
				changed = true
				break
		
		# if has not add by end, attempt to add to free empty slot
		if first_empty != null and not changed:
			first_empty.item = item
			first_empty.count = count
			
			changed = true
	else: # find first empty slot
		for slot in inventory:
			if slot.item == null:
				slot.item = item
				slot.count = count if item.stackable else 1
				
				changed = true
				break

	if changed:
		inventory_changed.emit()
	
	return changed
	
## Remove first instance of an item to the player's inventory with an optional count variable. If item is not stackable, the slot is cleared. If item is stackable, the count amount is removed, if remaining amount is 0, slot is cleared.
## [br][br]
## @arg item: Item to be removed [br]
## @arg count: count of the item to remove, if item is not stackable, this is ignored
## [br][br]
## @returns true if item removed, false if not
func remove_item_from_inventory(item: Item, count: int = 1) -> bool:
	var changed = false
	
	# find first instance of item in inventory
	for slot in inventory:
		if is_same(slot.item, item):
			if item.stackable: # if stackable, only remove if has sufficient count
				if slot.count > count:
					slot.count -= count
					changed = true
					break
				elif slot.count == count: # just enough, clear slot
					slot.item = null
					slot.count = 0
					changed = true
					break
				# else, do nothing
			else: # not stackable, just remove the slot
				slot.item = null
				slot.count = 0
				changed = true
				break
				
	# did not find from inventory, return false
	
	if changed:
		inventory_changed.emit()
		
	return changed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_resize_inventory()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
