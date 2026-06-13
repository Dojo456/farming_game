class_name Item
extends Resource

enum ItemActions {
	NONE,
	TILL,
	PLANT,
	WATER
}

@export var name: String
@export var sprite: Texture2D

@export var action: ItemActions = ItemActions.NONE
@export var action_range: int = 3

@export var animations: SpriteFrames
