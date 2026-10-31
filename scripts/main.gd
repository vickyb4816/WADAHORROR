extends Node3D

const PlayerScript = preload("res://scripts/player.gd")

# Blockout dimensions are deliberately modest for the project's older target PC
# and Android Compatibility renderer. Coordinates are metres.
const WALL := Color(0.63, 0.55, 0.42)
const WALL_DARK := Color(0.35, 0.27, 0.19)
const WOOD := Color(0.24, 0.12, 0.065)
const STONE := Color(0.31, 0.30, 0.26)
const FLOOR := Color(0.34, 0.28, 0.21)
const COURTYARD := Color(0.25, 0.29, 0.22)
const ROOF := Color(0.22, 0.13, 0.09)

var materials: Dictionary = {}

func _ready() -> void:
    _make_environment()
    _make_site()
    _make_ground_floor()
    _make_upper_floor()
    _make_staircase()
    _make_roof_silhouette()
    _make_entrance_key()
    _make_player()
    _make_tatya()
    _start_horror_ambience()
    print("Wada Horror test slice loaded: Laksha, entrance key, two-floor Wada, Tatya and horror ambience.")

func _make_environment() -> void:
    var world := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_SKY
    env.sky = Sky.new()
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.39, 0.40, 0.42)
    env.ambient_light_energy = 0.62
    env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    world.environment = env
    add_child(world)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48, -28, 0)
    sun.light_energy = 0.72
    sun.shadow_enabled = true
    add_child(sun)

func _make_site() -> void:
    _add_box("OuterYard", Vector3(0, -0.35, 3), Vector3(64, 0.7, 64), Color(0.19, 0.21, 0.15))
    _add_box("FrontApproachPath", Vector3(0, 0.015, 19), Vector3(5, 0.08, 18), STONE)
    # Low compound wall and gate posts frame the Wada entrance.
    _add_box("CompoundLeft", Vector3(-17, 1.0, 10), Vector3(0.45, 2.0, 22), WALL_DARK)
    _add_box("CompoundRight", Vector3(17, 1.0, 10), Vector3(0.45, 2.0, 22), WALL_DARK)
    _add_box("GatePostLeft", Vector3(-3.8, 1.5, 21), Vector3(0.7, 3.0, 0.7), WOOD)
    _add_box("GatePostRight", Vector3(3.8, 1.5, 21), Vector3(0.7, 3.0, 0.7), WOOD)
    _add_box("GateLintel", Vector3(0, 3.0, 21), Vector3(8.3, 0.45, 0.7), WOOD)
    # Dry well as a landmark. Its collision rim prevents falling inside.
    _add_cylinder("OldWell", Vector3(-12, 0.55, 8), 1.5, 1.1, STONE)
    _add_cylinder("WellOpening", Vector3(-12, 1.13, 8), 1.05, 0.08, Color(0.06, 0.07, 0.06))

func _make_ground_floor() -> void:
    # Ground floor and open central courtyard.
    _add_box("GroundFloor", Vector3(0, -0.12, 0), Vector3(24, 0.24, 20), FLOOR)
    _add_box("CourtyardStone", Vector3(0, 0.015, 0), Vector3(8, 0.08, 7), COURTYARD)

    # Outer walls: south side is split to leave the main entrance opening.
    _add_box("NorthOuterWall", Vector3(0, 2.1, -10), Vector3(24, 4.2, 0.45), WALL)
    _add_box("WestOuterWall", Vector3(-12, 2.1, 0), Vector3(0.45, 4.2, 20), WALL)
    _add_box("EastOuterWall", Vector3(12, 2.1, 0), Vector3(0.45, 4.2, 20), WALL)
    _add_box("SouthOuterLeft", Vector3(-7.15, 2.1, 10), Vector3(9.7, 4.2, 0.45), WALL)
    _add_box("SouthOuterRight", Vector3(7.15, 2.1, 10), Vector3(9.7, 4.2, 0.45), WALL)
    _add_box("SouthEntranceHeader", Vector3(0, 3.95, 10), Vector3(4.6, 0.5, 0.45), WALL_DARK)

    # Ground-floor partitions. Openings are intentionally left between room zones.
    _add_box("WestRoomDividerA", Vector3(-8.0, 1.7, -5.2), Vector3(7.5, 3.4, 0.25), WALL_DARK)
    _add_box("WestRoomDividerB", Vector3(-8.0, 1.7, 0.0), Vector3(7.5, 3.4, 0.25), WALL_DARK)
    _add_box("WestRoomDividerC", Vector3(-8.0, 1.7, 5.0), Vector3(7.5, 3.4, 0.25), WALL_DARK)
    _add_box("EastRoomDividerA", Vector3(8.0, 1.7, -5.2), Vector3(7.5, 3.4, 0.25), WALL_DARK)
    _add_box("EastRoomDividerB", Vector3(8.0, 1.7, 0.0), Vector3(7.5, 3.4, 0.25), WALL_DARK)
    _add_box("EastRoomDividerC", Vector3(8.0, 1.7, 5.0), Vector3(7.5, 3.4, 0.25), WALL_DARK)
    _add_box("NorthRoomDividerA", Vector3(-4.0, 1.7, -7.0), Vector3(0.25, 3.4, 5.5), WALL_DARK)
    _add_box("NorthRoomDividerB", Vector3(4.0, 1.7, -7.0), Vector3(0.25, 3.4, 5.5), WALL_DARK)
    _add_box("SouthRoomDividerA", Vector3(-4.0, 1.7, 7.0), Vector3(0.25, 3.4, 5.5), WALL_DARK)
    _add_box("SouthRoomDividerB", Vector3(4.0, 1.7, 7.0), Vector3(0.25, 3.4, 5.5), WALL_DARK)

    _make_door()
    _make_courtyard_pillars()
    _make_room_signs(0.35)

