extends Node2D

class_name Map

@onready var spawn_point: Vector2 = $Marker2D.global_position
@onready var _base_water: TileMapLayer = $BaseWaterLayer
@onready var _dirt: TileMapLayer = $DirtLayer
@onready var _watered_dirt: TileMapLayer = $DirtLayer/WateredDirtLayer
@onready var _grass: TileMapLayer = $GrassLayer

var tile_size: Vector2:
	get():
		return self._dirt.tile_set.tile_size

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
func closest_tile(global_position: Vector2) -> Vector2:
	return floor((global_position - self.global_position) / 
	Vector2(_dirt.tile_set.tile_size))
	
## Tile the tile at the given position.
## If only_test is true, does not actually till the tile. Can be useful for testing if a tile is tillable
##
## @return: true/false if the tile was tilled
func till_tile(tile: Vector2, only_test: bool = false) -> bool:
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
	
func water_tile(tile: Vector2, only_test: bool = false) -> bool:
	var is_tilled = false
	
	var dirt_cell = _dirt.get_cell_tile_data(tile)
	
		
	if not dirt_cell:
		return false
	
	BetterTerrain.set_cell(_dirt, tile, 3)
	BetterTerrain.update_terrain_cell(_dirt, tile)
	
	return true
	
	return true

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
