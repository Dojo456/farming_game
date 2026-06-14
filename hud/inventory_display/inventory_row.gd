@tool
class_name InventoryRow
extends Control

@onready var _item_list: GridContainer = $PanelContainer/HBoxContainer

@export var row_size = 8
@export var _slots: Array[InventorySlot] = []
@export var selected = 0

var blank_texture: Texture2D

signal selection_changed(selction: int)

func set_selected(val: int):
	self.selected = val
	selection_changed.emit(val)

func set_items(slots: Array[InventorySlot]):		
	var resized = slots.duplicate()
	resized.resize(row_size)
	
	if resized == _slots:
		return
		
	_slots = resized
		
	# Clear items list
	for child in self._item_list.get_children():
		child.queue_free()
	
	var i = 0
	
	for slot in resized:
		var display: InventorySlotDisplay = InventorySlotDisplayScene.instantiate()
		display.slot = slot
		display.pressed.connect(func(): set_selected(i))
		_item_list.add_child(display)
		i+=1
		
const InventorySlotDisplayScene = preload("res://hud/inventory_display/inventory_slot_display.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_slots.resize(self.row_size)
	
	self.set_size(Vector2((self.row_size * 40) + 8, 48))
	
	if not Engine.is_editor_hint():
		set_items(_slots)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var i = 0
	for child in _item_list.get_children():
		child.active = i == selected
		i+=1

const StateInteractor = preload("res://world/state_interactor.gd")

func _on_item_list_item_selected(index: int) -> void:
	self.selected = selected
	StateInteractor.set_inventory_select(index)
