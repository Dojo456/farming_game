@tool
class_name InventoryRow
extends Control

@onready var _item_list: ItemList = $ItemList

@export var _items: Array[Item] = []
var selected = 0

func update():
	_item_list.clear()
	
	for item in _items:		
		if item:
			_item_list.add_item(item.name, item.sprite)
	
	_item_list.select(self.selected)

func set_items(items: Array[Item]):
	if items != _items:
		self._items = items
		self.update()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.update()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_item_list_item_selected(index: int) -> void:
	self.selected = selected
	GameState.inventory_select = index
