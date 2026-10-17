extends Node
## SFX pool on the SFX bus, looping music on the Music bus, sliders on Master/Music/SFX.

const SAVE_PATH := "user://audio.json"
const MUSIC_GAIN_DB := 8.0
const COMBAT_DUCK_DB := -2.5

var music: AudioStreamPlayer
var _pool: Array[AudioStreamPlayer] = []
var _i: int = 0
var _streams: Dictionary = {}
var _last_hover_ms: int = 0
var master_lin: float = 1.0
var music_lin: float = 0.85
var sfx_lin: float = 1.0
var _title_bed: AudioStream
var _combat_bed: AudioStream
var _combat_on: bool = false
var _vol_tw: Tween


func setup() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_layout()
	_load_save()
	music = AudioStreamPlayer.new()
	music.bus = "Music"
	music.volume_db = MUSIC_GAIN_DB
	add_child(music)
	for _n in range(8):
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_pool.append(p)
	_bind("click", "res://assets/audio/click.wav")
	_bind("click2", "res://assets/audio/click2.wav")
	_bind("hover", "res://assets/audio/hover.wav")
	_bind("select", "res://assets/audio/select.wav")
	_bind("confirm", "res://assets/audio/confirm.wav")
	_bind("confirm_big", "res://assets/audio/confirm_big.wav")
	_bind("error", "res://assets/audio/error.wav")
	_bind("error_big", "res://assets/audio/error_big.wav")
	_bind("drop", "res://assets/audio/drop.wav")
	_bind("open", "res://assets/audio/open.wav")
	_bind("whoosh", "res://assets/audio/whoosh.wav")
	_bind("land", "res://assets/audio/land.wav")
	_bind("switch", "res://assets/audio/switch.wav")
	_bind("scratch", "res://assets/audio/scratch.wav")
	_bind("pluck", "res://assets/audio/pluck.wav")
	_bind("bong", "res://assets/audio/bong.wav")
	_bind("question", "res://assets/audio/question.wav")
	_bind("glass", "res://assets/audio/glass.wav")
	_bind("bleed", "res://assets/audio/bleed.wav")
	_bind("hit", "res://assets/audio/hit.ogg")
	_bind("chop", "res://assets/audio/chop.ogg")
	_bind("block", "res://assets/audio/block.ogg")
	_bind("block_heavy", "res://assets/audio/block_heavy.ogg")
	_bind("draw", "res://assets/audio/draw.ogg")
	_bind("cloth", "res://assets/audio/cloth.ogg")
	_bind("door_open", "res://assets/audio/door_open.ogg")
	_bind("door_close", "res://assets/audio/door_close.ogg")
	_bind("door_slam", "res://assets/audio/door_slam.ogg")
	_bind("metal_latch", "res://assets/audio/metal_latch.ogg")
	_bind("creak", "res://assets/audio/creak.ogg")
	_bind("book", "res://assets/audio/book.ogg")
	_title_bed = _load_stream("res://assets/audio/music.ogg")
	if _title_bed != null and _title_bed is AudioStreamOggVorbis:
		(_title_bed as AudioStreamOggVorbis).loop = true
	_combat_bed = _load_stream("res://assets/audio/music_combat.ogg")
	if _combat_bed != null and _combat_bed is AudioStreamOggVorbis:
		(_combat_bed as AudioStreamOggVorbis).loop = true
	if _title_bed != null:
		music.stream = _title_bed
	apply_levels()


func _ensure_layout() -> void:
	for n in ["Music", "Stings", "Ambience", "SFX", "UI"]:
		_ensure_bus(str(n))
	_ensure_master_limiter()
	_ensure_music_duck()
	_ensure_ambience_lpf()
	_ensure_sfx_compressor()


func _ensure_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) >= 0:
		return
	var idx: int = AudioServer.bus_count
	AudioServer.add_bus(idx)
	AudioServer.set_bus_name(idx, bus_name)
	AudioServer.set_bus_send(idx, "Master")


func _bus_has_effect(bus_name: String, script_class: String) -> bool:
	var idx: int = AudioServer.get_bus_index(bus_name)
	if idx < 0:
		return false
	for i in AudioServer.get_bus_effect_count(idx):
		var fx := AudioServer.get_bus_effect(idx, i)
		if fx != null and fx.get_class() == script_class:
			return true
	return false


func _ensure_master_limiter() -> void:
	if _bus_has_effect("Master", "AudioEffectHardLimiter"):
		return
	var idx: int = AudioServer.get_bus_index("Master")
	if idx < 0:
		return
	var lim := AudioEffectHardLimiter.new()
	lim.ceiling_db = -1.0
	lim.pre_gain_db = 0.0
	lim.release = 0.1
	AudioServer.add_bus_effect(idx, lim, 0)


