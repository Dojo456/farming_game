class_name Crop
extends Resource

@export var seed_item: Item
@export var harvested_item: Item

@export var growth_stages: SpriteFrames
@export var stage_lengths: Array[int]

func _init() -> void:
	if growth_stages:
		assert(len(growth_stages.get_frame_count("default")) == len(stage_lengths))
