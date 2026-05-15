extends StaticBody3D

@export var expansion_id: String = "east"
@export var spawn_offset: Vector3 = Vector3(40, 0, 0)
@export var cost: float = 100.0

var progress: float = 0.0

@onready var ghost_mesh: MeshInstance3D = $GhostMesh
@onready var progress_bar: Sprite3D = $ProgressBar

func _ready() -> void:
    add_to_group("expansion_site")
    cost = GameState.expansion_cost
    # Make material unique
    var mat = ghost_mesh.get_active_material(0).duplicate()
    ghost_mesh.set_surface_override_material(0, mat)
    _update_visuals()

func deposit(amount: float) -> void:
    progress += amount
    GameState.expansion_progress = progress
    _update_visuals()
    
    if progress >= cost:
        _complete_expansion()

func _update_visuals() -> void:
    var mat = ghost_mesh.get_surface_override_material(0)
    if mat:
        mat.albedo_color.a = lerp(0.1, 0.4, progress / cost)

func _complete_expansion() -> void:
    # Spawn a new permanent island part
    var new_island = MeshInstance3D.new()
    new_island.mesh = BoxMesh.new()
    new_island.mesh.size = Vector3(40, 2, 40)
    
    # Match material from Main island
    var island_node = get_tree().root.find_child("Island", true, false)
    if island_node:
        new_island.mesh.material = island_node.mesh.material
    
    get_parent().add_child(new_island)
    new_island.global_position = global_position
    new_island.global_position.y = -1 # Match island height offset
    
    # Move this site further out or delete it
    # For now, let's just move it to the next spot
    global_position += spawn_offset
    progress = 0
    _update_visuals()
    
    # Reset global progress if using a single site
    GameState.expansion_progress = 0