func _make_upper_floor() -> void:
    # Upper gallery surrounds the open-to-sky courtyard. The courtyard itself
    # stays empty so both levels overlook the same central space.
    var upper_y := 4.15
    _add_box("UpperNorthGallery", Vector3(0, upper_y, -8.35), Vector3(24, 0.3, 3.3), FLOOR)
    _add_box("UpperSouthGallery", Vector3(0, upper_y, 8.35), Vector3(24, 0.3, 3.3), FLOOR)
    _add_box("UpperWestGallery", Vector3(-10.35, upper_y, 0), Vector3(3.3, 0.3, 13.4), FLOOR)
    _add_box("UpperEastGallery", Vector3(10.35, upper_y, 0), Vector3(3.3, 0.3, 13.4), FLOOR)

    var upper_wall_y := 6.2
    _add_box("UpperNorthWall", Vector3(0, upper_wall_y, -10), Vector3(24, 4.1, 0.4), WALL)
    _add_box("UpperWestWall", Vector3(-12, upper_wall_y, 0), Vector3(0.4, 4.1, 20), WALL)
    _add_box("UpperEastWall", Vector3(12, upper_wall_y, 0), Vector3(0.4, 4.1, 20), WALL)
    _add_box("UpperSouthWallLeft", Vector3(-7.15, upper_wall_y, 10), Vector3(9.7, 4.1, 0.4), WALL)
    _add_box("UpperSouthWallRight", Vector3(7.15, upper_wall_y, 10), Vector3(9.7, 4.1, 0.4), WALL)

    # Upper-level room divisions create another six room zones.
    _add_box("UpperWestDividerA", Vector3(-8.0, 5.9, -5.2), Vector3(7.5, 3.4, 0.22), WALL_DARK)
    _add_box("UpperWestDividerB", Vector3(-8.0, 5.9, 0.0), Vector3(7.5, 3.4, 0.22), WALL_DARK)
    _add_box("UpperEastDividerA", Vector3(8.0, 5.9, -5.2), Vector3(7.5, 3.4, 0.22), WALL_DARK)
    _add_box("UpperEastDividerB", Vector3(8.0, 5.9, 0.0), Vector3(7.5, 3.4, 0.22), WALL_DARK)
    _add_box("UpperNorthDividerA", Vector3(-4.0, 5.9, -7.0), Vector3(0.22, 3.4, 5.5), WALL_DARK)
    _add_box("UpperNorthDividerB", Vector3(4.0, 5.9, -7.0), Vector3(0.22, 3.4, 5.5), WALL_DARK)
    _add_box("UpperSouthDividerA", Vector3(-4.0, 5.9, 7.0), Vector3(0.22, 3.4, 5.5), WALL_DARK)
    _add_box("UpperSouthDividerB", Vector3(4.0, 5.9, 7.0), Vector3(0.22, 3.4, 5.5), WALL_DARK)

    # Wooden gallery railings around the courtyard opening.
    _add_box("GalleryRailNorth", Vector3(0, 5.15, -4.0), Vector3(8.0, 0.9, 0.16), WOOD)
    _add_box("GalleryRailSouth", Vector3(0, 5.15, 4.0), Vector3(8.0, 0.9, 0.16), WOOD)
    _add_box("GalleryRailWest", Vector3(-4.0, 5.15, 0), Vector3(0.16, 0.9, 7.0), WOOD)
    _add_box("GalleryRailEast", Vector3(4.0, 5.15, 0), Vector3(0.16, 0.9, 7.0), WOOD)
    _make_room_signs(4.5)

