extends Control

var current_gloop: Node3D = null

func _ready() -> void:
    hide()
    add_to_group("ui")

func show_job_menu(gloop: Node3D) -> void:
    current_gloop = gloop
    show()
    # Center it? Or position near gloop? Screen center is easier for now.
    global_position = get_viewport().get_mouse_position()

func _on_idle_button_pressed() -> void:
    if current_gloop:
        current_gloop.set_job(0) # Job.IDLE
    hide()

func _on_expand_button_pressed() -> void:
    if current_gloop:
        current_gloop.set_job(1) # Now maps to Job.EXPAND in new enum
    hide()

func _on_close_button_pressed() -> void:
    hide()
