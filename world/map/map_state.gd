@tool

class_name MapState

extends Resource

@export var map_size: Vector2i:
	set(size):
		map_size = size
		_set_map_to_size(size)
		emit_changed()

@export var _land: Array[Array]
@export var _tilled: Array[Array]
@export var _watered: Array[Array]

func _set_map_to_size(size: Vector2i):
	var fill_data = func(arr: Array[Array]):
		arr.resize(size.y)
		for row in arr:
			row.resize(size.x)
			
	fill_data.call(_land)
	fill_data.call(_tilled)
	fill_data.call(_watered)
	
func _get_tile_data(tile: Vector2i, data: Array[Array]) -> bool:
	if data.size() > 0:
		return data[tile.x][tile.y]
		
	return false
	
func _update_tile_data(tile: Vector2i, value: bool, arr: Array[Array]):
	arr[tile.y][tile.x] = value
	self.emit_changed()
	
func tile_land(tile: Vector2i) -> bool:
	return _get_tile_data(tile, _land)

func tile_watered(tile: Vector2i) -> bool:
	return _get_tile_data(tile, _watered)
	
func tile_tilled(tile: Vector2i) -> bool:
	return _get_tile_data(tile, _tilled)

func set_tile_till(tile: Vector2i, value: bool):
	self._update_tile_data(tile, value, _tilled)
	
func set_tile_watered(tile: Vector2i, value: bool):
	self._update_tile_data(tile, value, _watered)
