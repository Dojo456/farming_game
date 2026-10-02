@tool

class_name Map

extends Node2D

@export var state: MapState

@onready var spawn_point: Vector2 = $Marker2D.global_position
@onready var _base_water_layer: TileMapLayer = $BaseWaterLayer
@onready var _dirt_layer: TileMapLayer = $DirtLayer
@onready var _grass_layer: TileMapLayer = $GrassLayer
@onready var _struct_layer: TileMapLayer = $StructureLayer

var tile_size: Vector2i:
	get():
		return self._dirt_layer.tile_set.tile_size

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var sync_from_editor = true
	
	if sync_from_editor:
		state = MapState.new()
		
		var max_x = 0
		var max_y = 0
		# Take current tiles from editor and input them into the state
		
		for c in _base_water_layer.get_used_cells():
			# Find the largest value for x and y of all layers and use that to set map size in state
			if c.x > max_x:
				max_x = c.x
			
			if c.y > max_y:
				max_y = c.y
				
		state.set_map_to_size(Vector2i(max_x, max_y))
		
		var update_arrs = func(cells: Array[Vector2i], arr, val: bool = true):
			for c in cells:
				arr[c.y][c.x] = true
				
		# Land cells
		update_arrs.call(_grass_layer.get_used_cells(), state._land)
		
		# Land that has been tilled
		update_arrs.call(_dirt_layer.get_used_cells_by_id(2), state._tilled)
		# Tilled and also watered
		update_arrs.call(_dirt_layer.get_used_cells_by_id(3), state._watered)
		
		# Special way for inserting structs
		for s in _struct_layer.get_children():
			if s is Node2D:
				var tile = closest_tile(s.global_position)
				
				state._structs[tile.y][tile.x] = s

	else: # load from presaved state
		_sync_from_state()
	
func closest_tile(global_position: Vector2) -> Vector2i:
	return floor((global_position - self.global_position) / 
	Vector2(_dirt_layer.tile_set.tile_size))
	
func _tile_pos(tile: Vector2i) -> Vector2:
	return floor(tile * Vector2i(_dirt_layer.tile_set.tile_size))

@onready var _planted_crop = preload("res://world/map/structures/planted_crop.tscn")
func plant_crop_at_tile(tile: Vector2i, crop: Crop):	
	# Check tile is watered and no existing structs
	if state.tile_watered(tile) and not state.tile_has_struct(tile):
		var new_crop: PlantedCrop = _planted_crop.instantiate()
		new_crop.crop = crop
		new_crop.age = 0
		new_crop.position = _tile_pos(tile) + (Vector2(_dirt_layer.tile_set.tile_size) / 2)
		state.set_tile_struct(tile, new_crop)
		
		GameState.remove_item_from_inventory(crop.seed_item)

func interact_at_tile(tile: Vector2i):
	# Check if there is a mature crop at the tile
	harvest_tile(tile)

## Tile the tile at the given position.
## If only_test is true, does not actually till the tile. Can be useful for testing if a tile is tillable
##
## @return: true/false if the tile was tilled
func till_tile(tile: Vector2i, only_test: bool = false) -> bool:
	if state.tile_tilled(tile) or state.tile_watered(tile): # If tile is already tilled or watered, un-till it
		state.set_tile_till(tile, false)
		state.set_tile_watered(tile, false)
		return true
	elif state.tile_land(tile): # If tile is land, allow till
		state.set_tile_till(tile, true)
		return true
	
	return false
	
func water_tile(tile: Vector2i, only_test: bool = false) -> bool:
	if state.tile_tilled(tile):
		state.set_tile_watered(tile, true)
		return true
		
	return false
	
func harvest_tile(tile: Vector2i, only_test: bool = false):
	var s = state.tile_struct_get(tile)
	
	# Is a crop, handle harvest and add crop item to inventory
	if s is PlantedCrop:
		# Check planted crop is mature
		
		var max_age = 0
		for stage_length in s.crop.stage_lengths:
			max_age += stage_length

		if s.age > max_age: # Can harvest
			GameState.add_item_to_inventory(s.crop.harvested_item)
			
			# TODO: For now assume that structs should be destroyed on harvest
			state.set_tile_struct(tile, null)
	
## Perform all drawing operations onto TileMapLayers based on MapState
func _sync_from_state() -> void:
	# Clear all existing tiles from layers
	_base_water_layer.clear()
	_grass_layer.clear()
	_dirt_layer.clear()
	_struct_layer.clear()
	
	var structs_to_free = {}
	for s in _struct_layer.get_children():
		structs_to_free[s] = true
	
	for i in self.state.map_size.x:
		for j in self.state.map_size.y:
			BetterTerrain.set_cell(_base_water_layer, Vector2i(i, j), 0)
			
			var tile_coord = Vector2i(i, j)
			
			if state.tile_land(tile_coord):
				BetterTerrain.set_cell(_grass_layer, tile_coord, 1)
			
			if state.tile_tilled(tile_coord):
				BetterTerrain.set_cell(_dirt_layer, tile_coord, 2)
				
			if state.tile_watered(tile_coord):
				BetterTerrain.set_cell(_dirt_layer, tile_coord, 3)
				
			if state.tile_has_struct(tile_coord):
				var c_struct = state.tile_struct_get(tile_coord)
				_struct_layer.add_child(c_struct)
				_struct_layer.set_cell(tile_coord)
				structs_to_free.erase(c_struct)
				
	# Remove structs that no longer exist in the state from struct layer
	for s in structs_to_free.keys():
		s.queue_free()
	
	BetterTerrain.update_terrain_area(_base_water_layer, Rect2i(Vector2i.ZERO, state.map_size))
	BetterTerrain.update_terrain_area(_grass_layer, Rect2i(Vector2i.ZERO, state.map_size))
	BetterTerrain.update_terrain_area(_dirt_layer, Rect2i(Vector2i.ZERO, state.map_size))
	BetterTerrain.update_terrain_area(_struct_layer, Rect2i(Vector2i.ZERO, state.map_size))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	if state.has_pending_updates and not Engine.is_editor_hint():
		_sync_from_state()
		state.has_pending_updates = false

func _on_age_ticker_timeout() -> void:
	for child in _struct_layer.get_children():
		if "age" in child:
			child.age += 1
