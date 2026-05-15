extends StaticBody3D

class_name SandPile

@export var resource_amount: int = 100

func _ready() -> void:
    # Randomize rotation slightly for natural look
    rotation.y = randf_range(0, TAU)
    scale *= randf_range(0.8, 1.2)
    
    # Set up signal for clicking
    input_ray_pickable = true
    input_event.connect(_on_input_event)

func _on_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        print("Clicked on sand pile. Amount remaining: ", resource_amount)

func collect(amount: int) -> int:
    var actual_collected = min(amount, resource_amount)
    resource_amount -= actual_collected
    if resource_amount <= 0:
        # For now, let's keep it but at a small size or reset it
        resource_amount = 100 # Reset for gameplay flow
    return actual_collected
