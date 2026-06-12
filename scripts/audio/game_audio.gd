extends Node

const MIX_RATE := 44100.0
const MUSIC_VOLUME_DB := -24.0
const SFX_VOLUME_DB := -8.0

# Slow C-major elevator loop (~68 BPM eighth notes).
const MELODY := [
	{"note": 130.8, "dur": 0.44}, {"note": 164.8, "dur": 0.44},
	{"note": 196.0, "dur": 0.44}, {"note": 164.8, "dur": 0.44},
	{"note": 196.0, "dur": 0.44}, {"note": 246.9, "dur": 0.44},
	{"note": 293.7, "dur": 0.44}, {"note": 246.9, "dur": 0.44},
	{"note": 220.0, "dur": 0.44}, {"note": 164.8, "dur": 0.44},
	{"note": 196.0, "dur": 0.66}, {"note": 174.6, "dur": 0.88},
]
const BASS := [
	65.4, 65.4, 65.4, 65.4,
	98.0, 98.0, 98.0, 98.0,
	110.0, 110.0, 110.0, 110.0,
]
const PAD := [
	130.8, 130.8, 130.8, 130.8,
	196.0, 196.0, 196.0, 196.0,
	220.0, 220.0, 220.0, 220.0,
]

var _music_player: AudioStreamPlayer
var _music_playback: AudioStreamGeneratorPlayback
var _music_playing: bool = false
var _melody_idx: int = 0
var _melody_phase: float = 0.0
var _melody_elapsed: float = 0.0
var _melody_env: float = 1.0
var _bass_idx: int = 0
var _bass_phase: float = 0.0
var _bass_elapsed: float = 0.0
var _pad_idx: int = 0
var _pad_phase: float = 0.0
var _pad_elapsed: float = 0.0
var _hit_cooldown: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(delta: float) -> void:
	_hit_cooldown = maxf(0.0, _hit_cooldown - delta)
	if _music_playing and _music_playback != null:
		_fill_music_buffer()


func start_music() -> void:
	if _music_playing:
		return
	_music_player = AudioStreamPlayer.new()
	_music_player.name = "MusicPlayer"
	_music_player.volume_db = MUSIC_VOLUME_DB
	_music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = MIX_RATE
	stream.buffer_length = 0.5
	_music_player.stream = stream
	add_child(_music_player)
	_music_player.play()
	_music_playback = _music_player.get_stream_playback() as AudioStreamGeneratorPlayback
	_melody_idx = 0
	_melody_phase = 0.0
	_melody_elapsed = 0.0
	_melody_env = 1.0
	_bass_idx = 0
	_bass_phase = 0.0
	_bass_elapsed = 0.0
	_pad_idx = 0
	_pad_phase = 0.0
	_pad_elapsed = 0.0
	_music_playing = true


func stop_music() -> void:
	_music_playing = false
	if _music_player != null and is_instance_valid(_music_player):
		_music_player.stop()
		_music_player.queue_free()
	_music_player = null
	_music_playback = null


func play_xp_pickup() -> void:
	_play_tone(880.0, 0.07, 0.22, SFX_VOLUME_DB - 2.0)


func play_donut_pickup() -> void:
	_play_tone(392.0, 0.08, 0.25, SFX_VOLUME_DB - 2.0)
	_delayed_tone(523.0, 0.1, 0.28, SFX_VOLUME_DB - 2.0, 0.06)
	_delayed_tone(659.0, 0.14, 0.3, SFX_VOLUME_DB - 2.0, 0.12)


func play_printer_jam() -> void:
	_play_tone(180.0, 0.12, 0.35, SFX_VOLUME_DB)
	_delayed_tone(90.0, 0.25, 0.4, SFX_VOLUME_DB - 2.0, 0.08)


func play_event_sting() -> void:
	_play_tone(440.0, 0.1, 0.3, SFX_VOLUME_DB - 4.0)
	_delayed_tone(660.0, 0.15, 0.35, SFX_VOLUME_DB - 4.0, 0.06)


func play_boss_spawn() -> void:
	_play_tone(110.0, 0.18, 0.45, SFX_VOLUME_DB - 2.0)
	_delayed_tone(82.0, 0.28, 0.5, SFX_VOLUME_DB - 2.0, 0.1)
	_delayed_tone(55.0, 0.35, 0.55, SFX_VOLUME_DB - 2.0, 0.22)


