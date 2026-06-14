class_name Item
extends Resource

enum ItemActions {
	NONE,
	TILL,
	WATER,
	PLANT,
	HARVEST
}

@export var name: String
@export var sprite: Texture2D
@export var stackable: bool = false

@export var action: ItemActions = ItemActions.NONE
@export var action_range: int = 3

@export var animations: SpriteFrames
