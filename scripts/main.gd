extends Node3D

const PlayerScript = preload("res://scripts/player.gd")

func _ready() -> void:
    _make_environment()
    _make_ground()
    _make_wada()
    _make_entrance_key()
    _make_player()

func _make_environment() -> void:
    var world := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_SKY
    env.sky = Sky.new()
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.34, 0.36, 0.40)
    env.ambient_light_energy = 0.55
    world.environment = env
    add_child(world)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48, -28, 0)
    sun.light_energy = 0.75
    add_child(sun)

func _make_ground() -> void:
    _add_box("YardGround", Vector3(0, -0.25, 2), Vector3(50, 0.5, 50), Color(0.20, 0.23, 0.16), true)

func _make_wada() -> void:
    # Simple blockout building: exterior walls and an open doorway.
    var wall_color := Color(0.30, 0.25, 0.20)
    _add_box("BackWall", Vector3(0, 2, 5), Vector3(12, 4, 0.4), wall_color, true)
    _add_box("LeftWall", Vector3(-6, 2, 0), Vector3(0.4, 4, 10), wall_color, true)
    _add_box("RightWall", Vector3(6, 2, 0), Vector3(0.4, 4, 10), wall_color, true)
    _add_box("FrontLeftWall", Vector3(-4.25, 2, -5), Vector3(3.5, 4, 0.4), wall_color, true)
    _add_box("FrontRightWall", Vector3(4.25, 2, -5), Vector3(3.5, 4, 0.4), wall_color, true)
    _add_box("FrontHeader", Vector3(0, 3.65, -5), Vector3(5, 0.7, 0.4), wall_color, true)
    _add_box("InteriorFloor", Vector3(0, 0.02, 0), Vector3(11.6, 0.15, 9.6), Color(0.25, 0.22, 0.18), true)
    _add_box("Roof", Vector3(0, 4.15, 0), Vector3(12.4, 0.3, 10.4), Color(0.16, 0.14, 0.12), true)
    _make_door()

    # A few simple pillars to establish the old wada courtyard.
    for x in [-5.5, 5.5]:
        _add_box("VerandahPillar", Vector3(x, 1.7, -5.8), Vector3(0.35, 3.4, 0.35), Color(0.42, 0.34, 0.25), true)

func _make_door() -> void:
    var hinge := Node3D.new()
    hinge.name = "EntranceDoorHinge"
    hinge.position = Vector3(-1.25, 0, -5.0)
    add_child(hinge)

    var door := StaticBody3D.new()
    door.name = "EntranceDoor"
    door.add_to_group("interactable")
    hinge.add_child(door)
    door.position = Vector3(1.25, 1.45, 0)
    var mesh := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = Vector3(2.5, 2.9, 0.18)
    mesh.mesh = box
    mesh.material_override = _material(Color(0.20, 0.10, 0.055))
    door.add_child(mesh)
    var shape := CollisionShape3D.new()
    var box_shape := BoxShape3D.new()
    box_shape.size = Vector3(2.5, 2.9, 0.18)
    shape.shape = box_shape
    door.add_child(shape)
    door.set_meta("hinge", hinge)
    door.set_meta("opened", false)
    door.set_script(load("res://scripts/door.gd"))

func _make_entrance_key() -> void:
    var key := Area3D.new()
    key.name = "EntranceKey"
    key.position = Vector3(2.2, 0.55, 1.2)
    key.add_to_group("interactable")
    key.set_script(load("res://scripts/key.gd"))
    add_child(key)

    var mesh := MeshInstance3D.new()
    var sphere := SphereMesh.new()
    sphere.radius = 0.18
    sphere.height = 0.36
    mesh.mesh = sphere
    mesh.material_override = _material(Color(0.95, 0.68, 0.12), true)
    key.add_child(mesh)

    var collision := CollisionShape3D.new()
    var shape := SphereShape3D.new()
    shape.radius = 0.5
    collision.shape = shape
    key.add_child(collision)

func _make_player() -> void:
    var player := CharacterBody3D.new()
    player.name = "Laksha"
    player.position = Vector3(0, 1.1, 10)
    player.set_script(PlayerScript)
    add_child(player)

    var collision := CollisionShape3D.new()
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.35
    capsule.height = 1.8
    collision.shape = capsule
    player.add_child(collision)

func _add_box(node_name: String, pos: Vector3, dimensions: Vector3, color: Color, collision: bool) -> void:
    var body := StaticBody3D.new() if collision else Node3D.new()
    body.name = node_name
    body.position = pos
    add_child(body)

    var mesh_instance := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = dimensions
    mesh_instance.mesh = box
    mesh_instance.material_override = _material(color)
    body.add_child(mesh_instance)

    if collision:
        var shape_node := CollisionShape3D.new()
        var box_shape := BoxShape3D.new()
        box_shape.size = dimensions
        shape_node.shape = box_shape
        body.add_child(shape_node)

func _material(color: Color, metallic: bool = false) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.metallic = 0.65 if metallic else 0.0
    mat.roughness = 0.35 if metallic else 0.9
    return mat
