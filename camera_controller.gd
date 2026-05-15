extends Node3D

@export var rotation_speed: float = 0.5
@export var zoom_speed: float = 1.0
@export var min_zoom: float = 5.0
@export var max_zoom: float = 100.0
@export var smooth_speed: float = 10.0

@onready var spring_arm: SpringArm3D = $SpringArm3D

@export var key_rotation_speed: float = 2.0

var target_rotation_x: float = -30.0
var target_rotation_y: float = 45.0
var target_zoom: float = 40.0
var is_panning: bool = false

func _ready() -> void:
    rotation_degrees.x = target_rotation_x
    rotation_degrees.y = target_rotation_y
    spring_arm.spring_length = target_zoom

func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_MIDDLE:
            is_panning = event.pressed
            if is_panning:
                Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
            else:
                Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
        
        if event.button_index == MOUSE_BUTTON_WHEEL_UP:
            target_zoom = clamp(target_zoom - zoom_speed, min_zoom, max_zoom)
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            target_zoom = clamp(target_zoom + zoom_speed, min_zoom, max_zoom)

    if event is InputEventMouseMotion and is_panning:
        target_rotation_y -= event.relative.x * rotation_speed
        target_rotation_x -= event.relative.y * rotation_speed
        target_rotation_x = clamp(target_rotation_x, -80, -10)

func _process(delta: float) -> void:
    # Arrow key controls
    var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    if input_dir != Vector2.ZERO:
        target_rotation_y -= input_dir.x * key_rotation_speed
        target_rotation_x += input_dir.y * key_rotation_speed
        target_rotation_x = clamp(target_rotation_x, -80, -10)

    rotation_degrees.x = lerp(rotation_degrees.x, target_rotation_x, delta * smooth_speed)
    rotation_degrees.y = lerp(rotation_degrees.y, target_rotation_y, delta * smooth_speed)
    spring_arm.spring_length = lerp(spring_arm.spring_length, target_zoom, delta * smooth_speed)
