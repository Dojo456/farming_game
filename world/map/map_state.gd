class_name MapState

extends Resource

@export var map_size: Vector2

var _land: Array[Array]
@export var _tilled: Array[Array]
var _watered: Array[Array]

func _init(map_size: Vector2) -> void:
	self.map_size = map_size
	
	var fill_data = func(arr: Array):
		arr.resize(map_size.y)
		
		for row in arr:
			row.resize(map_size.x)
			
			arr.fill(false)
			
	fill_data.callv(_land)
	fill_data.callv(_tilled)
	fill_data.callv(_watered)
	
func _get_tile_data(tile: Vector2, data: Array[Array]) -> bool:
	return data[tile.y][tile.x]
	
func _update_tile_data(tile: Vector2, value: bool, arr: Array[Array]):
	arr[tile.y][tile.x] = value
	self.emit_changed()
	
func tile_land(tile: Vector2) -> bool:
	return _get_tile_data(tile, _land)

func tile_watered(tile: Vector2) -> bool:
	return _get_tile_data(tile, _watered)
	
func tile_tilled(tile: Vector2) -> bool:
	return _get_tile_data(tile, _tilled)

func set_tile_till(tile: Vector2, value: bool):
	self._update_tile_data(tile, value, _tilled)
	
func set_tile_watered(tile: Vector2, value: bool):
	self._update_tile_data(tile, value, _watered)
