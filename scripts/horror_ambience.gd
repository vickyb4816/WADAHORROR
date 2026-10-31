extends Node

const SAMPLE_RATE := 22050.0
const CHUNK_SIZE := 512
var player: AudioStreamPlayer
var playback: AudioStreamGeneratorPlayback
var phase := 0.0
var elapsed := 0.0

func _ready() -> void:
    player = AudioStreamPlayer.new()
    var generator := AudioStreamGenerator.new()
    generator.mix_rate = SAMPLE_RATE
    generator.buffer_length = 0.6
    player.stream = generator
    player.volume_db = -17.0
    add_child(player)
    player.play()
    playback = player.get_stream_playback() as AudioStreamGeneratorPlayback

func _process(delta: float) -> void:
    if playback == null:
        return
    elapsed += delta
    var frames := playback.get_frames_available()
    var count := mini(frames, CHUNK_SIZE)
    for i in range(count):
        var drone := sin(phase * TAU * 47.0 / SAMPLE_RATE) * 0.10
        var overtone := sin(phase * TAU * 49.5 / SAMPLE_RATE) * 0.055
        var pulse := 0.72 + 0.28 * sin(elapsed * 0.72)
        var distant := sin(phase * TAU * 73.0 / SAMPLE_RATE) * 0.018
        var sample := (drone + overtone + distant) * pulse
        playback.push_frame(Vector2(sample, sample))
        phase += 1.0
