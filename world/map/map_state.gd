@tool

class_name MapState

extends Resource

@export var map_size: Vector2i:
	set(size):
		map_size = size
		emit_changed()

## 2D array of bools, intialized to nil
@export var _land: Array[Array]
## 2D array of bools, intialized to nil
@export var _tilled: Array[Array]
## 2D array of bools, intialized to nil
@export var _watered: Array[Array]
## 2D array of Node2Ds, intialized to nil
@export var _structs: Array[Array]

var has_pending_updates: bool = false

func set_map_to_size(size: Vector2i):
	var fill_data = func(arr: Array[Array]):
		arr.resize(size.y)
		for row in arr:
			row.resize(size.x)
			
	fill_data.call(_land)
	fill_data.call(_tilled)
	fill_data.call(_watered)
	fill_data.call(_structs)
	
	self.map_size = size
	
func _get_tile_data(tile: Vector2i, data: Array[Array], default: Variant = false) -> Variant:
	if data.size() > 0:
		var v = data[tile.y][tile.x]
		return v if v != null else default
		
	return default
	
func _update_tile_data(tile: Vector2i, value: Variant, arr: Array[Array]):
	arr[tile.y][tile.x] = value
	self.has_pending_updates = true
	self.emit_changed()
	
func tile_land(tile: Vector2i) -> bool:
	return _get_tile_data(tile, _land)

func tile_watered(tile: Vector2i) -> bool:
	return _get_tile_data(tile, _watered)
	
func tile_tilled(tile: Vector2i) -> bool:
	return _get_tile_data(tile, _tilled)
	
func tile_has_struct(tile: Vector2i) -> bool:
	return _get_tile_data(tile, _structs, null) != null
	
func tile_struct_get(tile: Vector2i) -> Node2D:
	return _get_tile_data(tile, _structs, null)

func set_tile_till(tile: Vector2i, value: bool):
	self._update_tile_data(tile, value, _tilled)
	
func set_tile_watered(tile: Vector2i, value: bool):
	self._update_tile_data(tile, value, _watered)

func set_tile_struct(tile: Vector2i, struct: Node2D):
	self._update_tile_data(tile, struct, _structs)
