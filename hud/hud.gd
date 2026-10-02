extends Control

@onready var score_label: Label = %ScoreLabel
@onready var inventory_bar: InventoryRow = %InventoryBar

func update_inventory_display():
	inventory_bar.set_items(GameState.inventory.slice(0, 8))

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.inventory_changed.connect(update_inventory_display)
	
	update_inventory_display()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	score_label.text = "%sx" % GameState.score


func _on_inventory_bar_selection_changed(selection: int) -> void:
	GameState.inventory_select = selection
