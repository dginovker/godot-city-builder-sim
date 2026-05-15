extends CharacterBody3D

@export var orbit_radius: float = 8.0
@export var orbit_speed: float = 1.0
@export var orbit_center: Vector3 = Vector3.ZERO

var current_angle: float = 0.0

func _ready() -> void:
    # Initialize angle based on starting position relative to center
    var offset: Vector3 = global_position - orbit_center
    current_angle = atan2(offset.x, offset.z)
    
    # Set up signal for clicking
    input_ray_pickable = true
    input_event.connect(_on_input_event)

func _process(delta: float) -> void:
    # Update angle clockwise (increasing angle moves it right-down-left-up in sin/cos space)
    current_angle += orbit_speed * delta
    
    # Calculate new position
    var new_pos: Vector3 = orbit_center
    new_pos.x += sin(current_angle) * orbit_radius
    new_pos.z += cos(current_angle) * orbit_radius
    
    # Maintain current height (y)
    new_pos.y = global_position.y
    
    # Look in the direction of movement (ahead of current angle)
    var look_target: Vector3 = orbit_center
    look_target.x += sin(current_angle + 0.1) * orbit_radius
    look_target.z += cos(current_angle + 0.1) * orbit_radius
    look_target.y = global_position.y
    
    # Rotate to look at the point it is moving TOWARDS
    if global_position.distance_to(look_target) > 0.01:
        look_at(look_target, Vector3.UP)
    global_position = new_pos

func _on_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        print("Clicked on character: ", name)
        # Future UI logic here