func play_level_up() -> void:
	_play_tone(523.0, 0.1, 0.28, SFX_VOLUME_DB - 2.0)
	_delayed_tone(659.0, 0.12, 0.3, SFX_VOLUME_DB - 2.0, 0.08)
	_delayed_tone(784.0, 0.18, 0.35, SFX_VOLUME_DB - 2.0, 0.16)


func play_weapon_fire() -> void:
	_play_tone(620.0, 0.025, 0.08, SFX_VOLUME_DB - 14.0, true)


func play_enemy_hit() -> void:
	if _hit_cooldown > 0.0:
		return
	_hit_cooldown = 0.04
	_play_tone(280.0, 0.03, 0.06, SFX_VOLUME_DB - 16.0, true)


func _fill_music_buffer() -> void:
	var frames_available := _music_playback.get_frames_available()
	while frames_available > 0:
		var sample := _next_music_sample()
		_music_playback.push_frame(Vector2(sample, sample))
		frames_available -= 1


func _next_music_sample() -> float:
	var step := 1.0 / MIX_RATE
	var melody_note: Dictionary = MELODY[_melody_idx]
	var melody_freq: float = melody_note.note
	var bass_freq: float = BASS[_bass_idx]
	var pad_freq: float = PAD[_pad_idx]

	_melody_elapsed += step
	if _melody_elapsed >= melody_note.dur:
		_melody_elapsed = 0.0
		_melody_idx = (_melody_idx + 1) % MELODY.size()
		melody_note = MELODY[_melody_idx]
		melody_freq = melody_note.note
		_melody_env = 0.0

	_bass_elapsed += step
	var bass_dur: float = MELODY[_melody_idx].dur
	if _bass_elapsed >= bass_dur:
		_bass_elapsed = 0.0
		_bass_idx = (_bass_idx + 1) % BASS.size()
		bass_freq = BASS[_bass_idx]

	_pad_elapsed += step
	if _pad_elapsed >= bass_dur:
		_pad_elapsed = 0.0
		_pad_idx = (_pad_idx + 1) % PAD.size()
		pad_freq = PAD[_pad_idx]

	_melody_env = minf(1.0, _melody_env + step * 18.0)

	var melody_inc := melody_freq / MIX_RATE
	var bass_inc := bass_freq / MIX_RATE
	var pad_inc := pad_freq / MIX_RATE
	var melody_wave := _triangle_wave(_melody_phase) * 0.038 * _melody_env
	var bass_wave := _sine_wave(_bass_phase) * 0.028
	var pad_wave := _sine_wave(_pad_phase) * 0.012
	_melody_phase += melody_inc
	if _melody_phase >= 1.0:
		_melody_phase -= 1.0
	_bass_phase += bass_inc
	if _bass_phase >= 1.0:
		_bass_phase -= 1.0
	_pad_phase += pad_inc
	if _pad_phase >= 1.0:
		_pad_phase -= 1.0
	return clampf(melody_wave + bass_wave + pad_wave, -1.0, 1.0)


func _sine_wave(phase: float) -> float:
	return sin(phase * TAU)


func _triangle_wave(phase: float) -> float:
	if phase < 0.25:
		return phase * 4.0
	if phase < 0.75:
		return 2.0 - phase * 4.0
	return phase * 4.0 - 4.0


func _delayed_tone(freq: float, duration: float, volume: float, volume_db: float, delay: float) -> void:
	var timer := get_tree().create_timer(delay, true, false, true)
	timer.timeout.connect(func(): _play_tone(freq, duration, volume, volume_db))


func _play_tone(freq: float, duration: float, volume: float, volume_db: float, square: bool = false) -> void:
	var player := AudioStreamPlayer.new()
	player.volume_db = volume_db
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = MIX_RATE
	stream.buffer_length = duration + 0.05
	player.stream = stream
	add_child(player)
	player.play()
	var playback := player.get_stream_playback() as AudioStreamGeneratorPlayback
	if playback == null:
		player.queue_free()
		return
	var increment := freq / MIX_RATE
	var phase := 0.0
	var frame_count := int(MIX_RATE * duration)
	for i in frame_count:
		var env := 1.0 - float(i) / float(frame_count)
		var sample: float
		if square:
			sample = (1.0 if phase < 0.5 else -1.0) * volume * env
		else:
			sample = sin(phase * TAU) * volume * env
		playback.push_frame(Vector2(sample, sample))
		phase += increment
		if phase >= 1.0:
			phase -= 1.0
	player.finished.connect(player.queue_free)
