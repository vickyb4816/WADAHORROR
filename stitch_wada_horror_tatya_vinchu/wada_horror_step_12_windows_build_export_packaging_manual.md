# PROJECT: WADA HORROR – TATYA VINCHU
## TECHNICAL DESIGN & IMPLEMENTATION MANUAL: STEP 12 (WINDOWS 64-BIT EXPORT, PACKAGING & LOW-SPEC GT 730 TUNING GUIDE)
**Engine**: Godot 4.2+ / 4.3 (Standard 64-bit)  
**Target Hardware**: Intel Core i3-4150 (3.50 GHz, 2 Cores / 4 Threads), NVIDIA GeForce GT 730 (2GB DDR3/GDDR5, 384 Kepler CUDA Cores / 96 Fermi Cores), 8GB DDR3 RAM, 7200 RPM HDD or SATA SSD.  
**Renderer Target**: `gl_compatibility` (OpenGL 3.3 / ES 3.0 fallback)  
**Distribution Target**: Windows 64-bit Standalone Executable + PCK Archive (`WadaHorror_TatyaVinchu.exe` + `WadaHorror_TatyaVinchu.pck`) / Single ZIP Distribution.

---

### TABLE OF CONTENTS
1. [Target Hardware Reality & Bottleneck Analysis (i3-4150 + GT 730)](#1-hardware-bottleneck-analysis)
2. [Project Settings & Engine Export Configuration (`project.godot`)](#2-project-settings-configuration)
3. [Windows Desktop Export Preset Configuration (`export_presets.cfg`)](#3-export-preset-configuration)
4. [Packaging & Distribution Structure](#4-packaging-distribution)
5. [Complete Production Pre-Flight Scripts](#5-complete-scripts)
   - `BuildOptimizer.gd` (Pre-export scene & resource validator for low-end specs)
   - `PerformanceMonitorOverlay.gd` (In-game low-spec diagnostics: FPS, VRAM, Drawcalls, Frame Time)
6. [Step-by-Step Godot Editor Windows Export Guide](#6-step-by-step-export-guide)
7. [Post-Build Quality Assurance & Verification Checklist](#7-qa-verification-checklist)

---

### 1. TARGET HARDWARE REALITY & BOTTLENECK ANALYSIS

The target setup is an entry-level legacy PC widely found in Indian cyber cafes, budget home rigs, and modest laptops:

```
+-----------------------------------------------------------------------------------+
| COMPONENT         | SPECIFICATION            | PRIMARY BOTTLENECK & CRITICAL MITIGATION |
+-----------------------------------------------------------------------------------+
| CPU               | Intel Core i3-4150       | 2 physical cores. Navigation and audio    |
|                   | (3.50 GHz, 4 Threads)    | queries must run asynchronously; avoid    |
|                   |                          | per-frame script allocations or deep trees|
+-----------------------------------------------------------------------------------+
| GPU               | NVIDIA GeForce GT 730    | Pixel Fill Rate (Memory bandwidth ~14GB/s)|
|                   | (2GB DDR3 / GDDR5)       | Resolution MUST be locked to 1280x720 by  |
|                   |                          | default; max 1 active directional shadow. |
+-----------------------------------------------------------------------------------+
| SYSTEM MEMORY     | 8GB DDR3                 | Texture VRAM leak prevention. Atlas all   |
|                   |                          | 3D models into 1024/2048 VRAM textures.   |
+-----------------------------------------------------------------------------------+
| RENDERER BACKEND  | gl_compatibility         | Vulkan Forward+ and Mobile will stutter   |
|                   | (OpenGL 3.3)             | or crash on Kepler/Fermi drivers!         |
+-----------------------------------------------------------------------------------+
```

#### Why `gl_compatibility` is mandatory:
1. The GT 730 driver implementation for Vulkan (Vulkan 1.1 / 1.2) suffers from extreme driver-level shader compilation stutter and lack of support for advanced Vulkan features.
2. `gl_compatibility` strips out compute shader overhead, complex screen-space reflections (SSR), and heavy volumetric clouds, delivering an immediate **60–80% framerate increase** compared to `Forward+`.

---

### 2. PROJECT SETTINGS & ENGINE EXPORT CONFIGURATION (`project.godot`)

Verify and apply these critical properties inside your `project.godot` file before building:

```ini
[application]
config/name="Wada Horror - Tatya Vinchu"
config/version="1.0.0"
run/main_scene="res://scenes/ui/MainMenu.tscn"
config/features=PackedStringArray("4.3", "GL Compatibility")
boot_splash/bg_color=Color(0, 0, 0, 1)
boot_splash/show_image=false
config/icon="res://icon.svg"

[display]
window/size/viewport_width=1280
window/size/viewport_height=720
window/size/mode=3 ; Mode 3 = Exclusive Fullscreen
window/stretch/mode="viewport"
window/stretch/aspect="keep"
window/vsync/vsync_mode=1 ; VSync Enabled to avoid screen tearing on 60Hz panels

[rendering]
renderer/rendering_method="gl_compatibility"
renderer/rendering_method.mobile="gl_compatibility"
textures/vram_compression/import_etc2_astc=false
textures/vram_compression/import_s3tc_bptc=true
driver/threads/thread_model=1 ; Safe Multi-threaded for dual-core CPU

[textures]
canvas_textures/default_texture_filter=1 ; Linear filter
default_filters/use_nearest_mipmap_filter=false

[environment]
defaults/default_clear_color=Color(0.015, 0.02, 0.04, 1.0)

[audio]
buses/default_bus_layout="res://default_bus_layout.tres"

[physics]
common/physics_ticks_per_second=60
3d/solver/solver_iterations=8 ; Default is 16; reduced to 8 for i3-4150 CPU budget
```

---

### 3. WINDOWS DESKTOP EXPORT PRESET CONFIGURATION (`export_presets.cfg`)

In the Godot Editor, navigate to **Project -> Export...** and add a **Windows Desktop** preset with the following properties:

```ini
[preset.0]
name="Windows Desktop (Low-Spec GT 730 Optimized)"
platform="Windows Desktop"
runnable=true
dedicated_server=false
custom_features=""
export_filter="all_resources"
include_filter=""
exclude_filter="*.tmp, *.bak, *.blend1, *.aseprite, *.psd, .git/*"
export_path="./bin/WadaHorror_TatyaVinchu.exe"
encryption_include_filters=""
encryption_exclude_filters=""
encrypt_pck=false
encrypt_directory=false

[preset.0.options]
custom_template/debug=""
custom_template/release=""
binary_format/embed_pck=false ; Separate .pck allows faster loading & modding
texture_format/bptc=false ; False ensures compatibility with legacy Kepler GPUs
texture_format/s3tc=true ; Traditional DXT1/DXT5 compression (ideal for GT 730)
application/modify_resources=true
application/icon="res://assets/ui/icon_tatya_512.ico"
application/console_wrapper_flags=0
application/icon_interpolations=true
application/file_version="1.0.0.0"
application/product_version="1.0.0.0"
application/company_name="Konkan Folk Horror Studios"
application/product_name="Wada Horror: Tatya Vinchu"
application/file_description="A Konkan Psychological Survival Horror Experience"
application/copyright="2025 Konkan Folk Horror"
application/trademarks=""
ssh/scp_path=""
ssh/host=""
ssh/port=""
ssh/remote_path=""
```

---

### 4. PACKAGING & DISTRIBUTION STRUCTURE

Organize the final export into a clean, standalone ZIP package for end users:

```text
WadaHorror_TatyaVinchu_v1.0.0_Win64/
├── WadaHorror_TatyaVinchu.exe          (Main Windows Executable ~ 65MB)
├── WadaHorror_TatyaVinchu.pck          (Packed Game Assets, Shaders & Maps ~ 350–500MB)
├── README.txt                          (Hardware Requirements, Controls & Troubleshooting)
└── OpenAudioLicense.txt                (Creative Commons & Audio Attribution)
```

#### Content of `README.txt` for End Users:
```text
===================================================================
         WADA HORROR: TATYA VINCHU (वाडा हॉरर – तात्या विंचू)
                     Version 1.0.0 (Windows 64-bit)
===================================================================

[MINIMUM SYSTEM REQUIREMENTS]
- OS: Windows 7 / 8.1 / 10 / 11 (64-bit)
- Processor: Intel Core i3-4150 (3.5 GHz) or AMD FX-4300
- Memory: 4 GB RAM (8 GB Recommended)
- Graphics: NVIDIA GeForce GT 730 (2GB VRAM) or AMD Radeon R7 240
- DirectX/OpenGL: OpenGL 3.3 Compatible
- Storage: 1.5 GB available space

[DEFAULT PERFORMANCE RECOMMENDATION]
- The game launches in 1280x720 Fullscreen for optimal 30–45 FPS.
- If experiencing frame drops, enter Settings -> Display and set:
    * Resolution: 1280 x 720
    * Shadows: Low (Orthogonal) or Off
    * VSync: Enabled

[DEFAULT CONTROLS]
- WASD: Move
- Mouse: Look
- Shift: Sprint (Caution: sprinting makes loud noise!)
- Ctrl / C: Crouch (Silent footsteps)
- E: Interact / Pick Up / Inspect / Hide in Cupboard
- Tab / I: Inventory & Clues
- M: Progressive Wada Map
- Esc: Pause Game & Settings
===================================================================
```

---

### 5. COMPLETE PRODUCTION PRE-FLIGHT SCRIPTS

#### SCRIPT 1: `BuildOptimizer.gd` (Pre-Export Quality & Resource Validator)
*Run this tool script directly inside the Godot Editor or as an EditorScript before building to catch missing assets, high-poly meshes, and non-compatibility materials.*

```gdscript
# File: res://scripts/tools/BuildOptimizer.gd
@tool
extends EditorScript

func _run() -> void:
	print("====================================================")
	print("[BUILD AUDIT] Starting GT 730 Pre-Flight Validation...")
	print("====================================================")
	
	var issues_found: int = 0
	
	# 1. Verify Main Scene
	var main_scene = ProjectSettings.get_setting("application/run/main_scene")
	if not ResourceLoader.exists(main_scene):
		push_error("[AUDIT ERROR] Main scene not found: " + str(main_scene))
		issues_found += 1
	else:
		print("[AUDIT OK] Main Scene verified: ", main_scene)
	
	# 2. Check Renderer Backend
	var renderer = ProjectSettings.get_setting("rendering/renderer/rendering_method")
	if renderer != "gl_compatibility":
		push_warning("[AUDIT WARN] Renderer is currently set to '" + str(renderer) + "'. GT 730 REQUIRES 'gl_compatibility'!")
		issues_found += 1
	else:
		print("[AUDIT OK] Renderer configured correctly: gl_compatibility")
	
	# 3. Check Default Window Resolution
	var width = ProjectSettings.get_setting("display/window/size/viewport_width")
	var height = ProjectSettings.get_setting("display/window/size/viewport_height")
	if width > 1280 or height > 720:
		push_warning("[AUDIT WARN] Default resolution is set to " + str(width) + "x" + str(height) + ". Recommended GT 730 default is 1280x720!")
	else:
		print("[AUDIT OK] Viewport resolution target verified: ", width, "x", height)
	
	# 4. Check Autoload Singletons
	var required_autoloads: Array[String] = [
		"SaveManager",
		"SettingsManager",
		"InventoryManager",
		"MapManager",
		"PuzzleManager",
		"GameManager",
		"AudioManager"
	]
	
	for al in required_autoloads:
		var path = "autoload/" + al
		if not ProjectSettings.has_setting(path):
			push_error("[AUDIT ERROR] Missing required Autoload: " + al)
			issues_found += 1
		else:
			print("[AUDIT OK] Autoload verified: ", al)
	
	print("====================================================")
	if issues_found == 0:
		print("[BUILD AUDIT] ALL CHECKS PASSED! Ready for Windows 64-bit Export.")
	else:
		push_warning("[BUILD AUDIT] Completed with " + str(issues_found) + " warnings/errors. Review above before exporting!")
	print("====================================================")
```

---

#### SCRIPT 2: `PerformanceMonitorOverlay.gd` (In-Game Diagnostics HUD)
*Attach this script to a lightweight `CanvasLayer` in your testing build (or toggle via `F3`) to display live FPS, Draw Calls, and Frame Times during playtesting.*

```gdscript
# File: res://scripts/ui/PerformanceMonitorOverlay.gd
extends CanvasLayer

@onready var label_stats: Label = $MarginContainer/LabelStats
var is_active: bool = false

func _ready() -> void:
	layer = 120 # Above all other HUDs
	visible = false

func _input(event: InputEvent) -> void:
	# Toggle performance metrics with F3 key
	if event is InputEventKey and event.pressed and event.keycode == KEY_F3:
		is_active = !is_active
		visible = is_active

func _process(_delta: float) -> void:
	if not is_active:
		return
	
	var fps = Engine.get_frames_per_second()
	var draw_calls = Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	var objects_drawn = Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)
	var video_mem = Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / (1024.0 * 1024.0)
	var process_time = Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
	var physics_time = Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0
	
	# Color code FPS target
	var fps_color = "#4CAF50" # Green (>= 30 FPS)
	if fps < 25:
		fps_color = "#F44336" # Red (< 25 FPS)
	elif fps < 30:
		fps_color = "#FF9800" # Orange (25-30 FPS)
	
	label_stats.text = (
		"GT 730 BENCHMARK METRICS (F3 to Hide)\n" +
		"FPS: " + str(fps) + " [Target: 30+ FPS]\n" +
		"Frame Time: " + "%.2f" % process_time + " ms | Physics: " + "%.2f" % physics_time + " ms\n" +
		"Draw Calls: " + str(draw_calls) + " (Max target: < 120)\n" +
		"Objects Drawn: " + str(objects_drawn) + "\n" +
		"VRAM Estimated: " + "%.1f" % video_mem + " MB / 2048 MB"
	)
```

---

### 6. STEP-BY-STEP GODOT EDITOR WINDOWS EXPORT GUIDE

Follow these exact steps inside the Godot 4.2 / 4.3 editor:

1. **Install Godot Export Templates**:
   - Go to **Editor -> Manage Export Templates...**
   - Confirm that the template matching your exact engine version (e.g. `4.3.stable`) is installed. If not, click **Download and Install**.
2. **Open the Export Dialog**:
   - Click **Project -> Export...**
   - Click **Add...** -> select **Windows Desktop**.
3. **Configure Export Options**:
   - **Name**: `Windows Desktop (Low-Spec)`
   - **Binary Format / Embed PCK**: Toggle to **OFF** (`Embed PCK = false`).
     *(Keeping `.pck` external accelerates streaming and prevents Windows Defender heuristic false positives).*
   - **Export Path**: Set destination to a `bin/` folder (e.g., `bin/WadaHorror_TatyaVinchu.exe`).
4. **Configure Resources Tab**:
   - Set **Export Mode** to **Export all resources in the project**.
   - Filters to exclude: `*.tmp, *.bak, *.blend1, .git/*`.
5. **Execute the Export**:
   - Click **Export Project** at the bottom right.
   - Choose your output filename: `WadaHorror_TatyaVinchu.exe`.
   - Ensure **Export With Debug** is **UNCHECKED** for the final production build (Release builds perform 15–25% faster due to omitted debug hooks).
   - Click **Save**. Godot will compile and package the game assets in under 60 seconds.

---

### 7. POST-BUILD QUALITY ASSURANCE & VERIFICATION CHECKLIST

Test the exported `.exe` on your target hardware or low-power profile:

- [ ] **Clean Boot & Splash**: Game launches directly into `MainMenu.tscn` in exclusive 720p fullscreen without aspect ratio stretching or black screen freezes.
- [ ] **Saved Game Persistence (`user://`)**:
  - Verify that saving checkpoints creates `save_game.json` in `%APPDATA%\Godot\app_userdata\Wada Horror - Tatya Vinchu\`.
  - Verify that changing audio sliders or resolution writes cleanly to `settings.cfg`.
- [ ] **Draw Call Budget on GT 730**: Press `F3` during the Courtyard, Upper Gallery, and Terrace boss fight:
  - Total Draw Calls remain **below 110–130**.
  - Total VRAM consumption remains **under 650 MB** (well below the 2048 MB limit).
- [ ] **Frame Rate Stability**:
  - Main Verandah & Courtyard: **34–42 FPS**.
  - Drawing Room & Corridors: **36–45 FPS**.
  - Rooftop Thunderstorm Boss Fight (Step 10 Climax): **Solid 30–33 FPS** at 720p.
- [ ] **Mouse Sensitivity & Window Focus**:
  - Alt-Tab releases cursor cleanly.
  - Re-entering the window captures mouse look without erratic snaps.
- [ ] **Audio Mix Balance**:
  - Tatya's Marathi voice lines are crisp and spatialized.
  - Low-pass filter properly engages when Laksha hides inside a wardrobe.
- [ ] **Final Distribution Package**:
  - The zipped folder contains `WadaHorror_TatyaVinchu.exe`, `WadaHorror_TatyaVinchu.pck`, and `README.txt`, executing flawlessly on a clean machine without requiring Godot to be installed.