func _make_staircase() -> void:
    # Simple solid steps on the east side. Laksha can walk up to the gallery.
    var step_count := 15
    for i in range(step_count):
        var step_height := 0.28
        var step_depth := 0.42
        var step_y := step_height * float(i + 1) * 0.5
        var step_z := 8.0 - float(i) * step_depth
        _add_box("StairStep_%02d" % i, Vector3(9.2, step_y, step_z), Vector3(2.2, step_height * float(i + 1), step_depth), WOOD)
    _add_box("StairLanding", Vector3(9.2, 4.12, 1.25), Vector3(2.5, 0.25, 1.2), WOOD)
    # Handrail posts and top rail.
    for i in range(0, 8):
        var z := 7.7 - float(i) * 0.78
        var y := 0.7 + float(i) * 0.42
        _add_box("StairPost_%02d" % i, Vector3(10.55, y, z), Vector3(0.12, 0.85, 0.12), WOOD)
    _add_box("StairHandrail", Vector3(10.55, 2.35, 4.8), Vector3(0.14, 0.14, 6.3), WOOD)

func _make_roof_silhouette() -> void:
    # Roof slabs are visual-only and deliberately kept above the playable gallery.
    var left_roof := _add_visual_box("RoofSlopeLeft", Vector3(-6.0, 8.55, 0), Vector3(13.0, 0.35, 22.0), ROOF)
    left_roof.rotation.z = deg_to_rad(-25)
    var right_roof := _add_visual_box("RoofSlopeRight", Vector3(6.0, 8.55, 0), Vector3(13.0, 0.35, 22.0), ROOF)
    right_roof.rotation.z = deg_to_rad(25)
    _add_box("FrontRoofEave", Vector3(0, 7.0, 10.2), Vector3(24.5, 0.45, 0.8), WOOD)

func _make_courtyard_pillars() -> void:
    for x in [-4.8, 4.8]:
        for z in [-4.7, 4.7]:
            _add_box("CourtyardPillar_%s_%s" % [str(x), str(z)], Vector3(x, 2.0, z), Vector3(0.42, 4.0, 0.42), WOOD)
            _add_box("UpperPillar_%s_%s" % [str(x), str(z)], Vector3(x, 6.15, z), Vector3(0.42, 4.0, 0.42), WOOD)

func _make_room_signs(level_y: float) -> void:
    var labels := [
        ["PUJA ROOM", Vector3(-8.0, level_y, -8.0)],
        ["STORAGE", Vector3(8.0, level_y, -8.0)],
        ["LIBRARY", Vector3(-8.0, level_y, -2.6)],
        ["GUEST ROOM", Vector3(8.0, level_y, -2.6)],
        ["KITCHEN", Vector3(-8.0, level_y, 2.5)],
        ["DINING", Vector3(8.0, level_y, 2.5)],
        ["BEDROOM", Vector3(-8.0, level_y, 7.6)],
        ["STUDY", Vector3(8.0, level_y, 7.6)]
    ]
    for entry in labels:
        var sign := Label3D.new()
        sign.text = entry[0]
        sign.position = entry[1]
        sign.font_size = 32
        sign.pixel_size = 0.006
        sign.modulate = Color(0.95, 0.82, 0.56)
        add_child(sign)

func _make_door() -> void:
    var hinge := Node3D.new()
    hinge.name = "EntranceDoorHinge"
    hinge.position = Vector3(-1.25, 0, 10.0)
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
    mesh.material_override = _material(WOOD)
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
    key.position = Vector3(2.2, 0.55, 13.0)
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
    player.position = Vector3(0, 1.1, 18)
    player.set_script(PlayerScript)
    add_child(player)

    var collision := CollisionShape3D.new()
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.35
    capsule.height = 1.8
    collision.shape = capsule
    player.add_child(collision)

func _add_box(node_name: String, pos: Vector3, dimensions: Vector3, color: Color) -> StaticBody3D:
    var body := StaticBody3D.new()
    body.name = node_name
    body.position = pos
    add_child(body)
    var mesh_instance := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = dimensions
    mesh_instance.mesh = box
    mesh_instance.material_override = _material(color)
    body.add_child(mesh_instance)
    var shape_node := CollisionShape3D.new()
    var box_shape := BoxShape3D.new()
    box_shape.size = dimensions
    shape_node.shape = box_shape
    body.add_child(shape_node)
    return body

