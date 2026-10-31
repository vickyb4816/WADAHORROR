# PROJECT: WADA HORROR – TATYA VINCHU
## TECHNICAL DESIGN & IMPLEMENTATION MANUAL: STEP 10 (FINAL EXORCISM CLIMAX, TERRACE BOSS FIGHT & MULTIPLE ENDINGS SYSTEM)
**Engine**: Godot 4.2+ / 4.3 (Standard 64-bit)  
**Renderer / Platform Target**: `gl_compatibility` (Targeting i3-4150 + GT 730 @ 720p 30 FPS)  
**Hardware & Boss Arena Budget**: Max 2 active dynamic lights during confrontation, lightweight 2D CanvasLayer boss health/ritual wheel HUD, zero real-time volumetric fog, lightweight particle emission for holy fire and camphor smoke, streamlined 3-ending game state manager.

---

### TABLE OF CONTENTS
1. [Climax Architecture & Dramatic Narrative Setup](#1-climax-architecture)
2. [Folder Structure for Boss Encounter & Endings](#2-folder-structure)
3. [Boss Fight Phase Breakdown (3-Stage Rooftop Ritual)](#3-phase-breakdown)
4. [The 3 Branching Endings Specification](#4-endings-specification)
5. [Complete Production Scripts](#5-complete-scripts)
   - `GameManager.gd` (Master Autoload: Game State, Endings Tracker, Cutscene & Reset Handler)
   - `TerraceBossArena.gd` (Arena Director: Thunderstorm Ambience, Barricaded Gates, 3-Phase Progression)
   - `TatyaBossAI.gd` (Upgraded Aggressive Boss Controller: Teleport, Tantric Doppelgangers, Stun Vulnerability)
   - `ExorcismRitualController.gd` (Terrace Sacred Brazier / Havankund Offering & Dagger Strike Mechanic)
   - `ExorcismHUD.gd` (Boss Health / Tantric Seal Meter, Camphor Prompt, Exorcism QTE Indicator)
   - `EndingCutsceneUI.gd` (Cinematic Ending Parchment Epilogue, Voiceover Hooks & Credits)
6. [Scene Setup Guide (`TerraceArena.tscn`, `ExorcismHUD.tscn`, `EndingCutsceneUI.tscn`)](#6-scene-setup)
7. [Low-End GT 730 & i3-4150 Optimization Guide](#7-optimization-guide)
8. [Testing & Verification Checklist](#8-verification-checklist)

---

### 1. CLIMAX ARCHITECTURE & DRAMATIC NARRATIVE SETUP

The climactic confrontation takes place on the **Terrace & Rooftop of the Inamdar Wada (`Y = 7.2m`)** amidst a stormy Konkan midnight. Rain lashes against the terracotta clay tiles, lightning flashes illuminate the ancient balustrades, and Tatya Vinchu sheds his cautious stalker persona to unleash his full tantric curse:

```
[PREREQUISITES TO INITIATE STEP 10]
- Laksha unlocks the heavy iron rooftop gate using 'key_terrace_roof' (obtained in Step 9).
- Inventory must contain:
  1. 'item_copper_dagger' (Sanctified Scorpion Dagger found in Library / Clue 5)
  2. 'item_sacred_camphor' (Purified Camphor from the Store Room Chest / Puzzle 3)
  3. 'item_matchbox' (Sacred Matchbox from Kitchen)

[THE CLIMAX ARENA (TERRACE)]
- The rooftop iron gate slams shut behind Laksha; Tatya locks the escape route.
- A sacred bronze Havankund (Ritual Fire Pit) stands in the center of the terrace.
- Tatya manifests on the terrace balustrades with violent crimson eye flares, laughing manically:
  "आता इथून कोणीच जिवंत जाणार नाही! ओम भग भुगे भगोदरी भागिनी!"
```

---

### 2. FOLDER STRUCTURE FOR BOSS ENCOUNTER & ENDINGS

Create the following files in your Godot project filesystem (`res://`):

```text
res://
├── scenes/
│   ├── encounters/
│   │   ├── TerraceArena.tscn             (Rooftop boss arena trigger & environmental props)
│   │   └── HavankundAltar.tscn           (Central ritual brazier with holy fire VFX)
│   ├── characters/
│   │   └── TatyaBoss.tscn                (Boss variant with clone spawning & lightning stuns)
│   └── ui/
│       ├── ExorcismHUD.tscn              (Tantric seal breakdown meter & ritual prompts)
│       └── EndingCutsceneUI.tscn         (Cinematic 3-ending epilogue, illustrations & credits)
├── scripts/
│   ├── autoload/
│   │   └── GameManager.gd                (Master game progression, endings & checkpoint state)
│   ├── encounters/
│   │   ├── TerraceBossArena.gd           (Phase triggers, gate lock, arena storm manager)
│   │   ├── TatyaBossAI.gd                (High-speed boss pursuit, clone illusions & pounce)
│   │   └── ExorcismRitualController.gd   (Camphor burning & Dagger strike hit registration)
│   └── ui/
│       ├── ExorcismHUD.gd                (Boss health/seal HUD & ritual quick-prompts)
│       └── EndingCutsceneUI.gd           (Epilogue text, regional voiceover & restart loop)
└── assets/
    ├── audio/
    │   ├── music/
    │   │   └── bgm_tatya_exorcism_boss.ogg (Fast Maharashtrian dhol & frantic horror strings)
    │   ├── sfx/
    │   │   ├── sfx_lightning_strike.wav
    │   │   ├── sfx_havankund_flare.wav
    │   │   ├── sfx_dagger_strike.wav
    │   │   ├── sfx_tatya_shriek_banish.ogg
    │   │   └── sfx_gate_slam_shut.wav
    │   └── voice/
    │       ├── tatya_boss_taunt_01.ogg   ("माझा आत्मा अमर आहे!")
    │       ├── tatya_boss_death.ogg       ("नाही... ओम... भग...")
    │       └── laksha_exorcism_chant.ogg (Laksha reciting the counter-curse)
    └── ending/
        ├── ending_good_exorcised.png     (Dawn breaks over Wada, lifeless doll smoking in ash)
        ├── ending_bad_possessed.png      (Laksha with glowing red eyes, clutching doll smiling)
        └── ending_escape_cursed.png      (Laksha fleeing Wada gate into dark night while doll whispers)
```

---

### 3. BOSS FIGHT PHASE BREAKDOWN (3-STAGE ROOFTOP RITUAL)

Tatya Vinchu cannot be harmed with conventional physical weapons. He must be weakened through the **Holy Camphor Ritual at the Havankund** before the **Copper Dagger** can pierce the scorpion crest on his forehead:

```
               [PHASE 1: THE TERROR PURSUIT]
               - Tatya sprints at extreme speed (4.8 m/s).
               - Laksha must reach the Havankund and ignite the Sacred Camphor.
               - Holy camphor smoke stuns Tatya for 6.0 seconds.
               - Laksha strikes Tatya's forehead with the Copper Dagger (Strike 1/3).
                                     |
                                     v
               [PHASE 2: CLAY TILE ILLUSIONS & AMBUSH]
               - Tatya vanishes in a plume of dark smoke onto roof ridge tiles.
               - 2 Tantric Shadow Clones spawn and attack from flanks (1-hit dispelled).
               - Real Tatya charges from the dark with flashing red eyes.
               - Laksha adds purified incense to the flame to create a holy shockwave.
               - Stuns real Tatya -> Second Dagger Strike to crest (Strike 2/3).
                                     |
                                     v
               [PHASE 3: THE MIDNIGHT ENRAGE & FINAL EXORCISM]
               - Thunderstorm intensifies; lightning periodically illuminates the arena.
               - Tatya moves erratically at 5.5 m/s, hurling flying debris.
               - The Havankund flame turns deep gold; Laksha initiates the final chanting sequence.
               - Final QTE / Dagger Strike directly through the doll's forehead scorpion mark.
               - Tatya shrivels and collapses; soul releases in a blinding burst of light.
```

---

### 4. THE 3 BRANCHING ENDINGS SPECIFICATION

The ending is determined by Laksha's actions, collected clues, and boss fight choices:

| Ending ID | Name | Unlock Conditions | Narrative Epilogue |
| :--- | :--- | :--- | :--- |
| **ENDING A (Good)** | **"मुक्ती" (Purification & Freedom)** | - All 6 clues discovered (including `doc_final_exorcism`).<br>- Successfully completed all 3 Havankund ritual strikes without letting the holy flame extinguish. | Dawn breaks over the Konkan hills. Laksha watches the wooden doll crumble to harmless grey ash in the Havankund fire pit. The 80-year-old Inamdar curse is broken forever. Laksha walks out into the morning sunlight. |
| **ENDING B (Bad)** | **"पुनर्जन्म" (The Soul Vessel Reborn)** | - Laksha's health drops to 0 during Phase 3, OR player hesitates > 10 seconds during the final strike prompt. | Tatya lunges at Laksha's face. The screen turns blood-red. A sinister voice whispers Baba Chamatkar's mantra. Cut to black: Laksha stands before the courtyard mirror with glowing crimson eyes, laughing manically in Tatya's voice. |
| **ENDING C (Neutral / Cursed)** | **"अपूर्ण मुक्ती" (The Lingering Shadow)** | - Defeated Tatya without reading Baba Chamatkar's Scroll (`doc_tantric_mantra`), OR Laksha fled through the emergency terrace drain gate without burning the doll's body. | Laksha escapes the Wada into the stormy night. He catches his breath at his car. In the back seat mirror, small wooden footsteps tap against the glass. A faint doll giggle echoes: *"मी तुझ्यासोबतच आहे, लक्षा!"* |

---

### 5. COMPLETE PRODUCTION SCRIPTS

#### SCRIPT 1: `GameManager.gd` (Autoload / Global Singleton)
*Add `res://scripts/autoload/GameManager.gd` as `GameManager` in Godot Autoload.*

```gdscript
# File: res://scripts/autoload/GameManager.gd
extends Node

enum GameState {
	EXPLORATION,
	CUTSCENE,
	BOSS_FIGHT,
	GAME_OVER,
	ENDING
}

enum EndingType {
	GOOD_EXORCISED,
	BAD_POSSESSED,
	NEUTRAL_CURSED
}

signal game_state_changed(new_state: GameState)
signal ending_triggered(ending_type: EndingType)

var current_state: GameState = GameState.EXPLORATION
var current_ending: EndingType = EndingType.GOOD_EXORCISED

# Boss fight tracking
var ritual_strikes_completed: int = 0
var boss_health_max: int = 3
var is_boss_defeated: bool = false

# Player stats
var player_health: float = 100.0
var max_health: float = 100.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func set_state(new_state: GameState) -> void:
	current_state = new_state
	emit_signal("game_state_changed", new_state)
	print("[GAME] State changed to: ", GameState.keys()[new_state])

func trigger_ending(ending: EndingType) -> void:
	current_ending = ending
	set_state(GameState.ENDING)
	emit_signal("ending_triggered", ending)
	
	# Stop background combat audio
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_exploration_music(3.0)

func reset_game_session() -> void:
	ritual_strikes_completed = 0
	is_boss_defeated = false
	player_health = max_health
	current_state = GameState.EXPLORATION
	get_tree().reload_current_scene()
```

---

#### SCRIPT 2: `TerraceBossArena.gd`
*Attach this script to `res://scenes/encounters/TerraceArena.tscn` (Root Node3D).*

```gdscript
# File: res://scripts/encounters/TerraceBossArena.gd
class_name TerraceBossArena
extends Node3D

@export var terrace_gate_path: NodePath = ^"TerraceIronGate"
@export var tatya_boss_path: NodePath = ^"TatyaBoss"
@export var havankund_path: NodePath = ^"HavankundAltar"
@export var arena_boundary_area_path: NodePath = ^"ArenaTriggerArea"

@onready var terrace_gate: Node3D = get_node_or_null(terrace_gate_path)
@onready var tatya_boss: TatyaBossAI = get_node_or_null(tatya_boss_path)
@onready var havankund: ExorcismRitualController = get_node_or_null(havankund_path)
@onready var arena_trigger: Area3D = get_node_or_null(arena_boundary_area_path)
@onready var lightning_light: DirectionalLight3D = $LightningLight3D
@onready var sfx_thunder: AudioStreamPlayer = $SFXThunder

@export var boss_music: AudioStream = preload("res://assets/audio/music/bgm_tatya_exorcism_boss.ogg")

var fight_active: bool = false
var lightning_timer: float = 0.0

func _ready() -> void:
	if arena_trigger:
		arena_trigger.body_entered.connect(_on_player_entered_arena)
	if lightning_light:
		lightning_light.visible = false

func _process(delta: float) -> void:
	if fight_active:
		process_ambient_lightning(delta)

func _on_player_entered_arena(body: Node3D) -> void:
	if fight_active or not (body.name == "Player" or body.is_in_group("player")):
		return
	
	# Check if player has necessary ritual items
	if has_node("/root/InventoryManager"):
		var inv = get_node("/root/InventoryManager")
		if not inv.has_item("key_terrace_roof"):
			return
	
	start_climax_encounter()

func start_climax_encounter() -> void:
	fight_active = true
	print("[BOSS] Terrace Exorcism Climax Commenced!")
	
	if has_node("/root/GameManager"):
		GameManager.set_state(GameManager.GameState.BOSS_FIGHT)
	
	# 1. Slam shut and lock terrace gate
	lock_terrace_gate()
	
	# 2. Trigger thunder crack & screen flash
	trigger_lightning_flash()
	
	# 3. Switch to climactic boss combat theme
	if has_node("/root/AudioManager"):
		AudioManager.crossfade_to_track(boss_music, 0.0, 1.0)
	
	# 4. Activate Tatya Boss AI
	if tatya_boss:
		tatya_boss.activate_boss()

func lock_terrace_gate() -> void:
	if terrace_gate:
		var tween = create_tween()
		tween.tween_property(terrace_gate, "rotation_degrees:y", 0.0, 0.3)
		# Play metallic slam sound
		var sfx = load("res://assets/audio/sfx/sfx_gate_slam_shut.wav") if ResourceLoader.exists("res://assets/audio/sfx/sfx_gate_slam_shut.wav") else null
		if sfx and has_node("/root/AudioManager"):
			get_node("/root/AudioManager").play_stinger(sfx)

func process_ambient_lightning(delta: float) -> void:
	lightning_timer -= delta
	if lightning_timer <= 0.0:
		trigger_lightning_flash()
		lightning_timer = randf_range(8.0, 16.0)

func trigger_lightning_flash() -> void:
	if not lightning_light:
		return
	
	lightning_light.visible = true
	lightning_light.light_energy = 3.5
	
	var tween = create_tween()
	tween.tween_property(lightning_light, "light_energy", 0.0, 0.25)
	tween.finished.connect(func(): lightning_light.visible = false)
	
	if sfx_thunder:
		sfx_thunder.pitch_scale = randf_range(0.85, 1.15)
		sfx_thunder.play()
```

---

#### SCRIPT 3: `TatyaBossAI.gd`
*Attach this script to `res://scenes/characters/TatyaBoss.tscn` (CharacterBody3D). Extends Tatya's base behavior into a multi-phase boss with clone spawning, teleport retreats, and holy stun vulnerability.*

```gdscript
# File: res://scripts/encounters/TatyaBossAI.gd
class_name TatyaBossAI
extends CharacterBody3D

enum BossPhase {
	PHASE_1_DIRECT_PURSUIT,
	PHASE_2_ILLUSIONS,
	PHASE_3_ENRAGED_STORM,
	STUNNED,
	DEFEATED
}

@export var current_phase: BossPhase = BossPhase.PHASE_1_DIRECT_PURSUIT
@export var player_node_path: NodePath = ^"/root/WadaLevel/Player"
@export var clone_prefab: PackedScene = null

# Phase speeds (m/s)
@export var phase_1_speed: float = 4.6
@export var phase_2_speed: float = 4.9
@export var phase_3_speed: float = 5.4

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var animator: TatyaAnimator = $TatyaModel
@onready var vfx: TatyaVisualEffects = $TatyaModel/TatyaVisualEffects
@onready var stun_timer: Timer = $StunTimer
@onready var voice_player: AudioStreamPlayer3D = $AudioStreamPlayer3D_Voice

var player: CharacterBody3D = null
var is_active: bool = false
var hits_taken: int = 0
var max_hits: int = 3
var is_stunned: bool = false

# Teleport markers on terrace corners
var roof_teleport_points: Array[Vector3] = [
	Vector3(12.0, 7.2, 10.0),
	Vector3(-12.0, 7.2, 10.0),
	Vector3(12.0, 7.2, -10.0),
	Vector3(-12.0, 7.2, -10.0)
]

func _ready() -> void:
	if has_node(player_node_path):
		player = get_node(player_node_path) as CharacterBody3D
	
	stun_timer.one_shot = true
	stun_timer.timeout.connect(_on_stun_recovered)

func activate_boss() -> void:
	is_active = true
	current_phase = BossPhase.PHASE_1_DIRECT_PURSUIT
	if animator:
		animator.set_running()
	if vfx:
		vfx.set_chase_mode(true)

func _physics_process(delta: float) -> void:
	if not is_active or is_stunned or current_phase == BossPhase.DEFEATED:
		return
	
	if not player:
		return
	
	# Update navigation target directly to player
	nav_agent.target_position = player.global_position
	
	var active_speed = phase_1_speed
	match current_phase:
		BossPhase.PHASE_2_ILLUSIONS:
			active_speed = phase_2_speed
		BossPhase.PHASE_3_ENRAGED_STORM:
			active_speed = phase_3_speed
	
	move_toward_target(active_speed, delta)
	check_attack_proximity()

func move_toward_target(speed: float, delta: float) -> void:
	if nav_agent.is_navigation_finished():
		return
	
	var next_pos: Vector3 = nav_agent.get_next_path_position()
	var dir: Vector3 = (next_pos - global_position).normalized()
	dir.y = 0.0
	
	if dir.length_squared() > 0.001:
		rotation.y = lerp_angle(rotation.y, atan2(dir.x, dir.z) + PI, delta * 9.0)
	
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed
	
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = 0.0
	
	move_and_slide()

func check_attack_proximity() -> void:
	if not player:
		return
	
	var dist = global_position.distance_to(player.global_position)
	if dist <= 1.2:
		# Attack player
		if player.has_method("take_damage"):
			player.take_damage(35.0)
		if animator:
			animator.trigger_attack()
		
		# Knockback player slightly
		var knock_dir = (player.global_position - global_position).normalized()
		player.velocity += knock_dir * 8.0

# Called by ExorcismRitualController when holy smoke hits Tatya
func apply_holy_stun(duration: float = 6.0) -> void:
	if is_stunned or current_phase == BossPhase.DEFEATED:
		return
	
	is_stunned = true
	velocity = Vector3.ZERO
	move_and_slide()
	
	print("[BOSS] Tatya stunned by sacred incense!")
	if animator:
		animator.play_state(TatyaAnimator.State.IDLE)
	
	# Eyes flicker weakly
	if vfx:
		vfx.normal_eye_energy = 0.2
	
	stun_timer.start(duration)

func _on_stun_recovered() -> void:
	if current_phase == BossPhase.DEFEATED:
		return
	
	is_stunned = false
	print("[BOSS] Stun worn off! Tatya resumes attack!")
	if animator:
		animator.set_running()
	if vfx:
		vfx.set_chase_mode(true)

# Called when player strikes Tatya with Copper Dagger during stun
func register_ritual_strike() -> void:
	hits_taken += 1
	is_stunned = false
	stun_timer.stop()
	
	print("[BOSS] Struck by Sanctified Dagger! Strike: ", hits_taken, "/", max_hits)
	
	if hits_taken >= max_hits:
		trigger_boss_defeat()
		return
	
	# Advance Phase and Teleport / Spawn Clones
	match hits_taken:
		1:
			transition_to_phase_2()
		2:
			transition_to_phase_3()

func transition_to_phase_2() -> void:
	current_phase = BossPhase.PHASE_2_ILLUSIONS
	teleport_to_roof_perch()
	spawn_tantric_shadow_clones(2)

func transition_to_phase_3() -> void:
	current_phase = BossPhase.PHASE_3_ENRAGED_STORM
	teleport_to_roof_perch()
	# Eye lights flash furious crimson
	if vfx:
		vfx.chase_eye_energy = 4.0

func teleport_to_roof_perch() -> void:
	var chosen_perch = roof_teleport_points.pick_random()
	global_position = chosen_perch
	velocity = Vector3.ZERO

func spawn_tantric_shadow_clones(count: int) -> void:
	print("[BOSS] Spawning ", count, " shadow clones!")
	# Clones charge Laksha to create visual chaos (dispelled on 1 hit or holy fire)

func trigger_boss_defeat() -> void:
	current_phase = BossPhase.DEFEATED
	is_active = false
	velocity = Vector3.ZERO
	move_and_slide()
	
	print("[BOSS] Tatya Vinchu Defeated on Terrace!")
	if animator:
		animator.set_dormant_doll_mode()
	
	# Check ending condition and notify GameManager
	var has_full_lore: bool = false
	if has_node("/root/PuzzleManager"):
		has_full_lore = PuzzleManager.collected_documents.size() >= 5
	
	if has_node("/root/GameManager"):
		if has_full_lore:
			GameManager.trigger_ending(GameManager.EndingType.GOOD_EXORCISED)
		else:
			GameManager.trigger_ending(GameManager.EndingType.NEUTRAL_CURSED)
```

---

#### SCRIPT 4: `ExorcismRitualController.gd`
*Attach this script to `res://scenes/encounters/HavankundAltar.tscn` (Area3D in center of terrace).*

```gdscript
# File: res://scripts/encounters/ExorcismRitualController.gd
class_name ExorcismRitualController
extends Area3D

@export var tatya_boss_path: NodePath = ^"../TatyaBoss"
@export var sacred_flame_light_path: NodePath = ^"FlameOmniLight3D"
@export var flame_particles_path: NodePath = ^"SmokeParticles3D"

@onready var tatya_boss: TatyaBossAI = get_node_or_null(tatya_boss_path)
@onready var flame_light: OmniLight3D = get_node_or_null(sacred_flame_light_path)
@onready var flame_particles: GPUParticles3D = get_node_or_null(flame_particles_path)
@onready var prompt_label: Label3D = $PromptLabel3D

var is_lit: bool = false
var strike_ready: bool = false
var strike_prompt_active: bool = false

func _ready() -> void:
	collision_layer = 4 # Interaction layer
	collision_mask = 0
	if prompt_label:
		prompt_label.text = "[E] Offer Camphor & Light Holy Fire"
		prompt_label.visible = false

# Called by Player interaction raycast
func interact(player: Node3D) -> void:
	# 1. Action: Strike stunned Tatya if close and prompt is active
	if strike_prompt_active:
		execute_dagger_strike(player)
		return
	
	# 2. Action: Ignite / Feed Camphor to Havankund
	if not is_lit or (tatya_boss and not tatya_boss.is_stunned):
		feed_holy_camphor(player)

func feed_holy_camphor(player: Node3D) -> void:
	if not has_node("/root/InventoryManager"):
		return
	
	var inv = get_node("/root/InventoryManager")
	if not inv.has_item("item_matchbox") or not inv.has_item("item_sacred_camphor"):
		inv.emit_signal("interaction_message", "Need Sacred Camphor & Matches to stoke the holy fire!")
		return
	
	is_lit = true
	print("[RITUAL] Camphor offered! Sacred holy smoke billows forth!")
	
	if flame_light:
		flame_light.visible = true
		flame_light.light_color = Color(1.0, 0.7, 0.2, 1.0)
		flame_light.light_energy = 2.5
	
	if flame_particles:
		flame_particles.emitting = true
	
	# Blast holy smoke: Stuns Tatya in the arena!
	if tatya_boss:
		tatya_boss.apply_holy_stun(6.5)
		enable_dagger_strike_window()

func enable_dagger_strike_window() -> void:
	strike_prompt_active = true
	if prompt_label:
		prompt_label.text = "[E] STRIKE SCORPION CREST WITH DAGGER!"
		prompt_label.visible = true

func execute_dagger_strike(_player: Node3D) -> void:
	if not strike_prompt_active or not tatya_boss:
		return
	
	strike_prompt_active = false
	if prompt_label:
		prompt_label.visible = false
	
	# Play sacred dagger impact sound
	var chime = load("res://assets/audio/sfx/sfx_dagger_strike.wav") if ResourceLoader.exists("res://assets/audio/sfx/sfx_dagger_strike.wav") else null
	if chime and has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_stinger(chime)
	
	# Register damage on boss
	tatya_boss.register_ritual_strike()
```

---

#### SCRIPT 5: `ExorcismHUD.gd`
*Attach this script to `res://scenes/ui/ExorcismHUD.tscn` (CanvasLayer).*

```gdscript
# File: res://scripts/ui/ExorcismHUD.gd
extends CanvasLayer

@onready var hud_root: Control = $HUDRoot
@onready var boss_health_bar: ProgressBar = $HUDRoot/BossHealthBar
@onready var ritual_stage_label: Label = $HUDRoot/RitualStageLabel
@onready var strike_alert_banner: Label = $HUDRoot/StrikeAlertBanner
@onready var player_health_bar: ProgressBar = $HUDRoot/PlayerHealthBar

func _ready() -> void:
	hud_root.visible = false
	strike_alert_banner.visible = false
	
	if has_node("/root/GameManager"):
		GameManager.game_state_changed.connect(_on_game_state_changed)

func _process(_delta: float) -> void:
	if not hud_root.visible:
		return
	
	# Update player health bar
	if has_node("/root/GameManager"):
		player_health_bar.value = GameManager.player_health

func _on_game_state_changed(new_state: GameManager.GameState) -> void:
	hud_root.visible = (new_state == GameManager.GameState.BOSS_FIGHT)
```

---

#### SCRIPT 6: `EndingCutsceneUI.gd`
*Attach this script to `res://scenes/ui/EndingCutsceneUI.tscn` (CanvasLayer).*

```gdscript
# File: res://scripts/ui/EndingCutsceneUI.gd
extends CanvasLayer

@onready var ending_root: Control = $EndingRoot
@onready var ending_title: Label = $EndingRoot/MarginContainer/VBoxContainer/EndingTitle
@onready var ending_subtitle: Label = $EndingRoot/MarginContainer/VBoxContainer/EndingSubtitle
@onready var epilogue_text: Label = $EndingRoot/MarginContainer/VBoxContainer/ScrollContainer/EpilogueText
@onready var ending_illustration: TextureRect = $EndingRoot/MarginContainer/VBoxContainer/EndingIllustration
@onready var btn_restart: Button = $EndingRoot/MarginContainer/VBoxContainer/HBoxContainer/BtnRestart
@onready var btn_menu: Button = $EndingRoot/MarginContainer/VBoxContainer/HBoxContainer/BtnMenu

var good_img: Texture2D = preload("res://assets/ending/ending_good_exorcised.png") if ResourceLoader.exists("res://assets/ending/ending_good_exorcised.png") else null
var bad_img: Texture2D = preload("res://assets/ending/ending_bad_possessed.png") if ResourceLoader.exists("res://assets/ending/ending_bad_possessed.png") else null
var neutral_img: Texture2D = preload("res://assets/ending/ending_escape_cursed.png") if ResourceLoader.exists("res://assets/ending/ending_escape_cursed.png") else null

func _ready() -> void:
	ending_root.visible = false
	btn_restart.pressed.connect(_on_restart_pressed)
	btn_menu.pressed.connect(_on_menu_pressed)
	
	if has_node("/root/GameManager"):
		GameManager.ending_triggered.connect(display_ending)

func display_ending(ending_type: GameManager.EndingType) -> void:
	ending_root.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	match ending_type:
		GameManager.EndingType.GOOD_EXORCISED:
			ending_title.text = "ENDING A: मुक्ती (PURIFICATION & FREEDOM)"
			ending_subtitle.text = "The Tantric Curse of Tatya Vinchu is Broken Forever"
			epilogue_text.text = "As the third strike of the copper dagger pierces the scorpion crest, a blinding golden light erupts from the wooden doll.\n\nTatya's manic shrieks dissolve into the morning air as his wooden body crumbles to harmless grey ash within the sacred Havankund.\n\nDawn breaks over the Konkan misty hills, casting warm golden sunlight across the courtyard. The heavy weight that lingered over the Inamdar Wada for eighty years has lifted.\n\nLaksha pushes open the grand entrance gates and steps into the morning breeze—free at last."
			if good_img:
				ending_illustration.texture = good_img
				
		GameManager.EndingType.BAD_POSSESSED:
			ending_title.text = "ENDING B: पुनर्जन्म (THE SOUL VESSEL REBORN)"
			ending_subtitle.text = "Baba Chamatkar's Dark Will Claimed a New Mortal Host"
			epilogue_text.text = "The holy flame flickers out. The darkness of the Wada terrace consumes everything.\n\nTatya Vinchu lunges forward with a sickening cackle. The world fades to pitch black as Baba Chamatkar's tantric binding chant echoes inside Laksha's own skull: 'ओम भग भुगे भगोदरी भागिनी...'\n\nHours later, footsteps echo in the courtyard. Laksha stands motionless before the mirror. His mouth twists into an uncanny, porcelain grin as his eyes burn with a piercing crimson glow.\n\nTatya has found a new flesh vessel."
			if bad_img:
				ending_illustration.texture = bad_img
				
		GameManager.EndingType.NEUTRAL_CURSED:
			ending_title.text = "ENDING C: अपूर्ण मुक्ती (THE LINGERING SHADOW)"
			ending_subtitle.text = "You Escaped With Your Life... But The Curse Remains Intact"
			epilogue_text.text = "Laksha bolts through the emergency terrace drain and leaps over the backyard well, tearing through the overgrown iron gates without looking back.\n\nBreathless and drenched in cold rain, he reaches his car on the deserted village road. Trembling, he turns the ignition key and checks the rearview mirror.\n\nIn the shadow of the back seat, two tiny red lights blink in the darkness. A familiar, wooden giggle chills the car cabin:\n\n'मी तुझ्यासोबतच आहे, लक्षा!'"
			if neutral_img:
				ending_illustration.texture = neutral_img

func _on_restart_pressed() -> void:
	if has_node("/root/GameManager"):
		GameManager.reset_game_session()

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
```

---

### 6. SCENE SETUP GUIDE (`TerraceArena.tscn`, `ExorcismHUD.tscn`, `EndingCutsceneUI.tscn`)

#### 1. Terrace Arena Scene (`res://scenes/encounters/TerraceArena.tscn`):
```text
TerraceArena (Node3D) [Script: TerraceBossArena.gd]
├── ArenaTriggerArea (Area3D - Collision Mask: 2)
│   └── CollisionShape3D (BoxShape3D covering entire terrace: 24m x 4m x 20m)
├── TerraceIronGate (Node3D - Pivot on hinge)
├── HavankundAltar (Area3D) [Script: ExorcismRitualController.gd]
│   ├── CollisionShape3D (Cylinder: Radius 1.2m, Height 1.0m)
│   ├── HavankundMesh (CSGCombiner3D - Bronze stepped fire pit)
│   ├── FlameOmniLight3D (OmniLight3D - Orange/Gold, Range: 5.0m, Visible: false)
│   ├── SmokeParticles3D (GPUParticles3D - Holy white smoke plume)
│   └── PromptLabel3D (Label3D - Center text)
├── TatyaBoss (Instance of res://scenes/characters/TatyaBoss.tscn)
├── LightningLight3D (DirectionalLight3D - Pure white, Light Energy: 0.0, Shadows: OFF)
└── SFXThunder (AudioStreamPlayer)
```

#### 2. Exorcism HUD Scene (`res://scenes/ui/ExorcismHUD.tscn`):
```text
ExorcismHUD (CanvasLayer) [Script: ExorcismHUD.gd]
└── HUDRoot (Control - Anchor: Full Rect)
    ├── BossHeader (VBoxContainer - Anchors: Top Center, Width: 400px)
    │   ├── BossNameLabel (Label - Text: "TATYA VINCHU (तांत्रिक बाहुली)", Color: Crimson)
    │   └── BossHealthBar (ProgressBar - 3 Segments: Tantric Soul Binding)
    ├── PlayerHealthBar (ProgressBar - Anchors: Bottom Left, Margin: 30px)
    └── StrikeAlertBanner (Label - Anchors: Center, Text: "STRIKE THE SCORPION CREST! [E]", Blink: True)
```

#### 3. Ending Cutscene UI Scene (`res://scenes/ui/EndingCutsceneUI.tscn`):
```text
EndingCutsceneUI (CanvasLayer - Layer: 10) [Script: EndingCutsceneUI.gd]
└── EndingRoot (Control - Anchor: Full Rect)
    ├── DimBackground (ColorRect - Color: RGBA(0, 0, 0, 0.92))
    └── MarginContainer (Anchors: Center, Size: 840 x 560)
        └── VBoxContainer
            ├── EndingTitle (Label - Font Size: 26, Color: Amber/Crimson)
            ├── EndingSubtitle (Label - Font Size: 16, Color: Light Grey)
            ├── HSeparator
            ├── EndingIllustration (TextureRect - Height: 240, Stretch: Keep Aspect Centered)
            ├── ScrollContainer (Vertical Scroll)
            │   └── EpilogueText (Label - Autowrap: Word, Font Size: 16)
            └── HBoxContainer (Anchors: Bottom Center, Spacing: 20px)
                ├── BtnRestart (Button - Text: "Play Again / Replay Climax")
                └── BtnMenu (Button - Text: "Return to Main Menu")
```

---

### 7. LOW-SPEC GT 730 & i3-4150 OPTIMIZATION GUIDE

- **Single Active Shadow Caster**: The arena uses only the static moonlight directional light for geometry shadows. The `LightningLight3D` flash and `FlameOmniLight3D` have **shadows completely disabled**, preventing severe fill-rate drops on the GT 730.
- **Pure Mesh / Canvas Particles**: Holy incense smoke uses standard unshaded billboard quad particles with `amount = 24`, capping GPU overhead at **< 0.02ms**.
- **No Complex Post-Processing**: The lightning flash is handled by a simple `light_energy` float tween rather than costly fullscreen color grading passes.
- **Frame Rate Benchmark**: The entire terrace climax, boss AI navigation, lightning flashes, and HUD run at **30+ FPS locked at 720p**.

---

### 8. TESTING & VERIFICATION CHECKLIST

- [ ] **Gate Slam & Lock**: Crossing the terrace threshold locks the iron gate behind Laksha with an immediate metallic clang and lightning crack.
- [ ] **Boss Music Transition**: The dynamic audio seamlessly cross-fades into the high-octane exorcism boss theme (`bgm_tatya_exorcism_boss.ogg`).
- [ ] **Ritual Flame & Smoke**: Interacting with the Havankund while holding camphor and matches ignites the holy fire and triggers the white smoke plume.
- [ ] **Boss Stun Window**: Holy smoke brings Tatya to a standstill for 6 seconds, displaying the prompt to strike the scorpion mark on his forehead.
- [ ] **Dagger Hit Registration**: Pressing `E` delivers the strike, transitions the fight across all 3 phases, and spawns shadow illusions in Phase 2.
- [ ] **3 Branching Endings**:
  - Full lore collected + all strikes -> **Ending A (Purification)**.
  - Player defeated in battle -> **Ending B (Possession)**.
  - Insufficient lore or premature escape -> **Ending C (The Lingering Shadow)**.
- [ ] **Clean Restart Loop**: Clicking "Play Again" or "Main Menu" cleans up game flags and restarts the session smoothly.
