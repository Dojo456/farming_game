extends Node

@onready var map: Map = $Map
@onready var character: MainCharacter = $Map/MainCharacter
@onready var cursor = $Map/CursorIndicator

# Label for debugging purposes
@onready var coord_label = $CanvasLayer/DebugHud/CharCoords

var cursor_locked = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	character.global_position = map.spawn_point
	character.holding_item = GameState.inventory[GameState.inventory_select].item

func perform_item_action(item: Item, tile: Vector2):
	var action = item.action
	
	match (action):
		Item.ItemActions.TILL:
			map.till_tile(tile)
		Item.ItemActions.WATER:
			map.water_tile(tile)
		Item.ItemActions.PLANT:
			var crop = Crops.from_seed(item)
			map.plant_crop_at_tile(tile, crop)
		_:
			pass
				
func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		use_active_item()
		
func use_active_item():
	if GameState.active_item:
		var mouse_pos = map.get_global_mouse_position()
		
		var current_cursor_tile = map.closest_tile(mouse_pos)
		cursor_locked = true
		
		var relative_dir_to_character = (mouse_pos - character.global_position).normalized().round()
		
		var use_item = func():
			if GameState.active_item.animations:
				await character.play_sprite_frame_once(GameState.active_item.animations, character.get_dir_string_from_vector(relative_dir_to_character))
			self.perform_item_action(GameState.active_item, current_cursor_tile)
			cursor_locked = false
		use_item.call()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	GameState.score = map._dirt.get_used_cells().size()
	
	if not cursor_locked:
		var cursor_pos = map.closest_tile(map.get_global_mouse_position())
		
		
		cursor.set_position(cursor_pos * map.tile_size)
		
	coord_label.text = str(map.closest_tile(character.global_position))
