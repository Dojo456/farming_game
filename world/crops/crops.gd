extends Node

class_name Crops

static var _crops: Array[Crop] = [
	preload("res://world/crops/all/wheat.tres")
]

static func _static_init():
	pass
	
static func from_seed(seed: Item) -> Crop:
	for crop in _crops:
		if crop.seed_item == seed:
			return crop
			
	return null
