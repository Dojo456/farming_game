extends Node

@onready var map: Map = $Map
@onready var character: MainCharacter = $MainCharacter
@onready var cursor = $Map/CursorIndicator

var cursor_locked = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	character.global_position = map.spawn_point
	character.holding_item = GameState.inventory[GameState.inventory_select]

func perform_action(action: Item.ItemActions, tile: Vector2):
	match (action):
			Item.ItemActions.TILL:
				map.toggle_tile(tile)
			Item.ItemActions.WATER:
				pass
			_:
				pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	GameState.score = map._dirt.get_used_cells().size()
	
	if GameState.active_item:
		if Input.is_action_just_pressed("use"):
			var action = GameState.active_item.action
			
			var current_cursor_tile = map.closest_tile(map.get_global_mouse_position())
			cursor_locked = true
			
			var use_item = func():
				await character.play_sprite_frame_once(GameState.active_item.animations, character.dir)
				self.perform_action(action, current_cursor_tile)
				cursor_locked = false
			use_item.call()
		
		cursor.show()
		
		if not cursor_locked:
			var cursor_pos = map.closest_tile(map.get_global_mouse_position())
			
			cursor.set_position(cursor_pos * map.tile_size)
	else:
		cursor.hide()