func _ensure_music_duck() -> void:
	if _bus_has_effect("Music", "AudioEffectAmplify"):
		return
	var idx: int = AudioServer.get_bus_index("Music")
	if idx < 0:
		return
	var amp := AudioEffectAmplify.new()
	amp.resource_name = "Duck"
	amp.volume_db = 0.0
	AudioServer.add_bus_effect(idx, amp, 0)


func _ensure_ambience_lpf() -> void:
	if _bus_has_effect("Ambience", "AudioEffectLowPassFilter"):
		return
	var idx: int = AudioServer.get_bus_index("Ambience")
	if idx < 0:
		return
	var lpf := AudioEffectLowPassFilter.new()
	lpf.cutoff_hz = 20000.0
	AudioServer.add_bus_effect(idx, lpf, 0)


func _ensure_sfx_compressor() -> void:
	if _bus_has_effect("SFX", "AudioEffectCompressor"):
		return
	var idx: int = AudioServer.get_bus_index("SFX")
	if idx < 0:
		return
	var comp := AudioEffectCompressor.new()
	comp.threshold = -14.0
	comp.ratio = 3.0
	comp.attack_us = 5000.0
	comp.release_ms = 120.0
	comp.gain = 0.0
	AudioServer.add_bus_effect(idx, comp, 0)


func _bind(id: String, path: String) -> void:
	var s: AudioStream = _load_stream(path)
	if s != null:
		_streams[id] = s


func _load_stream(path: String) -> AudioStream:
	if ResourceLoader.exists(path):
		return load(path) as AudioStream
	return null


func play(id: String, db: float = -6.0, pitch: float = 1.0) -> void:
	if not _streams.has(id) or _pool.is_empty():
		return
	var p: AudioStreamPlayer = _pool[_i]
	_i = (_i + 1) % _pool.size()
	p.stream = _streams[id]
	p.volume_db = db
	p.pitch_scale = clampf(pitch, 0.7, 1.4)
	p.play()


func hover() -> void:
	var now: int = Time.get_ticks_msec()
	if now - _last_hover_ms < 90:
		return
	_last_hover_ms = now
	play("hover", -18.0, 1.05)


func start_music(_db: float = 0.0) -> void:
	if music == null:
		return
	_combat_on = false
	if _title_bed != null:
		music.stream = _title_bed
	if music.stream == null:
		return
	if _vol_tw != null:
		_vol_tw.kill()
	music.volume_db = MUSIC_GAIN_DB
	apply_levels()
	if not music.playing:
		music.play()


func set_combat_music(on: bool) -> void:
	if _combat_on == on:
		return
	_combat_on = on
	if _combat_bed != null and _title_bed != null and music != null:
		music.stream = _combat_bed if on else _title_bed
		music.volume_db = MUSIC_GAIN_DB
		apply_levels()
		music.play()
		return
	duck_music(COMBAT_DUCK_DB if on else 0.0)


func duck_music(db: float) -> void:
	if music == null:
		return
	if _vol_tw != null:
		_vol_tw.kill()
	_vol_tw = create_tween()
	_vol_tw.tween_property(music, "volume_db", MUSIC_GAIN_DB + db, 0.35)


func stop_music() -> void:
	if music != null and music.playing:
		var tw := create_tween()
		tw.tween_property(music, "volume_db", -40.0, 0.5)
		tw.tween_callback(music.stop)


func set_master(lin: float) -> void:
	master_lin = clampf(lin, 0.0, 1.0)
	apply_levels()
	_save()


func set_music(lin: float) -> void:
	music_lin = clampf(lin, 0.0, 1.0)
	apply_levels()
	_save()


func set_sfx(lin: float) -> void:
	sfx_lin = clampf(lin, 0.0, 1.0)
	apply_levels()
	_save()


func apply_levels() -> void:
	_set_bus("Master", master_lin)
	_set_bus("Music", music_lin)
	_set_bus("SFX", sfx_lin)


func _set_bus(bus_name: String, lin: float) -> void:
	var idx: int = AudioServer.get_bus_index(bus_name)
	if idx < 0:
		return
	AudioServer.set_bus_mute(idx, lin <= 0.001)
	if lin <= 0.001:
		AudioServer.set_bus_volume_db(idx, -80.0)
	else:
		AudioServer.set_bus_volume_db(idx, linear_to_db(lin))


func _load_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var d: Dictionary = parsed
	master_lin = clampf(float(d.get("master", 1.0)), 0.0, 1.0)
	music_lin = clampf(float(d.get("music", 0.85)), 0.0, 1.0)
	sfx_lin = clampf(float(d.get("sfx", 1.0)), 0.0, 1.0)


func _save() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify({
		"master": master_lin,
		"music": music_lin,
		"sfx": sfx_lin,
	}))
