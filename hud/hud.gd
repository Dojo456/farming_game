extends Control

@onready var score_label: Label = %ScoreLabel
@onready var inventory_bar: InventoryRow = %InventoryBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	score_label.text = "%sx" % GameState.score
	
	inventory_bar.set_items(GameState.inventory.slice(0, 8))


func _on_inventory_bar_selection_changed(selection: int) -> void:
	StateInteractor.set_inventory_select(selection)
