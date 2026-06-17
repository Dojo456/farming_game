@tool

class_name PlantedCrop

extends Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var crop: Crop

@export var age = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if self.crop:
		sprite.sprite_frames = crop.growth_stages


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var i = 0
	var accuml = 0
	
	for stage in crop.stage_lengths.slice(0, -1):
		accuml += stage
		
		if age > accuml:
			i+=1
		else:
			break

	self.sprite.play(str(i))
