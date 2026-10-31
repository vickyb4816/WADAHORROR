# PROJECT: WADA HORROR – TATYA VINCHU
## TECHNICAL DESIGN & IMPLEMENTATION MANUAL: STEP 6 (TATYA VINCHU 3D MODEL, RIGGING, ANIMATION TREE & EMISSIVE GLOW)
**Engine**: Godot 4.2+ / 4.3 (Standard 64-bit)  
**Renderer Target**: `gl_compatibility` (Targeting i3-4150 + GT 730 @ 720p 30 FPS)  
**Hardware Budget**: Low-poly character (~3,500–6,500 tris max), single 1024x1024 or 2048x2048 diffuse/normal/emission texture atlas, 1 standard skeleton (24–32 bones max), zero dynamic ragdoll physics overhead during patrol/chase.

---

### TABLE OF CONTENTS
1. [Character Design Specification (Matching Reference Sheet)](#1-character-design-spec)
2. [Folder Structure for Character & Animations](#2-folder-structure)
3. [Skeleton Hierarchy & Bone Structure](#3-skeleton-bone-structure)
4. [Animation State Machine & Clips Specification](#4-animation-clips-spec)
5. [Complete Production Scripts](#5-complete-scripts)
   - `TatyaAnimator.gd` (AnimationPlayer / AnimationTree Controller & State Dispatcher)
   - `TatyaVisualEffects.gd` (Red Glowing Pupil Pulser, Footstep SFX Hook, Doll Stuttering)
6. [Step-by-Step Godot Scene Setup (`TatyaModel.tscn`)](#6-scene-setup-guide)
7. [Low-End GT 730 Optimization Guide (Compatibility Renderer)](#7-gt730-optimization)
8. [Testing & Verification Checklist](#8-verification-checklist)

---

### 1. CHARACTER DESIGN SPECIFICATION (MATCHING REFERENCE SHEET)

Referencing your **Tatya Vinchu Haunted Doll Character Sheet** (`{{DATA:IMAGE:IMAGE_4}}`):

- **Model Dimensions & Silhouette**:
  - **Height**: 1.05m to 1.15m (doll stature, approximately half of Laksha's 1.8m height). This creates intense psychological claustrophobia when he crouches or runs under low tables and balustrades.
  - **Head Proportions**: Exaggerated, slightly oversized head (chibi/puppet proportions) with wild, spiky copper-brown synthetic doll hair.
  - **Attire**:
    - Red and yellow/green plaid flannel shirt with a dark blue oversized floppy bow tie at the neck.
    - Deep blue cuffed denim overalls / trousers.
    - Crimson red curled pointed-toe doll shoes with worn, faded fabric edges.
    - Pale lavender-grey wax-like synthetic doll skin with prominent stitching / puppet string joints on wrists and fingers.
- **Iconic Facial Features**:
  - Piercing **Crimson Red Glowing Eyes** (`#FF1111`) that cast a subtle, terrifying ambient glow in completely dark Wada hallways.
  - Twisted, wide mischievous puppet grin displaying sharp porcelain teeth.
  - Movable wooden/puppet jaw for Marathi dialogue lip movement.

---

### 2. FOLDER STRUCTURE FOR CHARACTER & ANIMATIONS

Create the following folder structure under your Godot project filesystem (`res://`):

```text
res://
├── scenes/
│   └── characters/
│       ├── TatyaModel.tscn             (Master 3D visual scene with mesh, skeleton, materials)
│       └── TatyaVFX.tscn               (Sub-scene with red eye lights & particle dust)
├── assets/
│   ├── characters/
│   │   └── tatya/
│   │       ├── tatya_vinchu.glb        (Master 3D low-poly model with rig)
│   │       ├── textures/
│   │       │   ├── tatya_diffuse.png   (Base color texture atlas - 1024x1024)
│   │       │   ├── tatya_normal.png    (Subtle cloth and stitching relief)
│   │       │   ├── tatya_emission.png  (Mask for crimson eyes and inner teeth glow)
│   │       │   └── tatya_roughness.png (Wax skin vs matte cloth)
│   │       └── animations/
│   │           ├── anim_idle_doll.res  (Still, uncanny mechanical twitch)
│   │           ├── anim_patrol_walk.res(Creepy doll strut / waddle)
│   │           ├── anim_chase_sprint.res(Aggressive, hurried running with flailing arms)
│   │           ├── anim_sneak_stalk.res(Low hunched stalking pose)
│   │           ├── anim_point_accuse.res(Iconic finger pointing gesture)
│   │           ├── anim_sit_dormant.res (Floppy lifeless sitting doll disguise)
│   │           ├── anim_laugh_manic.res (Head tilted back, vibrating shoulders)
│   │           └── anim_jumpscare_grab.res(Lunge forward at screen)
└── scripts/
    └── characters/
        ├── TatyaAnimator.gd            (Animation state controller)
        └── TatyaVisualEffects.gd       (Eye glow brightness and head twitch controller)
```

---

### 3. SKELETON HIERARCHY & BONE STRUCTURE

For optimal performance on your **GT 730**, the skeleton uses a streamlined humanoid rig with 24 bones (standard for mobile/indie horror games):

```text
Root (Ground alignment bone)
└── Pelvis / Hips
    ├── Spine_01
    │   └── Spine_02 / Chest
    │       ├── Neck
    │       │   └── Head
    │       │       ├── Jaw (Puppet mouth talk / chomp)
    │       │       ├── Eye_Left_Aim (Look-at target)
    │       │       └── Eye_Right_Aim
    │       ├── Clavicle_L
    │       │   └── UpperArm_L
    │       │       └── LowerArm_L
    │       │           └── Hand_L (Puppet fingers open / grab)
    │       └── Clavicle_R
    │           └── UpperArm_R
    │               └── LowerArm_R
    │                   └── Hand_R (Pointing finger pose)
    ├── Thigh_L
    │   └── Calf_L
    │       └── Foot_L
    └── Thigh_R
        └── Calf_R
            └── Foot_R
```

*Note: In Blender, export as `.glb` (glTF 2.0 Binary) with **Skinning**, **Normals**, and **Animation** checked.*

---

### 4. ANIMATION CLIPS SPECIFICATION

Mapping directly to the poses on your **Tatya Vinchu Reference Sheet** (`{{DATA:IMAGE:IMAGE_4}}`):

| Animation Name | Duration (s) | Loop | Description & Movement Characteristics |
| :--- | :--- | :--- | :--- |
| **`idle_doll`** | 2.5s | Yes | Uncanny still pose; subtle mechanical micro-breathing; occasional jerky 1-frame head click to the left. |
| **`patrol_walk`** | 1.0s | Yes | Wooden-legged waddle, arms swinging with loose puppet joints. Speed: ~1.8 m/s. |
| **`chase_sprint`** | 0.6s | Yes | Aggressive forward tilt, frantic rapid patter footsteps, arms outstretched trying to reach Laksha. Speed: ~4.5 m/s. |
| **`sneak_stalk`** | 1.2s | Yes | Hunched low center of gravity, slow calculated footsteps, peering around corners. |
| **`point_accuse`** | 1.8s | No | Stands rigid, snaps right arm forward pointing index finger at Laksha ("Om Bhag Bheeghe Bhagodari!"). |
| **`sit_dormant`** | 3.0s | Yes | Lifeless toy disguise sitting against a wall with splayed legs and tilted head; mimics an inanimate doll until Laksha turns his back. |
| **`laugh_manic`** | 2.0s | No | Head throws back, jaw rattles, chest convulses with sinister Marathi laughter. |
| **`attack_lunge`** | 1.0s | No | High-speed forward pounce, arms clamping forward to latch onto player screen. |

---

### 5. COMPLETE PRODUCTION SCRIPTS

#### SCRIPT 1: `TatyaAnimator.gd`
*Attach this script to the root node of `TatyaModel.tscn` to handle animation states, blending, and transitions.*

```gdscript
# File: res://scripts/characters/TatyaAnimator.gd
class_name TatyaAnimator
extends Node3D

enum State {
	DORMANT_SIT,
	IDLE,
	PATROL_WALK,
	SNEAK,
	CHASE_SPRINT,
	POINT_ACCUSE,
	LAUGH,
	ATTACK_LUNGE
}

@export var current_state: State = State.IDLE
@export var blend_time: float = 0.2

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var visual_effects: Node3D = $TatyaVisualEffects

# Maps states to string animation names registered in AnimationPlayer
var anim_map: Dictionary = {
	State.DORMANT_SIT: "sit_dormant",
	State.IDLE: "idle_doll",
	State.PATROL_WALK: "patrol_walk",
	State.SNEAK: "sneak_stalk",
	State.CHASE_SPRINT: "chase_sprint",
	State.POINT_ACCUSE: "point_accuse",
	State.LAUGH: "laugh_manic",
	State.ATTACK_LUNGE: "attack_lunge"
}

func _ready() -> void:
	play_state(current_state, true)

# Switch animation smoothly with cross-fade
func play_state(new_state: State, force: bool = false) -> void:
	if not force and current_state == new_state:
		return
	
	current_state = new_state
	var anim_name: String = anim_map.get(new_state, "idle_doll")
	
	if anim_player.has_animation(anim_name):
		anim_player.play(anim_name, blend_time)
		print("[TATYA ANIM] Transitioned to: ", anim_name)
	else:
		push_warning("[TATYA ANIM] Animation missing: " + anim_name + ". Defaulting to idle_doll.")
		if anim_player.has_animation("idle_doll"):
			anim_player.play("idle_doll", blend_time)

# Helper methods called by Step 7 Tatya AI
func set_walking() -> void:
	play_state(State.PATROL_WALK)

func set_running() -> void:
	play_state(State.CHASE_SPRINT)

func set_idle() -> void:
	play_state(State.IDLE)

func set_stalking() -> void:
	play_state(State.SNEAK)

func trigger_laugh() -> void:
	play_state(State.LAUGH)
	# Revert back to idle after laugh animation completes
	await anim_player.animation_finished
	if current_state == State.LAUGH:
		play_state(State.IDLE)

func trigger_point_gesture() -> void:
	play_state(State.POINT_ACCUSE)
	await anim_player.animation_finished
	if current_state == State.POINT_ACCUSE:
		play_state(State.IDLE)

func trigger_attack() -> void:
	play_state(State.ATTACK_LUNGE)

func set_dormant_doll_mode() -> void:
	play_state(State.DORMANT_SIT)
```

---

#### SCRIPT 2: `TatyaVisualEffects.gd`
*Attach this script to a child node `TatyaVisualEffects` inside `TatyaModel.tscn`. It manages Tatya's terrifying glowing eyes, sudden stop-motion neck spasms, and emits footstep signals for 3D positional audio.*

```gdscript
# File: res://scripts/characters/TatyaVisualEffects.gd
class_name TatyaVisualEffects
extends Node3D

signal footstep_sound_triggered(is_running: bool)

@export var mesh_instance_path: NodePath = ^"../Armature/Skeleton3D/TatyaMesh"
@export var left_eye_light_path: NodePath = ^"EyeLightL"
@export var right_eye_light_path: NodePath = ^"EyeLightR"

# Eye intensity tuning
@export var normal_eye_energy: float = 0.8
@export var chase_eye_energy: float = 2.4
@export var eye_pulse_speed: float = 4.0

@onready var mesh_instance: MeshInstance3D = get_node_or_null(mesh_instance_path)
@onready var eye_light_l: OmniLight3D = get_node_or_null(left_eye_light_path)
@onready var eye_light_r: OmniLight3D = get_node_or_null(right_eye_light_path)

var is_chasing: bool = false
var pulse_time: float = 0.0
var material_override: StandardMaterial3D = null

func _ready() -> void:
	# Clone mesh material instance so runtime emission pulses don't leak to other meshes
	if mesh_instance and mesh_instance.get_active_material(0):
		material_override = mesh_instance.get_active_material(0).duplicate()
		mesh_instance.set_surface_override_material(0, material_override)
	
	setup_eye_lights()

func setup_eye_lights() -> void:
	var red_color = Color(1.0, 0.05, 0.05, 1.0) # Blood red from character sheet
	
	if eye_light_l:
		eye_light_l.light_color = red_color
		eye_light_l.omni_range = 1.5
		eye_light_l.shadow_enabled = false # Keep shadows off for GT 730 optimization
	
	if eye_light_r:
		eye_light_r.light_color = red_color
		eye_light_r.omni_range = 1.5
		eye_light_r.shadow_enabled = false

func _process(delta: float) -> void:
	pulse_time += delta * (eye_pulse_speed * (2.0 if is_chasing else 1.0))
	var pulse: float = (sin(pulse_time) + 1.0) * 0.5 # 0.0 to 1.0
	
	var target_energy: float = lerp(normal_eye_energy * 0.7, normal_eye_energy * 1.3, pulse)
	if is_chasing:
		target_energy = lerp(chase_eye_energy * 0.8, chase_eye_energy * 1.5, pulse)
	
	# Update localized OmniLights in eye sockets
	if eye_light_l:
		eye_light_l.light_energy = target_energy
	if eye_light_r:
		eye_light_r.light_energy = target_energy
	
	# Update material emission intensity
	if material_override:
		var emission_boost = target_energy * 1.2
		material_override.emission_energy_multiplier = emission_boost

# Set chase mode for intense glowing eyes and frantic pacing
func set_chase_mode(enabled: bool) -> void:
	is_chasing = enabled

# Animation call-method track hook for footsteps
func trigger_footstep_step() -> void:
	emit_signal("footstep_sound_triggered", is_chasing)
```

---

### 6. STEP-BY-STEP GODOT SCENE SETUP (`TatyaModel.tscn`)

Build `TatyaModel.tscn` in Godot’s 3D Editor:

```text
TatyaModel (Node3D) [Script: TatyaAnimator.gd]
├── Armature (Node3D)
│   └── Skeleton3D (Skeleton3D)
│       └── TatyaMesh (MeshInstance3D)
│           ├── Surface 0: StandardMaterial3D (Wax Skin, Clothes, Plaid, Emission)
│           └── BoneAttachment3D_Head (BoneAttachment3D - Bone: "Head")
│               ├── EyeLightL (OmniLight3D - Crimson Red, Range: 1.5m, Shadows: OFF)
│               └── EyeLightR (OmniLight3D - Crimson Red, Range: 1.5m, Shadows: OFF)
├── AnimationPlayer (AnimationPlayer - Holds all 8 animations)
├── TatyaVisualEffects (Node3D) [Script: TatyaVisualEffects.gd]
└── AudioStreamPlayer3D_DollSteps (AudioStreamPlayer3D - Rapid wooden clicks)
```

#### Step-by-Step Editor Assembly:
1. **Import `tatya_vinchu.glb`**:
   - In Godot FileSystem dock, select `tatya_vinchu.glb`.
   - In the Import dock, set **Root Type** to `Node3D`. Ensure **Animation -> Import** is enabled. Click **Reimport**.
2. **Setup the Master Material (`mat_tatya_vinchu.tres`)**:
   - Albedo: Assign `tatya_diffuse.png`.
   - Roughness: Roughness texture assigned (wax skin slightly shiny, fabric rough).
   - Emission:
     - Check **Enabled = true**.
     - Color: `#FF0000` (Pure Red).
     - Texture: Assign `tatya_emission.png` (Mask with only the eyes and teeth white, background black).
     - Energy Multiplier: `1.5`.
3. **Head Bone Attachment for Eye Glow Lights**:
   - Right-click `Skeleton3D` -> **Add Child** -> `BoneAttachment3D`.
   - In the Inspector, select **Bone Name** -> `Head`.
   - Add two `OmniLight3D` nodes under the BoneAttachment (`EyeLightL` and `EyeLightR`).
   - Move `EyeLightL` to local position `Vector3(0.08, 0.05, 0.12)` and `EyeLightR` to `Vector3(-0.08, 0.05, 0.12)` matching his red eye pupils.
4. **Attach Production Scripts**:
   - Attach `TatyaAnimator.gd` to the root `TatyaModel` node.
   - Attach `TatyaVisualEffects.gd` to the `TatyaVisualEffects` child node.
5. **Setup Footstep Animation Events**:
   - Open `AnimationPlayer`, select `patrol_walk`.
   - Add a **Call Method Track** targeting `TatyaVisualEffects`.
   - Insert keyframes on foot down moments (e.g., at `0.25s` and `0.75s`) calling `trigger_footstep_step()`.

---

### 7. LOW-END GT 730 OPTIMIZATION GUIDE (COMPATIBILITY RENDERER)

To keep your **i3-4150 + GT 730** locked at **30+ FPS at 720p**:

1. **Polygon Budget**:
   - Keep Tatya’s mesh between **3,500 and 6,500 triangles**. This avoids vertex bottlenecks on the GT 730’s Fermi/Kepler core architecture.
2. **Single Texture Atlas**:
   - Pack the entire character (head, hair, flannel shirt, bow tie, denim trousers, shoes) into a **single 1024x1024 or 2048x2048 texture sheet**. This ensures Tatya draws in **1 single draw call**!
3. **OmniLight Shadows Disabled**:
   - Tatya’s glowing red eye lights (`EyeLightL` and `EyeLightR`) have **`shadow_enabled = false`**. Shadow maps on moving character lights destroy fill-rate on low-end GPUs. The emission texture and unshadowed omni range provide maximum atmosphere with zero frame drops.
4. **Distance LOD / Cull**:
   - In `MeshInstance3D`, set **Visibility Range End** to `35.0m`. If Tatya is on the other side of the compound beyond thick midnight fog, Godot automatically skips drawing his geometry.

---

### 8. TESTING & VERIFICATION CHECKLIST

- [ ] **Height Scaling**: Tatya stands at ~1.1m (chest/waist level compared to Laksha), fitting easily through standard 1.2m doors and under tables.
- [ ] **Crimson Eye Glow**: Red pupils visibly pulse and cast eerie red highlights on nearby walls in dark corridors.
- [ ] **Animation Blending**: Transitioning from `idle_doll` to `patrol_walk` and `chase_sprint` cross-fades smoothly without snapping or T-posing.
- [ ] **Bone Attachment Tracking**: Eye lights remain locked directly in front of Tatya's pupils as his head tilts and twitches.
- [ ] **FPS Benchmark on GT 730**: Rendering Tatya with his eyes glowing introduces **< 0.1ms render time**, maintaining a smooth 30+ FPS at 720p.
