@tool

class_name Map

extends Node2D

@export var state: MapState

@onready var spawn_point: Vector2 = $Marker2D.global_position
@onready var _base_water: TileMapLayer = $BaseWaterLayer
@onready var _dirt: TileMapLayer = $DirtLayer
@onready var _grass: TileMapLayer = $GrassLayer
@onready var _struct: TileMapLayer = $StructureLayer

var tile_size: Vector2i:
	get():
		return self._dirt.tile_set.tile_size

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var sync_from_editor = true
	
	if sync_from_editor:
		var state = MapState.new()
		
		var max_x = 0
		var max_y = 0
		# Take current tiles from editor and input them into the state
		
		for c in _base_water.get_used_cells():
			# Find the largest value for x and y of all layers and use that to set map size in state
			if c.x > max_x:
				max_x = c.x
			
			if c.y > max_y:
				max_y = c.y
				
		state._set_map_to_size(Vector2i(max_x, max_y))
		
		for c in _grass.get_used_cells():
			# get all land "grass" cells
			state._land[c.x][c.y] = true
			
		for c in _dirt.get_used_cells_by_id(2):
			# get all land "dirt" cells
			state._tilled[c.x][c.y] = true
			
		for c in _dirt.get_used_cells_by_id(3):
			# get all land "dirt" cells
			state._watered[c.x][c.y] = true

	else: # load from presaved state
		_sync_from_state()
	
	state.changed.connect(_sync_from_state)
	
func closest_tile(global_position: Vector2) -> Vector2i:
	return floor((global_position - self.global_position) / 
	Vector2(_dirt.tile_set.tile_size))
	
func _tile_pos(tile: Vector2i) -> Vector2:
	return floor(tile * Vector2i(_dirt.tile_set.tile_size))

@onready var _planted_crop = preload("res://world/map/structures/planted_crop.tscn")
func plant_crop_at_tile(tile: Vector2i, crop: Crop):
	var _dirt_data = _dirt.get_cell_tile_data(tile)
	if not (_dirt_data and _dirt_data.get_custom_data("watered")):
		return
		
	var struct_data = _struct.get_cell_source_id(tile)
	# Equal -1 if cell is empty, if not empty, return
	if struct_data != -1:
		return
	
	var new_crop: PlantedCrop = _planted_crop.instantiate()
	new_crop.crop = crop
	new_crop.age = 0
	new_crop.position = _tile_pos(tile) + (Vector2(_dirt.tile_set.tile_size) / 2)
	
	_struct.add_child(new_crop)
	_struct.set_cell(tile, 5, Vector2i.ZERO, 2)

func interact_at_tile(tile: Vector2i):
	pass

## Tile the tile at the given position.
## If only_test is true, does not actually till the tile. Can be useful for testing if a tile is tillable
##
## @return: true/false if the tile was tilled
func till_tile(tile: Vector2i, only_test: bool = false) -> bool:
	var tillable = false
	
	var grass_cell = _grass.get_cell_tile_data(tile)
	
	if grass_cell:
		tillable = grass_cell.get_custom_data("tillable")
		
	if not tillable:
		return false
	
	var current_cell = BetterTerrain.get_cell(_dirt, tile)
	
	# If is dirt, current_cell = 2 (dirt), else = -1
	
	BetterTerrain.set_cell(_dirt, tile, 2 if current_cell == -1 else -1)
	BetterTerrain.update_terrain_cell(_dirt, tile)
	
	return true
	
func water_tile(tile: Vector2i, only_test: bool = false) -> bool:
	var is_tilled = false
	
	var dirt_cell = _dirt.get_cell_tile_data(tile)
	
		
	if not dirt_cell:
		return false
	
	BetterTerrain.set_cell(_dirt, tile, 3)
	BetterTerrain.update_terrain_cell(_dirt, tile)
	
	return true
	
func _sync_from_state() -> void:
	# Clear all existing tiles from layers
	_base_water.clear()
	_grass.clear()
	_dirt.clear()
	_struct.clear()
	
	for i in self.state.map_size.y:
		for j in self.state.map_size.x:
			BetterTerrain.set_cell(_base_water, Vector2i(i, j), 0)
			
			var tile_coord = Vector2i(i, j)
			
			if state.tile_land(tile_coord):
				BetterTerrain.set_cell(_grass, tile_coord, 1)
			
			if state.tile_tilled(tile_coord):
				self.till_tile(tile_coord)
				
			if state.tile_watered(tile_coord):
				self.water_tile(tile_coord)
				
	BetterTerrain.update_terrain_area(_base_water, Rect2i(Vector2i.ZERO, state.map_size))
	BetterTerrain.update_terrain_area(_grass, Rect2i(Vector2i.ZERO, state.map_size))
	BetterTerrain.update_terrain_area(_dirt, Rect2i(Vector2i.ZERO, state.map_size))
	BetterTerrain.update_terrain_area(_struct, Rect2i(Vector2i.ZERO, state.map_size))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#func _physics_process(delta: float) -> void:
	#for i in self.state.map_size.y:
		#for j in self.state.map_size.x:
			#if state._tilled[i][j]:
				#self.till_tile(Vector2(i, j))
				#
			#if state._watered[i][j]:
				#self.water_tile(Vector2(i, j))


func _on_age_ticker_timeout() -> void:
	for child in _struct.get_children():
		if "age" in child:
			child.age += 1
