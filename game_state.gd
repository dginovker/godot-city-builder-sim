extends Node

signal sand_changed(new_count: int)
signal expansion_changed(new_progress: float)

var sand_count: int = 0:
    set(value):
        sand_count = value
        sand_changed.emit(sand_count)

var expansion_progress: float = 0.0:
    set(value):
        expansion_progress = value
        expansion_changed.emit(expansion_progress)

var expansion_cost: float = 100.0
