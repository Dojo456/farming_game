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

@export var left_sprite: Texture2D
@export var down_sprite: Texture2D
@export var up_sprite: Texture2D

@export var animations: SpriteFrames
