extends Control

@onready var count_label: Label = %Count
@onready var exp_label: Label = %ExpCount

func _ready() -> void:
    GameState.sand_changed.connect(_on_sand_changed)
    GameState.expansion_changed.connect(_on_expansion_changed)
    count_label.text = str(GameState.sand_count)
    exp_label.text = str(int(GameState.expansion_progress / GameState.expansion_cost * 100)) + "%"

func _on_sand_changed(new_count: int) -> void:
    count_label.text = str(new_count)

func _on_expansion_changed(new_progress: float) -> void:
    exp_label.text = str(int(new_progress / GameState.expansion_cost * 100)) + "%"

func update_expansion_progress(percentage: float) -> void:
    exp_label.text = str(int(percentage)) + "%"
