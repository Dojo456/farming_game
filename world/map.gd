extends Node2D

class_name Map

@onready var spawn_point: Vector2 = $Marker2D.global_position
@onready var _dirt: TileMapLayer = $DirtLayer
@onready var _grass: TileMapLayer = $GrassLayer

var tile_size: Vector2:
	get():
		return self._dirt.tile_set.tile_size

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func closest_tile(global_position: Vector2) -> Vector2:
	return floor((global_position - self.global_position) / 
	Vector2(_dirt.tile_set.tile_size))

func toggle_tile_at_position(global_position: Vector2):
	var tile = self.closest_tile(global_position)
	
	self.toggle_tile(tile)
	
func toggle_tile(tile: Vector2):
	var tillable = false
	
	var grass_cell = _grass.get_cell_tile_data(tile)
	
	if grass_cell:
		tillable = grass_cell.get_custom_data("tillable")
		
	if not tillable:
		return
	
	var is_dirt = BetterTerrain.get_cell(_dirt, tile)
	
	BetterTerrain.set_cell(_dirt, tile, is_dirt * -1)
	BetterTerrain.update_terrain_cell(_dirt, tile)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
