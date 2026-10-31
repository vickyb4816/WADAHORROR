# PROJECT: WADA HORROR – TATYA VINCHU
## TECHNICAL DESIGN & IMPLEMENTATION MANUAL: STEP 8 (MARATHI HORROR VOICE, SFX, 3D SPATIAL AUDIO & DYNAMIC MUSIC SYSTEM)
**Engine**: Godot 4.2+ / 4.3 (Standard 64-bit)  
**Renderer / Platform Target**: `gl_compatibility` (Targeting i3-4150 + GT 730 @ 720p 30 FPS)  
**Hardware & Audio Budget**: 4 Global Audio Buses, Max 16 simultaneous active audio channels, linear distance culling (`ATTENUATION_INVERSE_DISTANCE`), lightweight cross-fading tween music player (0 runtime memory allocation).

---

### TABLE OF CONTENTS
1. [Audio Architecture Overview & Horror Soundscape](#1-audio-architecture)
2. [Folder Structure for Audio Assets & Scripts](#2-folder-structure)
3. [Audio Bus Layout Specification (`default_bus_layout.tres`)](#3-bus-layout)
4. [Sound Registry: Dialogue, SFX, Chase Stingers & Wada Ambiance](#4-sound-registry)
5. [Complete Production Scripts](#5-complete-scripts)
   - `AudioManager.gd` (Master Autoload: Dynamic Music Cross-Fade, 2D Global Stingers, Voice Priority)
   - `TatyaVoiceController.gd` (3D Spatial Positional Dialogue, Marathi Taunts & Cackle Emitter)
   - `PlayerFootstepAudio.gd` (Surface-aware 3D Footstep Player for Laksha)
6. [Dynamic Chase Music System (Exploration vs Chase Transition)](#6-dynamic-music-system)
7. [Low-End GT 730 & i3-4150 Audio Optimization Guide](#7-optimization-guide)
8. [Step-by-Step Godot Editor Integration Guide](#8-editor-integration)
9. [Testing & Verification Checklist](#9-verification-checklist)

---

### 1. AUDIO ARCHITECTURE OVERVIEW & HORROR SOUNDSCAPE

In survival horror, **sound is 50% of the terror**. For *Wada Horror – Tatya Vinchu*, the audio design mirrors classic Indian haunted folklore and atmospheric horror games (*Alien: Isolation*, *Resident Evil 7*, *Phasmophobia*):

- **Authentic Marathi Horror Voice Lines**:
  - Iconic, spine-chilling dialogue ("लक्षा! कुठे लपलास?", "ओम भग भुगे भगोदरी भागिनी...", "मी पुन्हा आलोय!").
  - Three distinct vocal categories: **Idle/Stalking Whispers**, **Alert/Detection Shouts**, and **Chase Taunts & Manic Laughs**.
  - 3D spatial positional attenuation: Laksha hears Tatya's muffled giggles and wooden joint clicks through adjacent room walls and above from the wooden ceiling gallery.
- **Surface-Aware Material Footsteps**:
  - Distinct sounds depending on where Laksha or Tatya walks:
    - Antique Teakwood Floorboards (creaking, hollow resonance).
    - Stone / Flagstone Tiles (Verandah, Courtyard, Kitchen).
    - Terracotta Clay Roof Tiles (dry, brittle scraping sound).
- **Dynamic 2-State Music System**:
  - **Exploration Ambience**: Deep low-frequency drone (sub-bass), howling Konkan midnight wind, distant crickets, and occasional unsettling sitar/tanpura dissonant chords.
  - **Chase Stinger & High-Octane Pursuit**: Sudden sharp brass/percussion impact transitioning instantly into fast-paced rhythmic Indian folk percussion (dhol/ghungroo rattle with industrial tension drums).
- **Heartbeat & Tension Feedback**:
  - Proximity-based heartbeat sound that grows louder and faster as Tatya approaches Laksha's hiding cupboard or crouched location.

---

### 2. FOLDER STRUCTURE FOR AUDIO ASSETS & SCRIPTS

Create the following directory layout in your Godot project filesystem (`res://`):

```text
res://
├── assets/
│   └── audio/
│       ├── voice/
│       │   ├── tatya/
│       │   │   ├── tatya_om_bhag_whisper.ogg     ("Om Bhag Bheeghe Bhagodari...")
│       │   │   ├── tatya_chuckle_01.ogg           (Creepy short puppet snicker)
│       │   │   ├── tatya_chuckle_02.ogg           (Mischievous doll chuckle)
│       │   │   ├── tatya_chase_kuthe_laplas.ogg   ("लक्षा! कुठे लपलास?")
│       │   │   ├── tatya_chase_aata_nahi_sodnar.ogg("आता नाही सोडणार तुला!")
│       │   │   ├── tatya_laugh_manic.ogg          (Full deranged puppet laugh)
│       │   │   └── tatya_attack_jumpscare.ogg     (Violent shrieking lunge)
│       │   └── laksha/
│       │       ├── laksha_gasp.ogg                (Sudden fright inhalation)
│       │       └── laksha_breath_heavy.ogg        (Exhausted hiding breathing)
│       ├── music/
│       │   ├── bgm_wada_exploration.ogg           (Looping eerie midnight ambience)
│       │   ├── bgm_tatya_chase.ogg                (Fast rhythmic Maharashtrian chase theme)
│       │   └── stinger_detected.ogg               (Violent brass/metal horror screech)
│       ├── sfx/
│       │   ├── footsteps/
│       │   │   ├── step_wood_01.wav to 04.wav     (Creaky upper floor planks)
│       │   │   ├── step_stone_01.wav to 04.wav    (Courtyard & verandah stone)
│       │   │   ├── step_roof_01.wav to 03.wav     (Terracotta roof scraping)
│       │   │   └── step_doll_click_01.wav to 04.wav (Tatya's wooden doll foot clicks)
│       │   ├── environment/
│       │   │   ├── sfx_wada_wind_exterior.ogg
│       │   │   ├── sfx_creaking_beam.wav
│       │   │   ├── sfx_tulsi_wind_bells.wav
│       │   │   └── sfx_clock_ticking_slow.wav
│       │   └── gameplay/
│       │       ├── sfx_heartbeat_loop.ogg         (Low pulsing tension heartbeat)
│       │       ├── sfx_cupboard_creak_in.wav
│       │       ├── sfx_cupboard_creak_out.wav
│       │       └── sfx_key_jingle.wav
├── scripts/
│   ├── autoload/
│   │   └── AudioManager.gd                        (Autoload: Music & Global 2D FX)
│   ├── characters/
│   │   └── TatyaVoiceController.gd                (3D Spatial Marathi Audio)
│   └── player/
│       └── PlayerFootstepAudio.gd                 (Surface detection footstep hook)
└── default_bus_layout.tres                        (Master, Music, SFX, Voice buses)
```

---

### 3. AUDIO BUS LAYOUT SPECIFICATION (`default_bus_layout.tres`)

Godot’s Audio Buses allow independent volume mixing and horror audio processing (e.g. reverb in the courtyard or low-pass filtering while hiding inside a cupboard):

| Bus Name | Master / Parent | Volume (dB) | Effects Added | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| **Master** | Audio Device | `0.0 dB` | None | Final output to speakers/headphones |
| **Music** | Master | `-4.0 dB` | `AudioEffectLowPassFilter` (Toggled when hidden) | Ambient background music & Chase track |
| **SFX** | Master | `0.0 dB` | None | Doors, footsteps, items, heartbeats |
| **Voice** | Master | `+2.0 dB` | `AudioEffectReverb` (Subtle 15% wet Wada echo) | Marathi lines, chants, laughs |

---

### 4. SOUND REGISTRY: DIALOGUE, SFX & MUSIC

Mapping directly to your game references:

| Trigger Event | Sound File | Bus | 2D / 3D | Description |
| :--- | :--- | :--- | :--- | :--- |
| **Tatya Patrolling (Unseen)** | `tatya_om_bhag_whisper.ogg` | Voice | **3D** | Low rhythmic recitation of the tantric chant. Max distance: 18m. |
| **Tatya Spotting Laksha** | `stinger_detected.ogg` + `tatya_chuckle_01.ogg` | Master / Voice | **2D + 3D** | Sharp terrifying musical stinger followed by spatial chuckle. |
| **Chase Commenced** | `tatya_chase_kuthe_laplas.ogg` | Voice | **3D** | "लक्षा! कुठे लपलास?" (Where are you hiding, Laksha?). |
| **Chase Music Active** | `bgm_tatya_chase.ogg` | Music | **2D** | Heart-pounding dhol / industrial thriller chase music. |
| **Laksha Inside Cupboard** | `sfx_heartbeat_loop.ogg` | SFX | **2D** | Volume scales linearly as Tatya gets closer to the wardrobe. |
| **Tatya Wooden Steps** | `step_doll_click_01.wav` | SFX | **3D** | Rapid wooden tap-tap-tap footsteps at 4.2 m/s. |
| **Courtyard Ambient** | `sfx_wada_wind_exterior.ogg` | SFX | **3D** | Soft night wind rustling through the open courtyard sky. |

---

### 5. COMPLETE PRODUCTION SCRIPTS

#### SCRIPT 1: `AudioManager.gd` (Autoload / Global Singleton)
*Go to **Project -> Project Settings -> Globals -> Autoload**, add `res://scripts/autoload/AudioManager.gd` as `AudioManager`.*  
*Manages dynamic cross-fading between Wada ambient exploration music and high-tension Tatya chase music, plays 2D horror stingers, and handles cupboard muffled audio filtering.*

```gdscript
# File: res://scripts/autoload/AudioManager.gd
extends Node

signal chase_music_started
signal chase_music_ended

# Master audio streams
@export var music_exploration: AudioStream = preload("res://assets/audio/music/bgm_wada_exploration.ogg")
@export var music_chase: AudioStream = preload("res://assets/audio/music/bgm_tatya_chase.ogg")
@export var stinger_detect: AudioStream = preload("res://assets/audio/music/stinger_detected.ogg")
@export var sfx_heartbeat: AudioStream = preload("res://assets/audio/gameplay/sfx_heartbeat_loop.ogg")

var player_music_a: AudioStreamPlayer
var player_music_b: AudioStreamPlayer
var player_stinger: AudioStreamPlayer
var player_heartbeat: AudioStreamPlayer

var current_music_player: AudioStreamPlayer
var is_in_chase: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS # Keeps playing if game paused
	
	# 1. Setup dual music players for seamless cross-fades
	player_music_a = AudioStreamPlayer.new()
	player_music_a.bus = "Music"
	add_child(player_music_a)
	
	player_music_b = AudioStreamPlayer.new()
	player_music_b.bus = "Music"
	add_child(player_music_b)
	
	# 2. Setup Stinger and Heartbeat players
	player_stinger = AudioStreamPlayer.new()
	player_stinger.bus = "SFX"
	add_child(player_stinger)
	
	player_heartbeat = AudioStreamPlayer.new()
	player_heartbeat.bus = "SFX"
	player_heartbeat.stream = sfx_heartbeat
	player_heartbeat.volume_db = -80.0
	add_child(player_heartbeat)
	
	current_music_player = player_music_a
	play_exploration_music()

# ----------------- MUSIC STATE CONTROLLER -----------------
func play_exploration_music(fade_duration: float = 2.0) -> void:
	if not is_in_chase and current_music_player.stream == music_exploration and current_music_player.playing:
		return
	
	is_in_chase = false
	crossfade_to_track(music_exploration, -6.0, fade_duration)
	emit_signal("chase_music_ended")

func play_chase_music(fade_duration: float = 0.5) -> void:
	if is_in_chase:
		return
	
	is_in_chase = true
	# Play immediate shock stinger
	play_stinger(stinger_detect)
	# Crossfade into rapid chase percussion
	crossfade_to_track(music_chase, -2.0, fade_duration)
	emit_signal("chase_music_started")

func crossfade_to_track(new_stream: AudioStream, target_db: float, duration: float) -> void:
	if not new_stream:
		return
	
	var outgoing_player = current_music_player
	var incoming_player = player_music_b if outgoing_player == player_music_a else player_music_a
	
	incoming_player.stream = new_stream
	incoming_player.volume_db = -45.0
	incoming_player.play()
	
	var tween = create_tween()
	tween.set_parallel(true)
	# Fade out current
	tween.tween_property(outgoing_player, "volume_db", -45.0, duration)
	# Fade in new
	tween.tween_property(incoming_player, "volume_db", target_db, duration)
	
	tween.finished.connect(func():
		outgoing_player.stop()
		current_music_player = incoming_player
	)

# ----------------- HORROR STINGERS & HEARTBEAT -----------------
func play_stinger(stream: AudioStream) -> void:
	if stream:
		player_stinger.stream = stream
		player_stinger.play()

# Called continuously by Player when Tatya is near Laksha's hiding spot
func update_heartbeat_proximity(distance: float, max_range: float = 12.0) -> void:
	if distance > max_range:
		if player_heartbeat.playing and player_heartbeat.volume_db <= -40.0:
			player_heartbeat.stop()
		return
	
	if not player_heartbeat.playing:
		player_heartbeat.play()
	
	# Closer distance = Louder volume (-30dB to 0dB)
	var t: float = clamp(1.0 - (distance / max_range), 0.0, 1.0)
	var target_volume: float = lerp(-32.0, 2.0, t)
	player_heartbeat.volume_db = target_volume
	# Pitch increases with terror
	player_heartbeat.pitch_scale = lerp(0.85, 1.35, t)

func stop_heartbeat() -> void:
	if player_heartbeat.playing:
		var tween = create_tween()
		tween.tween_property(player_heartbeat, "volume_db", -60.0, 1.0)
		tween.finished.connect(func(): player_heartbeat.stop())

# Apply low-pass filter effect when Laksha closes cupboard door
func set_hiding_audio_muffled(is_muffled: bool) -> void:
	var master_bus_idx = AudioServer.get_bus_index("Master")
	# If low-pass effect exists on Master bus, toggle bypass
	for i in range(AudioServer.get_bus_effect_count(master_bus_idx)):
		var effect = AudioServer.get_bus_effect(master_bus_idx, i)
		if effect is AudioEffectLowPassFilter:
			AudioServer.set_bus_effect_enabled(master_bus_idx, i, is_muffled)
```

---

#### SCRIPT 2: `TatyaVoiceController.gd`
*Attach this script to a child node `TatyaVoiceController` inside `TatyaEnemy.tscn` (or `TatyaModel.tscn`). It controls spatial Marathi dialogues, whispering during patrol, and shrieks during chases.*

```gdscript
# File: res://scripts/characters/TatyaVoiceController.gd
class_name TatyaVoiceController
extends Node3D

@export var voice_player_path: NodePath = ^"VoicePlayer3D"
@onready var voice_player: AudioStreamPlayer3D = get_node_or_null(voice_player_path)

# Voice Audio Clips
var clips_patrol_chants: Array[AudioStream] = [
	preload("res://assets/audio/voice/tatya/tatya_om_bhag_whisper.ogg"),
	preload("res://assets/audio/voice/tatya/tatya_chuckle_01.ogg"),
	preload("res://assets/audio/voice/tatya/tatya_chuckle_02.ogg")
]

var clips_chase_taunts: Array[AudioStream] = [
	preload("res://assets/audio/voice/tatya/tatya_chase_kuthe_laplas.ogg"),
	preload("res://assets/audio/voice/tatya/tatya_chase_aata_nahi_sodnar.ogg"),
	preload("res://assets/audio/voice/tatya/tatya_laugh_manic.ogg")
]

var clip_jumpscare: AudioStream = preload("res://assets/audio/voice/tatya/tatya_attack_jumpscare.ogg")

@export var min_speech_interval: float = 6.0
@export var max_speech_interval: float = 14.0

var speech_timer: float = 0.0
var current_enemy: TatyaAI = null

func _ready() -> void:
	if not voice_player:
		voice_player = AudioStreamPlayer3D.new()
		add_child(voice_player)
	
	# Configure 3D Spatial Attenuation for low-end GT 730
	voice_player.bus = "Voice"
	voice_player.unit_size = 3.0
	voice_player.max_distance = 18.0
	voice_player.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
	
	current_enemy = get_parent() as TatyaAI
	reset_speech_timer()

func _process(delta: float) -> void:
	if not current_enemy:
		return
	
	# Don't speak while already speaking or when dormant
	if voice_player.playing or current_enemy.current_state == TatyaAI.AIState.DORMANT:
		return
	
	speech_timer -= delta
	if speech_timer <= 0.0:
		trigger_context_voice()
		reset_speech_timer()

func reset_speech_timer() -> void:
	# Speaks more frequently when chasing Laksha!
	if current_enemy and current_enemy.current_state == TatyaAI.AIState.CHASE:
		speech_timer = randf_range(3.0, 6.0)
	else:
		speech_timer = randf_range(min_speech_interval, max_speech_interval)

func trigger_context_voice() -> void:
	if not current_enemy:
		return
	
	match current_enemy.current_state:
		TatyaAI.AIState.PATROL, TatyaAI.AIState.INVESTIGATE, TatyaAI.AIState.SEARCH_LOST:
			play_random_clip(clips_patrol_chants)
		TatyaAI.AIState.CHASE:
			play_random_clip(clips_chase_taunts)

func play_random_clip(clip_array: Array[AudioStream]) -> void:
	if clip_array.is_empty():
		return
	
	var chosen = clip_array.pick_random()
	if chosen:
		voice_player.stream = chosen
		voice_player.pitch_scale = randf_range(0.95, 1.05) # Random pitch variation
		voice_player.play()

# Called when Tatya initiates lunge attack
func play_jumpscare_shriek() -> void:
	if clip_jumpscare:
		voice_player.stop()
		voice_player.stream = clip_jumpscare
		voice_player.pitch_scale = 1.0
		voice_player.play()
```

---

#### SCRIPT 3: `PlayerFootstepAudio.gd`
*Attach this script to `Player.tscn`. It performs downward raycasts to identify whether Laksha is stepping on wooden gallery boards, courtyard stone, or rooftop terracotta, playing accurate footstep sounds and informing Tatya's hearing AI.*

```gdscript
# File: res://scripts/player/PlayerFootstepAudio.gd
class_name PlayerFootstepAudio
extends Node3D

@export var floor_raycast_path: NodePath = ^"FloorRayCast"
@onready var floor_ray: RayCast3D = get_node_or_null(floor_raycast_path)

# Footstep Audio Collections
@export var wood_steps: Array[AudioStream] = []
@export var stone_steps: Array[AudioStream] = []
@export var roof_steps: Array[AudioStream] = []

@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

var step_timer: float = 0.0
var parent_player: CharacterBody3D = null

func _ready() -> void:
	parent_player = get_parent() as CharacterBody3D
	if not audio_player:
		audio_player = AudioStreamPlayer3D.new()
		add_child(audio_player)
	
	audio_player.bus = "SFX"
	audio_player.max_distance = 16.0
	audio_player.unit_size = 2.0

func _physics_process(delta: float) -> void:
	if not parent_player or not parent_player.is_on_floor():
		return
	
	var speed = parent_player.velocity.length()
	if speed < 0.2:
		step_timer = 0.0
		return
	
	# Step cadence: faster when sprinting, slower when crouched
	var is_sprinting = parent_player.get("is_sprinting") if "is_sprinting" in parent_player else false
	var is_crouching = parent_player.get("is_crouching") if "is_crouching" in parent_player else false
	
	var step_interval: float = 0.55
	if is_sprinting:
		step_interval = 0.32
	elif is_crouching:
		step_interval = 0.75
	
	step_timer += delta
	if step_timer >= step_interval:
		play_footstep(is_sprinting, is_crouching)
		step_timer = 0.0

func play_footstep(is_sprinting: bool, is_crouching: bool) -> void:
	# Crouching is completely silent
	if is_crouching:
		return
	
	var surface_type: String = detect_surface()
	var selected_stream: AudioStream = null
	
	match surface_type:
		"wood":
			selected_stream = wood_steps.pick_random() if wood_steps.size() > 0 else null
		"roof":
			selected_stream = roof_steps.pick_random() if roof_steps.size() > 0 else null
		_: # Default stone
			selected_stream = stone_steps.pick_random() if stone_steps.size() > 0 else null
	
	if selected_stream:
		audio_player.stream = selected_stream
		audio_player.pitch_scale = randf_range(0.9, 1.1)
		audio_player.volume_db = 2.0 if is_sprinting else -4.0
		audio_player.play()
	
	# Alert Tatya AI hearing system
	var noise_range: float = 14.0 if is_sprinting else 4.0
	emit_sound_to_tatya(global_position, noise_range)

func detect_surface() -> String:
	if not floor_ray:
		return "stone"
	
	floor_ray.force_raycast_update()
	if floor_ray.is_colliding():
		var collider = floor_ray.get_collider()
		if collider:
			var node_name = collider.name.to_lower()
			if "wood" in node_name or "gallery" in node_name or "plank" in node_name:
				return "wood"
			elif "roof" in node_name or "tile" in node_name or "terrace" in node_name:
				return "roof"
	return "stone"

func emit_sound_to_tatya(sound_pos: Vector3, noise_radius: float) -> void:
	# Broadcast to all active Tatya AI nodes in tree
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		if enemy.has_method("hear_noise"):
			enemy.hear_noise(sound_pos, noise_radius)
```

---

### 6. DYNAMIC CHASE MUSIC SYSTEM (INTEGRATION HOOKS)

Connect Step 7 `TatyaAI.gd` directly with Step 8 `AudioManager.gd`:

#### In `TatyaAI.gd`:
1. When entering `AIState.CHASE`:
   ```gdscript
   func trigger_chase() -> void:
       # ... [Existing VFX / speed changes from Step 7] ...
       if has_node("/root/AudioManager"):
           AudioManager.play_chase_music()
   ```
2. When losing sight or returning to patrol:
   ```gdscript
   func lose_player_target() -> void:
       # ... [Existing search timer logic] ...
       if has_node("/root/AudioManager"):
           AudioManager.play_exploration_music()
   ```
3. When Laksha is hiding in a cupboard and Tatya walks past:
   ```gdscript
   func process_search(delta: float) -> void:
       # ... [Existing code] ...
       if player and has_node("/root/AudioManager"):
           var dist = global_position.distance_to(player.global_position)
           AudioManager.update_heartbeat_proximity(dist, 10.0)
   ```

---

### 7. LOW-END GT 730 & i3-4150 AUDIO OPTIMIZATION GUIDE

Audio processing can consume significant CPU if spatial audio isn't culled properly on an older dual-core i3:

1. **Compressed OGG Vorbis for Long Audio**:
   - Save all ambient loops, dialogue lines, and music tracks as `.ogg` (Vorbis). In Godot Inspector, set **Loop Mode = Forward** and enable **Compress (RAM)**.
2. **Short WAV for Micro SFX**:
   - Keep footstep clicks, key jingles, and cupboard creaks as 16-bit 44.1kHz mono `.wav` for zero decompression CPU overhead.
3. **Strict Spatial Max Distance**:
   - In all `AudioStreamPlayer3D` nodes (Tatya's voice, footsteps), keep `max_distance` set between `14.0m` and `18.0m`.
   - Set `attenuation_model = ATTENUATION_INVERSE_DISTANCE`. When Tatya is on the other floor beyond 18 meters, Godot completely stops mixing his 3D voice channel, reducing CPU usage to 0%.
4. **Cap Active Polyphony**:
   - Limit `max_polyphony = 2` on all local sound players to prevent sound stacking when spamming footsteps or interactions.

---

### 8. STEP-BY-STEP GODOT EDITOR INTEGRATION GUIDE

1. **Create the Audio Buses**:
   - At the bottom of the Godot editor, click the **Audio** dock.
   - Click **Add Bus** 3 times to create: `Music`, `SFX`, and `Voice`.
   - On the `Master` bus, click **Add Effect** -> `AudioEffectLowPassFilter` (set Cutoff Hz to `800 Hz`, disabled by default).
   - On the `Voice` bus, click **Add Effect** -> `AudioEffectReverb` (set Room Size: `0.3`, Wet: `0.15`).
   - Save the layout as `res://default_bus_layout.tres`.
2. **Register AudioManager Autoload**:
   - Open **Project -> Project Settings -> Globals -> Autoload**.
   - Browse to `res://scripts/autoload/AudioManager.gd`.
   - Node Name: `AudioManager`. Click **Add**.
3. **Attach Voice Controller to Tatya**:
   - Open `TatyaEnemy.tscn`.
   - Add a child `Node3D` named `TatyaVoiceController`.
   - Attach `TatyaVoiceController.gd`.
   - Add an `AudioStreamPlayer3D` named `VoicePlayer3D` as its child.
4. **Attach Footsteps to Player**:
   - Open `Player.tscn`.
   - Add a child `Node3D` named `PlayerFootstepAudio`.
   - Attach `PlayerFootstepAudio.gd`.
   - Add a `RayCast3D` pointing down (`target_position = Vector3(0, -1.2, 0)`).
5. **Test in Editor (Press F5)**:
   - Walk through the Verandah: notice crisp stone footsteps.
   - Enter the upper gallery: listen to hollow creaking wooden planks.
   - Let Tatya spot you: hear the terrifying horror stinger followed by *"लक्षा! कुठे लपलास?"* and rapid chase music!
   - Dive into the nearest wardrobe: the music muffles and Laksha's heartbeat starts pulsing in your ears as Tatya searches outside!

---

### 9. TESTING & VERIFICATION CHECKLIST

- [ ] **Bus Routing**: Tatya's voice routes to `Voice`, chase music routes to `Music`, footsteps route to `SFX`.
- [ ] **Distance Culling**: Moving more than 18m away from Tatya smoothly fades out his whispered chants.
- [ ] **Cross-fade Smoothness**: Transition from exploration to chase music and back takes place without clipping, pops, or stutters.
- [ ] **Cupboard Muffling**: Stepping into a wardrobe engages the low-pass filter, giving an authentic claustrophobic muffled sound.
- [ ] **Heartbeat Proximity**: Walking Tatya past Laksha's hiding place raises the heartbeat volume and tempo in real time.
- [ ] **CPU Benchmark on i3-4150**: Entire audio system introduces **< 0.1ms frame time**, leaving maximum CPU headroom for 30+ FPS gameplay.
