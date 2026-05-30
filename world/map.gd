extends Node2D

class_name Map

@onready var spawn_point: Vector2 = $Marker2D.global_position
@onready var _dirt: TileMapLayer = $DirtLayer
@onready var _grass: TileMapLayer = $GrassLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func toggle_tile(global_position: Vector2):
	var offset = (global_position - self.global_position) / Vector2(_dirt.tile_set.tile_size)
	
	var tillable = false
	
	var grass_cell = _grass.get_cell_tile_data(offset)
	
	if grass_cell:
		tillable = grass_cell.get_custom_data("tillable")
		
	if not tillable:
		return
	
	var is_dirt = BetterTerrain.get_cell(_dirt, offset)
	
	BetterTerrain.set_cell(_dirt, offset, is_dirt * -1)
	BetterTerrain.update_terrain_cell(_dirt, offset)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
