extends Node

@onready var map: Map = $Map
@onready var character: MainCharacter = $MainCharacter

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	character.global_position = map.spawn_point
	character.holding_item = GameState.inventory[GameState.inventory_select]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	GameState.score = map._dirt.get_used_cells().size()
	
	if Input.is_action_just_pressed("use"):
		if GameState.active_item:
			var action = GameState.active_item.action
			
			if action == Item.ItemActions.TILL:
				map.toggle_tile(character.global_position)
	