func _add_visual_box(node_name: String, pos: Vector3, dimensions: Vector3, color: Color) -> MeshInstance3D:
    var mesh_instance := MeshInstance3D.new()
    mesh_instance.name = node_name
    mesh_instance.position = pos
    var box := BoxMesh.new()
    box.size = dimensions
    mesh_instance.mesh = box
    mesh_instance.material_override = _material(color)
    add_child(mesh_instance)
    return mesh_instance

func _add_cylinder(node_name: String, pos: Vector3, radius: float, height: float, color: Color) -> void:
    var body := StaticBody3D.new()
    body.name = node_name
    body.position = pos
    add_child(body)
    var mesh_instance := MeshInstance3D.new()
    var cylinder := CylinderMesh.new()
    cylinder.top_radius = radius
    cylinder.bottom_radius = radius
    cylinder.height = height
    mesh_instance.mesh = cylinder
    mesh_instance.material_override = _material(color)
    body.add_child(mesh_instance)
    var collision := CollisionShape3D.new()
    var shape := CylinderShape3D.new()
    shape.radius = radius
    shape.height = height
    collision.shape = shape
    body.add_child(collision)


func _make_tatya() -> void:
    var tatya := CharacterBody3D.new()
    tatya.name = "TatyaVinchu"
    tatya.position = Vector3(0, 0.12, -1.8)
    tatya.set_script(load("res://scripts/tatya_hunter.gd"))
    add_child(tatya)

    var body_mesh := MeshInstance3D.new()
    var robe := CylinderMesh.new()
    robe.top_radius = 0.34
    robe.bottom_radius = 0.72
    robe.height = 1.75
    body_mesh.mesh = robe
    body_mesh.position.y = 1.02
    body_mesh.material_override = _material(Color(0.055, 0.035, 0.045))
    tatya.add_child(body_mesh)

    var head := MeshInstance3D.new()
    var head_shape := SphereMesh.new()
    head_shape.radius = 0.48
    head_shape.height = 0.9
    head.mesh = head_shape
    head.position = Vector3(0, 2.05, -0.02)
    head.material_override = _material(Color(0.42, 0.31, 0.25))
    tatya.add_child(head)

    for side in [-1.0, 1.0]:
        var eye := MeshInstance3D.new()
        var eye_shape := SphereMesh.new()
        eye_shape.radius = 0.075
        eye_shape.height = 0.12
        eye.mesh = eye_shape
        eye.position = Vector3(side * 0.18, 2.12, -0.43)
        eye.material_override = _material(Color(0.95, 0.025, 0.015), true)
        tatya.add_child(eye)

        var arm := MeshInstance3D.new()
        var arm_shape := CylinderMesh.new()
        arm_shape.top_radius = 0.10
        arm_shape.bottom_radius = 0.14
        arm_shape.height = 1.05
        arm.mesh = arm_shape
        arm.position = Vector3(side * 0.52, 1.15, 0)
        arm.rotation.z = deg_to_rad(side * -18.0)
        arm.material_override = _material(Color(0.12, 0.07, 0.065))
        tatya.add_child(arm)

    var red_glow := OmniLight3D.new()
    red_glow.position = Vector3(0, 2.05, -0.65)
    red_glow.light_color = Color(1.0, 0.025, 0.01)
    red_glow.light_energy = 0.8
    red_glow.omni_range = 3.5
    tatya.add_child(red_glow)

    var collision := CollisionShape3D.new()
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.48
    capsule.height = 2.5
    collision.shape = capsule
    collision.position.y = 1.22
    tatya.add_child(collision)

    var patrol_nodes: Array[Node3D] = []
    for i in range(4):
        var point := Node3D.new()
        point.name = "TatyaPatrolPoint_%d" % i
        point.position = [Vector3(0, 0, -2), Vector3(5.5, 0, -2), Vector3(5.5, 0, 2), Vector3(-5.5, 0, 2)][i]
        add_child(point)
        patrol_nodes.append(point)
    tatya.set("patrol_points", patrol_nodes)
    tatya.call("set_player", get_node("Laksha"))

func _start_horror_ambience() -> void:
    var ambience := Node.new()
    ambience.name = "HorrorAmbience"
    ambience.set_script(load("res://scripts/horror_ambience.gd"))
    add_child(ambience)

func _material(color: Color, metallic: bool = false) -> StandardMaterial3D:
    var key := color.to_html() + str(metallic)
    if materials.has(key):
        return materials[key]
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.metallic = 0.65 if metallic else 0.0
    mat.roughness = 0.35 if metallic else 0.9
    materials[key] = mat
    return mat
