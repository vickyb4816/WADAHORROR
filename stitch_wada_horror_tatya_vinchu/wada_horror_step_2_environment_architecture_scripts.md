# PROJECT: WADA HORROR – TATYA VINCHU
## TECHNICAL DESIGN & IMPLEMENTATION MANUAL: STEP 2 (WADA ENVIRONMENT BLOCKOUT)
**Engine**: Godot 4.2+ / 4.3 (Standard 64-bit)  
**Renderer Target**: `gl_compatibility` (Targeting i3-4150 + GT 730 @ 720p 30 FPS)  
**Target Hardware Constraints**: Max 50,000 tris on screen at once, Baked/Unshaded lightmaps or minimal omni lights (max 2-3 active shadow casters per room), zero real-time volumetric fog.

---

### TABLE OF CONTENTS
1. [Step 2 Architecture Overview & Reference Mapping](#1-architecture-overview)
2. [Folder Structure & Scene Organization](#2-folder-structure)
3. [Godot GridMap & CSG Blockout Dimensions (Metric Standard)](#3-gridmap--dimensions)
4. [Step-by-Step Godot Scene Tree: `WadaLevel.tscn`](#4-scene-tree-assembly)
5. [Complete Blockout Script Implementations](#5-complete-scripts)
   - `WadaRoom.gd` (Area3D Room Detection & Occlusion/Map trigger)
   - `DoorController.gd` (Integrated Key & Interaction Handler)
   - `WorldEnvironmentConfig.gd` (Low-spec GT 730 Horror Atmosphere & Lighting setup)
6. [Step-by-Step Godot Editor Guide for Beginners](#6-beginner-editor-guide)
7. [Collision & Stuck-Prevention Checklist](#7-collision-checklist)

---

### 1. ARCHITECTURE OVERVIEW & REFERENCE MAPPING

Referencing your uploaded blueprints (**Horror Indian Wada Blueprint Board** & **Tatya Vinchu Reference Sheet**):

```
+-----------------------------------------------------------------------------------+
|                                 BACKYARD / ANCIENT WELL                           |
+-----------------------------------------------------------------------------------+
|  Puja Room   |  Bedroom 1   | Store Room |  Bedroom 2   | Study/Library | Kitchen |
+--------------+--------------+------------+--------------+---------------+---------+
|     Hall / Drawing Room     |                  Dining Room                        |
+-----------------------------+    CENTRAL COURTYARD      +-------------------------+
|  Guest Room  |  Inner Room  |    (Open to Sky / Tulsi)  |   Storage     | Servant |
+--------------+--------------+---------------------------+---------------+---------+
|                  MAIN VERANDAH (Wooden Pillars, Stone Foundation)                 |
+-----------------------------------------------------------------------------------+
|             EXTERIOR COMPOUND / GARDEN (Start Area, Golden Key Location)          |
+-----------------------------------------------------------------------------------+
```

#### Vertical Layout:
- **Ground Floor (Y = 0.0m)**: Verandah, Central Courtyard with Tulsi Vrindavan, Hall, Kitchen, Dining, Servant Room, Store Room, Guest Room, Puja Room.
- **Staircase (Central / Corridor)**: Leads from Ground Verandah/Courtyard corridor to First Floor corridor at Y = 3.6m.
- **First Floor (Y = 3.6m)**: Corridors with wooden railings overlooking the Central Courtyard, Master Bedrooms, Storage Lofts, and Outside Balcony.
- **Rooftop & Terrace (Y = 7.2m)**: Flat accessible terrace area, connected to low-angle walkable sloping terracotta tile roofs (15–20° pitch) with low parapet borders to prevent Laksha or Tatya falling out of bounds.

---

### 2. FOLDER STRUCTURE

Organize your Godot project filesystem exactly as shown below:

```text
res://
├── scenes/
│   ├── player/
│   │   └── Player.tscn                 (Your working Step 1 Player)
│   ├── environment/
│   │   ├── WadaLevel.tscn              (Main Stage Master Scene)
│   │   ├── WadaExterior.tscn           (Boundary wall, garden, well, gate)
│   │   ├── WadaCourtyard.tscn          (Central open-sky courtyard & Tulsi)
│   │   ├── WadaGroundFloor.tscn        (12 primary rooms blockout)
│   │   ├── WadaFirstFloor.tscn         (Upper rooms, gallery & balcony)
│   │   └── WadaRoofTerrace.tscn        (Flat terrace & walkable slope)
│   ├── interactables/
│   │   ├── Door.tscn                   (Reusable hinged door + lock)
│   │   └── GoldenKey.tscn              (Step 1 key object)
├── scripts/
│   ├── environment/
│   │   ├── WadaRoom.gd                 (Room tracker for map/sound)
│   │   └── WorldEnvironmentConfig.gd   (GT 730 lighting configuration)
│   └── interactables/
│       └── DoorController.gd           (Locked/unlocked door logic)
└── materials/
    ├── mat_stone_foundation.tres       (Simple palette material)
    ├── mat_cream_wall.tres
    ├── mat_wood_pillar.tres
    └── mat_terracotta_roof.tres
```

---

### 3. METRIC STANDARDS & BLOCKOUT DIMENSIONS

To ensure Laksha (Height: 1.8m, Radius: 0.4m) moves smoothly without clipping:

| Component | Width (X) | Depth (Z) | Height (Y) | Notes |
| :--- | :--- | :--- | :--- | :--- |
| **Doorways** | 1.2 m | 0.2 m | 2.4 m | Ample clearance for player collision capsule |
| **Interior Corridors** | 2.4 m | Variable | 3.2 m | Allows 2-way clearance if Tatya encounters Laksha |
| **Floor-to-Ceiling** | Variable | Variable | 3.5 m | High Maharashtrian Wada ceiling aesthetic |
| **Staircase Step** | 1.4 m wide | 0.28 m tread | 0.18 m riser | Smooth stepping (use invisible collision ramp!) |
| **Balcony Railing** | Variable | 0.15 m | 1.1 m | Player camera eye level is 1.6m; railing prevents falling |
| **Roof Slope Pitch** | Variable | Variable | Max 20° | Godot `floor_max_angle` set to 45° |

> **PRO-TIP FOR LOW-END GT 730**: Use Godot's **CSGBox3D** for the initial whitebox blockout. When you are done blocking out, check **`Use Collision = true`** on each CSG parent, or convert to a static `MeshInstance3D` with trimesh collision. For stairs, **never use step-by-step collision boxes**—place an invisible angled box ramp over the steps with `CollisionShape3D` so the character controller does not stutter or get stuck on step edges!

---

### 4. SCENE TREE ASSEMBLY (`WadaLevel.tscn`)

Assemble the master scene in the inspector:

```text
WadaLevel (Node3D) [Script: WorldEnvironmentConfig.gd]
├── WorldEnvironment (WorldEnvironment)
├── DirectionalLight3D (Moonlight - Low energy, deep dark navy blue)
├── WadaNavigationRegion3D (NavigationRegion3D - Prepares Tatya AI mesh later)
│   ├── ExteriorGround (StaticBody3D)
│   │   ├── MeshInstance3D (Ground plane 60m x 60m)
│   │   └── CollisionShape3D (BoxShape3D)
│   ├── WadaStructure (Node3D)
│   │   ├── GroundFloor (Node3D)
│   │   │   ├── Verandah (StaticBody3D)
│   │   │   ├── Courtyard (StaticBody3D)
│   │   │   ├── Rooms (Node3D)
│   │   │   │   ├── Room_Puja (Area3D) [WadaRoom.gd]
│   │   │   │   ├── Room_Bedroom1 (Area3D) [WadaRoom.gd]
│   │   │   │   ├── Room_Kitchen (Area3D) [WadaRoom.gd]
│   │   │   │   └── ... (Other rooms as defined in map)
│   │   │   └── Doors (Node3D)
│   │   │       ├── MainEntranceDoor (Node3D) [Door.tscn]
│   │   │       └── InteriorDoors ...
│   │   ├── Staircase (StaticBody3D)
│   │   │   ├── VisualSteps (CSGCombiner3D or Mesh)
│   │   │   └── SmoothCollisionRamp (CollisionShape3D - Angled box)
│   │   ├── FirstFloor (Node3D)
│   │   │   ├── BalconyOverhang (StaticBody3D)
│   │   │   └── UpperRooms (Node3D)
│   │   └── RoofAndTerrace (StaticBody3D)
│   │       ├── FlatTerrace (CollisionShape3D)
│   │       └── WalkableRoofs (CollisionShape3D)
├── SpawnPoints (Node3D)
│   └── PlayerStartPoint (Marker3D - Positioned outside garden gate)
└── Player (Instance of res://scenes/player/Player.tscn)
```

---

### 5. COMPLETE SCRIPTS

#### SCRIPT 1: `WadaRoom.gd`
*Attach this script to an `Area3D` spanning the interior bounds of each room. It tracks which room Laksha is in, prepares the progressive map reveal system for Step 5, and controls room audio zones.*

```gdscript
# File: res://scripts/environment/WadaRoom.gd
class_name WadaRoom
extends Area3D

@export var room_id: String = "room_unnamed"
@export var room_display_name: String = "Unknown Room"
@export var floor_level: int = 0 # 0 = Ground, 1 = First Floor, 2 = Terrace/Roof
@export var is_discovered: bool = false

signal room_entered(room_info: WadaRoom)
signal room_exited(room_info: WadaRoom)

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2 # Ensure your Player is on Layer 2 (or match player collision layer)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		if not is_discovered:
			is_discovered = true
			print("[WADA MAP] Newly Discovered: ", room_display_name)
		emit_signal("room_entered", self)

func _on_body_exited(body: Node3D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		emit_signal("room_exited", self)
```

---

#### SCRIPT 2: `DoorController.gd`
*Attach this script to your `Door.tscn`. It integrates seamlessly with your working Step 1 key collection and `ray.collide_with_areas = true` interaction code.*

```gdscript
# File: res://scripts/interactables/DoorController.gd
class_name DoorController
extends Node3D

@export var is_locked: bool = true
@export var required_key_id: String = "golden_entrance_key"
@export var door_name: String = "Main Entrance Door"
@export var open_angle: float = 95.0
@export var swing_speed: float = 3.5

@onready var hinge_pivot: Node3D = $HingePivot
@onready var interact_area: Area3D = $InteractArea
@onready var prompt_label_3d: Label3D = $PromptLabel3D

var is_open: bool = false
var target_rotation_y: float = 0.0

func _ready() -> void:
	# Set interactable layer so player raycast with collide_with_areas = true hits it
	interact_area.collision_layer = 4 # Interaction layer
	interact_area.collision_mask = 0
	if prompt_label_3d:
		prompt_label_3d.visible = false
		prompt_label_3d.text = "[E] Unlock " + door_name if is_locked else "[E] Open Door"

func _process(delta: float) -> void:
	# Smoothly rotate the door around the hinge
	hinge_pivot.rotation.y = lerp_angle(hinge_pivot.rotation.y, target_rotation_y, delta * swing_speed)

# Called when Player's interaction ray hits this object
func interact(player: Node3D) -> void:
	if is_locked:
		# Check if the player possesses the required key in their inventory
		if player.has_method("has_key") and player.has_key(required_key_id):
			is_locked = false
			print("[DOOR] Unlocked: ", door_name)
			toggle_door()
		else:
			print("[DOOR] Locked! Requires: ", required_key_id)
			show_temporary_prompt("Locked. Key required.")
	else:
		toggle_door()

func toggle_door() -> void:
	is_open = !is_open
	target_rotation_y = deg_to_rad(open_angle) if is_open else 0.0

func show_temporary_prompt(message: String) -> void:
	if prompt_label_3d:
		prompt_label_3d.text = message
		prompt_label_3d.visible = true
		await get_tree().create_timer(2.0).timeout
		prompt_label_3d.visible = false
```

---

#### SCRIPT 3: `WorldEnvironmentConfig.gd`
*Specifically tuned for GeForce GT 730 + i3-4150 on Godot 4 Compatibility Renderer. Balances spooky Maharashtrian Wada atmosphere with solid 30+ FPS at 720p.*

```gdscript
# File: res://scripts/environment/WorldEnvironmentConfig.gd
extends Node3D

@onready var world_env: WorldEnvironment = $WorldEnvironment
@onready var moon_light: DirectionalLight3D = $DirectionalLight3D

func _ready() -> void:
	setup_low_end_horror_visuals()

func setup_low_end_horror_visuals() -> void:
	var env: Environment = world_env.environment
	if not env:
		env = Environment.new()
		world_env.environment = env

	# 1. Background Sky: Eerie Midnight Dark Blue
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.015, 0.02, 0.04, 1.0) # Pitch midnight with slight blue tinge

	# 2. Ambient Light: Very dim so dark interior feels terrifying
	env.ambient_light_source = Environment.AMB_COLOR
	env.ambient_light_color = Color(0.04, 0.05, 0.08, 1.0)
	env.ambient_light_energy = 0.6

	# 3. Simple Distance Fog (Cheap for GT 730, avoids heavy Volumetric Fog)
	env.fog_enabled = true
	env.fog_light_color = Color(0.03, 0.04, 0.07, 1.0)
	env.fog_density = 0.02
	env.fog_depth_begin = 4.0
	env.fog_depth_end = 32.0

	# 4. Moon Directional Light Configuration (Soft, non-expensive shadows)
	if moon_light:
		moon_light.light_color = Color(0.45, 0.55, 0.75, 1.0) # Cold moonlight
		moon_light.light_energy = 0.45
		moon_light.shadow_enabled = true
		# Optimization for GT 730: Keep shadow resolution modest
		moon_light.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
		moon_light.directional_shadow_max_distance = 25.0
```

---

### 6. STEP-BY-STEP GODOT EDITOR GUIDE

1. **Launch Godot 4** and open your project.
2. In Project Settings -> **Rendering -> Renderer**, confirm that `gl_compatibility` is selected.
3. In Project Settings -> **Physics -> 3D**, set `Default Gravity` = `9.8`.
4. Create the directories under `res://` listed in Section 2.
5. Create a new Inherited or 3D Scene named `WadaLevel.tscn`.
6. Add a `DirectionalLight3D` and rotate it X: -45°, Y: 30° to cast cold moonlight through the open central courtyard and verandah arches.
7. Use **CSGBox3D** shapes under `WadaStructure` to build the walls according to the dimensions in Section 3:
   - Verandah: 16m wide, 4m deep, 3.5m high.
   - Central Courtyard: 10m x 10m open space in the middle.
   - Ground floor perimeter rooms surrounding the courtyard.
8. Place your `Player.tscn` at the exterior garden path marker.
9. Press **F5** to run the project. Walk up the garden path, pick up the golden key, and unlock the main door.
10. Walk up the staircase ramp to verify that Laksha climbs smoothly without jumping or snagging.

---

### 7. COLLISION & STUCK-PREVENTION CHECKLIST

- [ ] **Player CharacterBody3D `floor_max_angle`**: Set to `45.0` degrees (0.785 rad).
- [ ] **Player `floor_snap_length`**: Set to `0.3` meters to prevent jittering when descending stairs or slopes.
- [ ] **Stairway Collision**: Always cover individual step geometry with a single tilted box `CollisionShape3D` inclined at ~30°.
- [ ] **Doorways**: Ensure minimum door opening clearance is 1.2m wide x 2.4m tall (Player width is 0.8m).
- [ ] **Sloping Roof**: Walkable terracotta tiles must not exceed 25° incline. Place invisible collision barrier boxes at the roof outer edges to prevent game-breaking falls outside the level boundary.
- [ ] **Performance Validation**: Press `F5`, open Debugger -> Monitors, and verify that total draw calls remain below **120** and vertex count remains under **50,000** for stable 30+ FPS on your GT 730.
