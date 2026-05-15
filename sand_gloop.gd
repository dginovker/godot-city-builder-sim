extends "res://character_base.gd"

enum Job { IDLE, EXPAND }

var current_job: Job = Job.IDLE
var target_node: Node3D = null
var is_working: bool = false
var work_timer: float = 0.0
var held_sand: int = 0
var is_wet: bool = false

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var model: Node3D = $Model

var hud_scene: PackedScene = preload("res://ui/hud.tscn")
var menu_scene: PackedScene = preload("res://ui/job_menu.tscn")

func _ready() -> void:
    super._ready()
    _setup_animations()
    call_deferred("_instance_ui")

func _instance_ui() -> void:
    if get_tree().get_nodes_in_group("ui_instanced").size() == 0:
        var canvas = CanvasLayer.new()
        canvas.add_to_group("ui_instanced")
        get_tree().root.add_child(canvas)
        
        var hud = hud_scene.instantiate()
        canvas.add_child(hud)
        
        var menu = menu_scene.instantiate()
        canvas.add_child(menu)

func _setup_animations() -> void:
    var anim_lib: AnimationLibrary = AnimationLibrary.new()
    var walk_anim: Animation = Animation.new()
    
    walk_anim.length = 0.8
    walk_anim.loop_mode = Animation.LOOP_LINEAR
    
    var scale_track: int = walk_anim.add_track(Animation.TYPE_VALUE)
    walk_anim.track_set_path(scale_track, "Model:scale")
    walk_anim.track_insert_key(scale_track, 0.0, Vector3(1, 1, 1))
    walk_anim.track_insert_key(scale_track, 0.4, Vector3(1.1, 0.8, 1.1))
    walk_anim.track_insert_key(scale_track, 0.8, Vector3(1, 1, 1))
    
    var pos_track: int = walk_anim.add_track(Animation.TYPE_VALUE)
    walk_anim.track_set_path(pos_track, "Model:position")
    walk_anim.track_insert_key(pos_track, 0.0, Vector3(0, 2.4, 0))
    walk_anim.track_insert_key(pos_track, 0.4, Vector3(0, 1.9, 0))
    walk_anim.track_insert_key(pos_track, 0.8, Vector3(0, 2.4, 0))
    
    anim_lib.add_animation("walk", walk_anim)
    anim_player.add_animation_library("", anim_lib)
    anim_player.play("walk")

func _process(delta: float) -> void:
    match current_job:
        Job.IDLE:
            super._process(delta)
        Job.EXPAND:
            _process_expand(delta)

func _process_expand(delta: float) -> void:
    if held_sand == 0:
        # Step 1: Get sand
        if not target_node or not target_node.is_in_group("resources"):
            var piles = get_tree().get_nodes_in_group("resources")
            if piles.size() > 0:
                target_node = piles[0] as Node3D
            else:
                current_job = Job.IDLE
                return

        if is_working:
            work_timer -= delta
            if work_timer <= 0:
                if target_node.has_method("collect"):
                    held_sand = target_node.collect(10)
                else:
                    held_sand = 10
                is_wet = false
                is_working = false
                target_node = null
                anim_player.speed_scale = 1.0
        else:
            _move_to_target(target_node, delta, 12.0)
            if global_position.distance_to(target_node.global_position) <= 12.5:
                is_working = true
                work_timer = 2.0
                anim_player.speed_scale = 2.0
                velocity = Vector3.ZERO
                
    elif not is_wet:
        # Step 2: Get it wet at the fountain
        if not target_node or not target_node.is_in_group("fountain"):
            var fountains = get_tree().get_nodes_in_group("fountain")
            if fountains.size() > 0:
                target_node = fountains[0] as Node3D
            else:
                current_job = Job.IDLE
                return
            
        if is_working:
            work_timer -= delta
            if work_timer <= 0:
                is_wet = true
                is_working = false
                target_node = null
                anim_player.speed_scale = 1.0
                model.scale = Vector3(1.2, 1.2, 1.2)
        else:
            _move_to_target(target_node, delta, 15.0)
            if global_position.distance_to(target_node.global_position) <= 15.5:
                is_working = true
                work_timer = 1.0
                anim_player.speed_scale = 4.0
                velocity = Vector3.ZERO
                
    else:
        # Step 3: Deliver to expansion site
        if not target_node or not target_node.is_in_group("expansion_site"):
            var sites = get_tree().get_nodes_in_group("expansion_site")
            if sites.size() > 0:
                target_node = sites[0] as Node3D
            else:
                current_job = Job.IDLE
                return
            
        if is_working:
            work_timer -= delta
            if work_timer <= 0:
                if target_node.has_method("deposit"):
                    target_node.deposit(held_sand)
                held_sand = 0
                is_wet = false
                is_working = false
                target_node = null
                anim_player.speed_scale = 1.0
                model.scale = Vector3(1, 1, 1)
        else:
            # Expansion site is at center of NEW tile (40 units away)
            # We stop at distance 25 so we stay on the current island (ends at 20)
            _move_to_target(target_node, delta, 25.0)
            if global_position.distance_to(target_node.global_position) <= 25.5:
                is_working = true
                work_timer = 1.5
                anim_player.speed_scale = 2.0
                velocity = Vector3.ZERO

func _move_to_target(node: Node3D, _delta: float, stop_dist: float = 6.0) -> void:
    var dist: float = global_position.distance_to(node.global_position)
    if dist > stop_dist:
        var dir: Vector3 = (node.global_position - global_position).normalized()
        dir.y = 0
        velocity = dir * 12.0
        move_and_slide()
        
        var look_pos: Vector3 = node.global_position
        look_pos.y = global_position.y
        if global_position.distance_to(look_pos) > 0.1:
            look_at(look_pos, Vector3.UP)
    else:
        velocity = Vector3.ZERO

func set_job(new_job_int: int) -> void:
    # Handle both old 1/2 IDs and new enum IDs
    if new_job_int == 0:
        current_job = Job.IDLE
    else:
        current_job = Job.EXPAND
        
    is_working = false
    target_node = null
    anim_player.speed_scale = 1.0
    held_sand = 0
    is_wet = false
    model.scale = Vector3(1, 1, 1)
    if current_job == Job.IDLE:
        var offset: Vector3 = global_position - orbit_center
        current_angle = atan2(offset.x, offset.z)

func _on_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        get_tree().call_group("ui", "show_job_menu", self)
