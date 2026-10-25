extends Node
## Event-driven audio: 16-voice pool, A/B music, map-driven cues. Existing play() stays valid.

const SAVE_PATH := "user://audio.json"
const MAP_PATH := "res://data/sfx-map.json"
const LEGACY_UI_IDS := ["hover", "click", "click2", "select", "question", "error", "switch", "confirm", "confirm_big"]
const LOOP_FILES := ["music_combat", "music_deadly", "music_cabin", "cabin_fire_loop", "cabin_cat_purr_loop", "music", "music_intro", "music_ending", "music_station_inn", "music_station_rag", "music_station_harp"]
const AUDIO_LOG_CAP := 80

var music: AudioStreamPlayer
var master_lin: float = 1.0
var music_lin: float = 0.85
var ambience_lin: float = 0.8
var sfx_lin: float = 1.0
var ui_lin: float = 0.9
var music_state: StringName = &"boot"
var cutscene_autoplay: bool = true

var _map: Dictionary = {}
var _cues: Dictionary = {}
var _cue_streams: Dictionary = {}
var _streams: Dictionary = {}
var _last_file: Dictionary = {}
var _last_fired_ms: Dictionary = {}
var _pool: Array[AudioStreamPlayer] = []
var _voice_meta: Array[Dictionary] = []
var _tick: AudioStreamPlayer
var _speech: AudioStreamPlayer
var _sting: AudioStreamPlayer
var _music_a: AudioStreamPlayer
var _music_b: AudioStreamPlayer
var _music_front: int = 0
var _loop_players: Dictionary = {}
var _beds: Dictionary = {}
var _bed_pos: Dictionary = {}
var _current_bed: StringName = &""
var _last_hover_ms: int = 0
var session_log
var _last_tick_ms: int = 0
var _unlocked: bool = false
var _duck_tw: Tween
var _xfade_tw: Tween
var _lpf_tw: Tween
var _pause_duck: float = 0.0
var _between_duck: float = 0.0
var _speech_duck: float = 0.0
var _cue_duck: float = 0.0
var _speech_last_file: String = ""
var _speech_chars: int = 0
var _speech_kind: StringName = &""
var _speech_end_timer: SceneTreeTimer
var _victory_timer: SceneTreeTimer
var _prefix_bus: Dictionary = {}
var _defaults: Dictionary = {}
var _deadly_pitch: Dictionary = {}
var _wheel_ticks: Dictionary = {}
var _speech_rules: Dictionary = {}
var _music_cfg: Dictionary = {}
var audio_log: Array = []
var _watch_s: float = 0.0
var _last_logged_playing: bool = false


func setup() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process_input(true)
	set_process(true)
	_ensure_layout()
	_load_map()
	_load_save()
	_build_players()
	_bind_legacy()
	_load_beds()
	apply_levels()
	_hook_music_finished()
	_hook_web_audio()
	log_audio("setup", "boot")


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


func _load_map() -> void:
	if not FileAccess.file_exists(MAP_PATH):
		push_warning("AudioFx: missing %s" % MAP_PATH)
		return
	var f := FileAccess.open(MAP_PATH, FileAccess.READ)
	if f == null:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("AudioFx: sfx-map.json is not a dictionary")
		return
	_map = parsed
	_cues = _map.get("cues", {})
	_prefix_bus = _map.get("prefix_bus", {})
	_defaults = _map.get("defaults", {"bus": "SFX", "db": -8, "pitch": [0.97, 1.03], "cooldown_ms": 0, "max_voices": 4, "priority": 1})
	_deadly_pitch = _map.get("deadly_sting_pitch", {})
	_wheel_ticks = _map.get("wheel_ticks", {})
	_speech_rules = _map.get("speech", {})
	_music_cfg = _map.get("music", {})
	var prefix: String = str(_map.get("path_prefix", "res://assets/audio/"))
	for cue_id in _cues.keys():
		var cue: Dictionary = _cues[cue_id]
		if typeof(cue) != TYPE_DICTIONARY:
			continue
		var arr: Array[AudioStream] = []
		for name in cue.get("files", []):
			var stem: String = str(name)
			var stream := _load_named(prefix, stem)
			if stream == null:
				push_warning("AudioFx: missing file for cue %s (%s)" % [str(cue_id), stem])
				continue
			_maybe_loop(stream, stem, bool(cue.get("loop", false)))
			arr.append(stream)
		_cue_streams[str(cue_id)] = arr


func _load_named(prefix: String, stem: String) -> AudioStream:
	var ogg: String = prefix + stem + ".ogg"
	var wav: String = prefix + stem + ".wav"
	if ResourceLoader.exists(ogg):
		return _load_stream(ogg)
	if ResourceLoader.exists(wav):
		return _load_stream(wav)
	return null


func _maybe_loop(stream: AudioStream, stem: String, cue_loop: bool) -> void:
	if stream is AudioStreamOggVorbis and (cue_loop or stem in LOOP_FILES):
		(stream as AudioStreamOggVorbis).loop = true


func _build_players() -> void:
	var pool_n: int = int(_map.get("voice_pool", {}).get("sfx_players", 16))
	for _n in range(pool_n):
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		p.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(p)
		_pool.append(p)
		_voice_meta.append({"cue_id": "", "priority": 0, "started_ms": 0})
	_tick = AudioStreamPlayer.new()
	_tick.bus = "UI"
	_tick.max_polyphony = int(_map.get("voice_pool", {}).get("tick_player_polyphony", 3))
	_tick.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_tick)
	_speech = AudioStreamPlayer.new()
	_speech.bus = "UI"
	_speech.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_speech)
	_sting = AudioStreamPlayer.new()
	_sting.bus = "Stings"
	_sting.max_polyphony = 2
	_sting.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_sting)
	_music_a = AudioStreamPlayer.new()
	_music_a.name = "MusicA"
	_music_a.bus = "Music"
	_music_a.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_music_a)
	_music_b = AudioStreamPlayer.new()
	_music_b.name = "MusicB"
	_music_b.bus = "Music"
	_music_b.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_music_b)
	music = _music_a
	for cue_id in ["amb.fire", "amb.cat_purr", "amb.radio_static"]:
		var lp := AudioStreamPlayer.new()
		lp.bus = "Ambience"
		lp.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(lp)
		_loop_players[cue_id] = lp


func _bind_legacy() -> void:
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


func _load_beds() -> void:
	var beds: Dictionary = _music_cfg.get("beds", {})
	var prefix: String = str(_map.get("path_prefix", "res://assets/audio/"))
	for bed_id in beds.keys():
		if str(bed_id).begins_with("_"):
			continue
		var spec: Dictionary = beds[bed_id]
		var stream := _load_named(prefix, str(spec.get("file", "")))
		if stream == null:
			push_warning("AudioFx: missing music bed %s" % str(bed_id))
			continue
		_maybe_loop(stream, str(spec.get("file", "")), true)
		_beds[str(bed_id)] = {"stream": stream, "gain_db": float(spec.get("gain_db", 0.0)), "resume": bool(spec.get("resume_position", false))}
	if _beds.has("title"):
		_music_a.stream = _beds["title"]["stream"]
		_music_a.volume_db = float(_beds["title"]["gain_db"])
		music = _music_a
		_current_bed = &"title"


func _bind(id: String, path: String) -> void:
	var s: AudioStream = _load_stream(path)
	if s != null:
		_streams[id] = s


func _load_stream(path: String) -> AudioStream:
	if ResourceLoader.exists(path):
		return load(path) as AudioStream
	return null


func set_session_log(log) -> void:
	session_log = log


func play(id: String, db: float = -6.0, pitch: float = 1.0) -> void:
	if session_log:
		session_log.push("audio", "start %s" % id)
	if not _streams.has(id) or _pool.is_empty():
		return
	var p := _acquire_voice(&"legacy", 1, 8)
	if p == null:
		return
	p.stream = _streams[id]
	p.bus = _legacy_bus(id)
	p.volume_db = db
	p.pitch_scale = clampf(pitch, 0.7, 1.4)
	p.play()


func _legacy_bus(id: String) -> String:
	if id in LEGACY_UI_IDS:
		return "UI"
	for prefix in _prefix_bus.keys():
		if id.begins_with(str(prefix)):
			return str(_prefix_bus[prefix])
	return "SFX"


func hover() -> void:
	var now: int = Time.get_ticks_msec()
	if now - _last_hover_ms < 90:
		return
	_last_hover_ms = now
	play("hover", -18.0, 1.05)


func play_event(cue_id: StringName, ctx: Dictionary = {}) -> void:
	if session_log:
		session_log.push("audio", "start %s" % String(cue_id))
	_play_event_inner(cue_id, ctx, 0)


func _play_event_inner(cue_id: StringName, ctx: Dictionary, depth: int) -> void:
	if depth > 4:
		return
	var id: String = String(cue_id)
	if id == "" or not _cues.has(id):
		return
	var delay_ms: float = float(ctx.get("delay_ms", 0))
	if delay_ms > 0.0:
		var delayed: Dictionary = ctx.duplicate()
		delayed["delay_ms"] = 0
		_after_ms(delay_ms, func() -> void: _play_event_inner(cue_id, delayed, depth))
		return
	var cue: Dictionary = _cues[id]
	var now: int = Time.get_ticks_msec()
	var cooldown: int = int(cue.get("cooldown_ms", _defaults.get("cooldown_ms", 0)))
	if cooldown > 0 and now - int(_last_fired_ms.get(id, -999999)) < cooldown:
		return
	_last_fired_ms[id] = now
	var files: Array = _cue_streams.get(id, [])
	if not files.is_empty():
		_play_cue_voice(id, cue, ctx, files)
	var layers: Array = cue.get("layers", [])
	for layer in layers:
		if typeof(layer) != TYPE_DICTIONARY:
			continue
		var layer_ctx: Dictionary = ctx.duplicate()
		layer_ctx["db_offset"] = float(ctx.get("db_offset", 0.0)) + float(layer.get("db_offset", 0.0))
		layer_ctx["delay_ms"] = float(layer.get("delay_ms", 0))
		_play_event_inner(StringName(str(layer.get("cue", ""))), layer_ctx, depth + 1)
	var repeat: Variant = cue.get("repeat", null)
	if typeof(repeat) == TYPE_DICTIONARY and not bool(ctx.get("_from_repeat", false)):
		var count: int = int(repeat.get("count", 0))
		var interval: float = float(repeat.get("interval_ms", 0))
		for n in range(1, count):
			var rctx: Dictionary = ctx.duplicate()
			rctx["delay_ms"] = interval * float(n)
			rctx["_from_repeat"] = true
			_play_event_inner(cue_id, rctx, depth + 1)
	if not bool(ctx.get("_from_repeat", false)):
		_apply_cue_duck(cue)
		_apply_cue_music(id, str(cue.get("music", "")))
		var loop_id: String = str(cue.get("loop_start", ""))
		if loop_id != "":
			loop_start(StringName(loop_id), 1.5)


func _play_cue_voice(id: String, cue: Dictionary, ctx: Dictionary, files: Array) -> void:
	if bool(cue.get("loop", false)) and _loop_players.has(id):
		loop_start(StringName(id), 0.15)
		return
	var stream: AudioStream = _pick_stream(id, files)
	if stream == null:
		return
	var bus: String = str(ctx.get("bus", cue.get("bus", _defaults.get("bus", "SFX"))))
	var db: float = float(cue.get("db", _defaults.get("db", -8))) + float(ctx.get("db_offset", 0.0))
	var pitch: float = _cue_pitch(cue) * float(ctx.get("pitch_mul", 1.0))
	pitch = clampf(pitch, 0.5, 2.0)
	var prio: int = int(cue.get("priority", _defaults.get("priority", 1)))
	var max_v: int = int(cue.get("max_voices", _defaults.get("max_voices", 4)))
	var player: AudioStreamPlayer
	if bus == "Stings":
		player = _sting
	else:
		player = _acquire_voice(StringName(id), prio, max_v)
	if player == null:
		return
	player.stream = stream
	player.bus = bus
	player.volume_db = db
	player.pitch_scale = pitch
	player.play()


func _pick_stream(id: String, files: Array) -> AudioStream:
	if files.is_empty():
		return null
	if files.size() == 1:
		return files[0]
	var last: AudioStream = _last_file.get(id, null)
	var picks: Array = []
	for s in files:
		if s != last:
			picks.append(s)
	if picks.is_empty():
		picks = files
	var chosen: AudioStream = picks[randi() % picks.size()]
	_last_file[id] = chosen
	return chosen


func _cue_pitch(cue: Dictionary) -> float:
	var p: Variant = cue.get("pitch", _defaults.get("pitch", [0.97, 1.03]))
	if typeof(p) == TYPE_ARRAY and p.size() >= 2:
		return randf_range(float(p[0]), float(p[1]))
	return 1.0


func _acquire_voice(cue_id: StringName, priority: int, max_voices: int) -> AudioStreamPlayer:
	var now: int = Time.get_ticks_msec()
	var same: Array[int] = []
	var free: Array[int] = []
	var stealable: Array[int] = []
	for i in _pool.size():
		var p: AudioStreamPlayer = _pool[i]
		var meta: Dictionary = _voice_meta[i]
		if not p.playing:
			free.append(i)
		elif str(meta.get("cue_id", "")) == String(cue_id):
			same.append(i)
		elif int(meta.get("priority", 0)) <= priority:
			stealable.append(i)
	var pick: int = -1
	if same.size() >= max_voices:
		pick = _oldest_index(same)
	elif not free.is_empty():
		pick = free[0]
	elif not stealable.is_empty():
		pick = _oldest_index(stealable)
	if pick < 0:
		return null
	_voice_meta[pick] = {"cue_id": String(cue_id), "priority": priority, "started_ms": now}
	return _pool[pick]


func _oldest_index(idxs: Array[int]) -> int:
	var best: int = idxs[0]
	var oldest: int = int(_voice_meta[best].get("started_ms", 0))
	for i in idxs:
		var t: int = int(_voice_meta[i].get("started_ms", 0))
		if t < oldest:
			oldest = t
			best = i
	return best


func resolve(event: StringName, ctx: Dictionary) -> StringName:
	var ev: String = String(event)
	var lookup: Dictionary = _map.get("lookup", {})
	var chain: Array = _map.get("fallback_chain", [])
	for key in chain:
		var dim: String = str(key)
		var table: Dictionary = lookup.get(dim, {})
		if dim == "default":
			if table.has(ev):
				return StringName(str(table[ev]))
			continue
		if not ctx.has(dim):
			continue
		var ctx_val: String = str(ctx[dim])
		var entry: Variant = _lookup_entry(table, dim, ctx_val)
		if typeof(entry) == TYPE_DICTIONARY:
			var hit: String = _entry_event(entry, ev, ctx)
			if hit != "":
				return StringName(hit)
		if table.has(ev) and typeof(table[ev]) == TYPE_DICTIONARY:
			var by_val: Dictionary = table[ev]
			if by_val.has(ctx_val):
				return StringName(str(by_val[ctx_val]))
	return StringName(ev)


func _lookup_entry(table: Dictionary, dim: String, ctx_val: String) -> Variant:
	if table.has(ctx_val) and typeof(table[ctx_val]) == TYPE_DICTIONARY:
		return table[ctx_val]
	if dim == "ops_kind":
		for k in table.keys():
			var ks: String = str(k)
			if ks.ends_with("*"):
				var prefix: String = ks.substr(0, ks.length() - 1)
				if ctx_val.begins_with(prefix) and typeof(table[k]) == TYPE_DICTIONARY:
					return table[k]
	return null


func _entry_event(entry: Dictionary, ev: String, ctx: Dictionary) -> String:
	if ev == "hit" and entry.has("hit_heavy") and float(ctx.get("dmg", 0)) >= float(entry.get("heavy_threshold", 999)):
		return str(entry["hit_heavy"])
	if ev == "gain" and entry.has("gain_big") and float(ctx.get("n", ctx.get("amount", 0))) >= float(entry.get("big_threshold", 999)):
		return str(entry["gain_big"])
	if entry.has(ev) and typeof(entry[ev]) == TYPE_STRING:
		return str(entry[ev])
	return ""


func tier_of(monster: Dictionary) -> int:
	var t: int = int(monster.get("pack_tier", 0))
	if t < 1:
		t = int(monster.get("tier", 0))
	return maxi(1, t)


func deadly_pitch(monster_id: String) -> float:
	if _deadly_pitch.has(monster_id):
		return float(_deadly_pitch[monster_id])
	return 1.0


func play_tick(speed01: float) -> void:
	var now: int = Time.get_ticks_msec()
	var min_ms: int = int(_wheel_ticks.get("min_interval_ms", 35))
	if now - _last_tick_ms < min_ms:
		return
	_last_tick_ms = now
	var cue_id: String = str(_wheel_ticks.get("cue", "wheel.tick"))
	var files: Array = _cue_streams.get(cue_id, [])
	if files.is_empty() or _tick == null:
		return
	var t: float = clampf(speed01, 0.0, 1.0)
	var pr: Array = _wheel_ticks.get("pitch_from_speed", [0.92, 1.12])
	var dr: Array = _wheel_ticks.get("db_from_speed", [-18, -12])
	_tick.stream = _pick_stream(cue_id, files)
	_tick.bus = "UI"
	_tick.pitch_scale = clampf(lerpf(float(pr[0]), float(pr[1]), t) * randf_range(0.96, 1.04), 0.5, 2.0)
	_tick.volume_db = lerpf(float(dr[0]), float(dr[1]), t)
	_tick.play()


func speak(kind: StringName, text: String, ctx: Dictionary = {}) -> void:
	_speech_kind = kind
	_speech_chars = 0
	var rules: Dictionary = _speech_rules.get(String(kind), {})
	if rules.is_empty():
		return
	_set_speech_duck(float(rules.get("duck_music_db", -3.0)))
	var burst: Array = rules.get("burst_if_no_typewriter", [3, 5])
	var lo: int = int(burst[0])
	var hi: int = int(burst[1]) if burst.size() > 1 else lo
	var n: int = clampi(lo + int(floor(float(text.length()) / 18.0)), lo, hi)
	var iv: Array = rules.get("burst_interval_ms", [70, 110])
	for i in range(n):
		var wait: float = 0.0 if i == 0 else randf_range(float(iv[0]), float(iv[1])) * float(i)
		var last: bool = i == n - 1
		_after_ms(wait, func() -> void: _blip(kind, text, ctx, last))
	_after_ms(float(n) * 140.0 + 200.0, func() -> void: _set_speech_duck(0.0))


func speak_progress(kind: StringName, visible_chars: int, text: String = "", ctx: Dictionary = {}) -> void:
	var rules: Dictionary = _speech_rules.get(String(kind), {})
	if rules.is_empty():
		return
	var step: int = int(rules.get("chars_per_blip", 3))
	if visible_chars < _speech_chars + step:
		return
	_speech_chars = visible_chars
	_set_speech_duck(float(rules.get("duck_music_db", -3.0)))
	var last: bool = text != "" and visible_chars >= text.length()
	_blip(kind, text, ctx, last)
	if last:
		_after_ms(250.0, func() -> void: _set_speech_duck(0.0))


func _blip(kind: StringName, text: String, ctx: Dictionary, last: bool) -> void:
	var rules: Dictionary = _speech_rules.get(String(kind), {})
	var cue_id: String = str(rules.get("cue", "speech.nib"))
	var files: Array = _cue_streams.get(cue_id, [])
	if files.is_empty() or _speech == null:
		return
	var stream: AudioStream = _pick_stream(cue_id, files)
	if stream == _speech.stream and files.size() > 1:
		stream = _pick_stream(cue_id, files)
	var cue: Dictionary = _cues.get(cue_id, {})
	var db: float = float(cue.get("db", -14))
	var pitch: float = _cue_pitch(cue)
	if String(kind) == "nib":
		pitch *= 1.0
	else:
		var by_t: Dictionary = rules.get("pitch_by_tier", {})
		var t: String = str(int(ctx.get("tier", 2)))
		pitch *= float(by_t.get(t, 1.0))
		if str(ctx.get("monster_id", "")) == "cowardly_king":
			pitch *= 1.3
	if last and text.ends_with("?"):
		pitch *= 1.15
	if last and text.ends_with("!"):
		db += 2.0
	_speech.stream = stream
	_speech.bus = "UI"
	_speech.volume_db = db
	_speech.pitch_scale = clampf(pitch, 0.5, 2.0)
	_speech.play()


func _set_speech_duck(db: float) -> void:
	_speech_duck = db
	_mix_duck(0.05)


func loop_start(cue_id: StringName, fade_s: float, db_override: float = INF) -> void:
	var id: String = String(cue_id)
	var player: AudioStreamPlayer = _loop_players.get(id, null)
	if player == null:
		return
	var files: Array = _cue_streams.get(id, [])
	if files.is_empty():
		return
	var cue: Dictionary = _cues.get(id, {})
	var stream: AudioStream = files[0]
	_maybe_loop(stream, "", true)
	player.stream = stream
	player.bus = str(cue.get("bus", "Ambience"))
	player.pitch_scale = 1.0
	var target: float = float(cue.get("db", -10))
	if db_override != INF:
		target = db_override
	if not player.playing:
		player.volume_db = -40.0
		player.play()
	var tw := create_tween()
	tw.set_ignore_time_scale(true)
	tw.tween_property(player, "volume_db", target, maxf(fade_s, 0.01))


func loop_stop(cue_id: StringName, fade_s: float = 0.4) -> void:
	stop_cue_voices(cue_id)
	var player: AudioStreamPlayer = _loop_players.get(String(cue_id), null)
	if player == null or not player.playing:
		return
	var tw := create_tween()
	tw.set_ignore_time_scale(true)
	tw.tween_property(player, "volume_db", -40.0, maxf(fade_s, 0.01))
	tw.tween_callback(player.stop)


func loop_stop_all(fade_s: float) -> void:
	for id in _loop_players.keys():
		loop_stop(StringName(str(id)), fade_s)


func stop_cue_voices(cue_id: StringName) -> void:
	if session_log:
		session_log.push("audio", "stop %s" % String(cue_id))
	var id: String = String(cue_id)
	for i in _pool.size():
		if str(_voice_meta[i].get("cue_id", "")) != id:
			continue
		_pool[i].stop()
		_voice_meta[i] = {"cue_id": "", "priority": 0, "started_ms": 0}


func music_to(bed: StringName, fade_s: float) -> void:
	var id: String = String(bed)
	if id in ["combat", "title", "deadly", "intro"]:
		loop_stop(&"amb.radio_static", 0.25)
	if not _beds.has(id):
		log_audio("skip", "missing_bed", {"bed": id})
		return
	if _current_bed == bed and music != null and music.playing:
		return
	log_audio("start", "music_to", {"bed": id, "fade": fade_s})
	var out_gain: float = 0.0
	if _current_bed != &"" and _beds.has(String(_current_bed)):
		var old_spec: Dictionary = _beds[String(_current_bed)]
		out_gain = float(old_spec.get("gain_db", 0.0))
		if bool(old_spec.get("resume", false)) and music != null:
			_bed_pos[String(_current_bed)] = music.get_playback_position()
	var incoming: AudioStreamPlayer = _music_b if _music_front == 0 else _music_a
	var outgoing: AudioStreamPlayer = _music_a if _music_front == 0 else _music_b
	var spec: Dictionary = _beds[id]
	incoming.stream = spec["stream"]
	incoming.bus = "Music"
	var gain: float = float(spec["gain_db"])
	var start_pos: float = 0.0
	if bool(spec.get("resume", false)):
		start_pos = float(_bed_pos.get(id, 0.0))
	incoming.volume_db = -80.0
	incoming.play(start_pos)
	_music_front = 1 - _music_front
	music = incoming
	_current_bed = bed
	if _xfade_tw != null:
		_xfade_tw.kill()
	var dur: float = maxf(fade_s, 0.01)
	_xfade_tw = create_tween()
	_xfade_tw.set_ignore_time_scale(true)
	_xfade_tw.set_parallel(true)
	_xfade_tw.tween_method(_set_in_lin.bind(incoming, gain), 0.0, 1.0, dur)
	_xfade_tw.tween_method(_set_out_lin.bind(outgoing, out_gain), 0.0, 1.0, dur)
	_xfade_tw.chain().tween_callback(func() -> void:
		if outgoing != incoming:
			outgoing.stop()
	)


func _set_in_lin(t: float, player: AudioStreamPlayer, gain: float) -> void:
	var lin: float = sin(t * PI * 0.5)
	player.volume_db = gain + linear_to_db(maxf(lin, 0.0001))


func _set_out_lin(t: float, player: AudioStreamPlayer, start_db: float) -> void:
	var lin: float = cos(t * PI * 0.5)
	player.volume_db = start_db + linear_to_db(maxf(lin, 0.0001)) - linear_to_db(1.0)


func music_title() -> void:
	music_state = &"title"
	_between_duck = 0.0
	_mix_duck(0.3)
	var fades: Dictionary = _music_cfg.get("crossfade_s", {})
	music_to(&"title", float(fades.get("to_title", 1.2)))


func music_deadly() -> void:
	music_state = &"deadly"
	_between_duck = 0.0
	_mix_duck(0.3)
	var fades: Dictionary = _music_cfg.get("crossfade_s", {})
	music_to(&"deadly", float(fades.get("to_deadly", 0.5)))


func music_cabin() -> void:
	music_state = &"cabin"
	_between_duck = 0.0
	_mix_duck(0.3)
	var fades: Dictionary = _music_cfg.get("crossfade_s", {})
	music_to(&"cabin", float(fades.get("to_cabin", 1.5)))


func music_victory() -> void:
	music_state = &"victory"
	_cue_duck = -30.0
	_mix_duck(0.1)
	_after_ms(2500.0, func() -> void:
		_cue_duck = 0.0
		music_title()
		_mix_duck(2.0)
	)


func music_defeat() -> void:
	music_state = &"defeat"
	_cue_duck = -30.0
	_mix_duck(0.1)
	_after_ms(3000.0, func() -> void:
		_cue_duck = 0.0
		music_title()
		_mix_duck(2.0)
	)


func start_music(_db: float = 0.0) -> void:
	music_title()
	if music != null and not music.playing and _beds.has("title"):
		music.stream = _beds["title"]["stream"]
		music.volume_db = float(_beds["title"]["gain_db"])
		music.play()


func set_combat_music(on: bool) -> void:
	if on:
		if music_state == &"deadly":
			return
		music_state = &"combat"
		_between_duck = 0.0
		_mix_duck(0.3)
		var fades: Dictionary = _music_cfg.get("crossfade_s", {})
		music_to(&"combat", float(fades.get("default", 0.8)))
	else:
		if music_state == &"title" or music_state == &"cabin" or music_state == &"victory" or music_state == &"defeat":
			return
		music_state = &"between"
		_between_duck = float(_music_cfg.get("between_fights_duck_db", -4))
		_mix_duck(0.3)
		if _current_bed != &"combat":
			music_to(&"combat", float(_music_cfg.get("crossfade_s", {}).get("default", 0.8)))


func duck_music(db: float) -> void:
	_cue_duck = db
	_mix_duck(0.35)
	if db >= -0.01:
		_after_ms(50.0, func() -> void:
			_cue_duck = 0.0
			_mix_duck(0.6)
		)


func duck(db: float, attack: float, release_or_hold: Variant) -> void:
	_cue_duck = db
	_mix_duck(attack)
	if typeof(release_or_hold) == TYPE_STRING and str(release_or_hold) == "hold":
		return
	_after_ms(float(release_or_hold) * 1000.0, func() -> void:
		unduck(0.6)
	)


func unduck(release: float) -> void:
	_cue_duck = 0.0
	_mix_duck(release)


func stop_music() -> void:
	log_audio("stop", "stop_music")
	if session_log:
		session_log.push("audio", "stop music")
	_current_bed = &""
	for p in [_music_a, _music_b]:
		if p != null and p.playing:
			var tw := create_tween()
			tw.tween_property(p, "volume_db", -40.0, 0.5)
			tw.tween_callback(p.stop)


func on_pause(open: bool) -> void:
	if open:
		_pause_duck = -6.0
		_mix_duck(0.15)
		_set_ambience_cutoff(1200.0, 0.2)
	else:
		_pause_duck = 0.0
		_mix_duck(0.3)
		_set_ambience_cutoff(20000.0, 0.3)


func _apply_cue_duck(cue: Dictionary) -> void:
	var spec: Variant = cue.get("duck_music", null)
	if typeof(spec) != TYPE_DICTIONARY:
		return
	var db: float = float(spec.get("db", 0.0))
	var attack: float = float(spec.get("attack_s", 0.05))
	var rel: Variant = spec.get("release_s", 0.6)
	duck(db, attack, rel)


func _apply_cue_music(cue_id: String, bed: String) -> void:
	if bed == "":
		return
	match bed:
		"deadly":
			music_deadly()
		"combat":
			if music_state == &"deadly":
				var fades: Dictionary = _music_cfg.get("crossfade_s", {})
				music_state = &"combat"
				_between_duck = 0.0
				_mix_duck(0.3)
				music_to(&"combat", float(fades.get("from_deadly", 1.2)))
			else:
				set_combat_music(true)
		"cabin":
			music_cabin()
		"title":
			music_title()
		"title_after_sting":
			if cue_id.contains("defeat"):
				music_defeat()
			else:
				music_victory()
		"intro":
			music_state = &"intro"
			music_to(&"intro", float(_music_cfg.get("crossfade_s", {}).get("default", 0.8)))
		"ending":
			music_state = &"ending"
			music_to(&"ending", float(_music_cfg.get("crossfade_s", {}).get("default", 0.8)))


func _mix_duck(attack: float) -> void:
	var db: float = minf(0.0, minf(_pause_duck, minf(_between_duck, minf(_speech_duck, _cue_duck))))
	var fx := _duck_fx()
	if fx == null:
		return
	if _duck_tw != null:
		_duck_tw.kill()
	_duck_tw = create_tween()
	_duck_tw.set_ignore_time_scale(true)
	_duck_tw.tween_property(fx, "volume_db", db, maxf(attack, 0.01))


func _duck_fx() -> AudioEffectAmplify:
	var idx: int = AudioServer.get_bus_index("Music")
	if idx < 0:
		return null
	for i in AudioServer.get_bus_effect_count(idx):
		var fx := AudioServer.get_bus_effect(idx, i)
		if fx is AudioEffectAmplify:
			return fx as AudioEffectAmplify
	return null


func _set_ambience_cutoff(hz: float, dur: float) -> void:
	var fx := _ambience_lpf()
	if fx == null:
		return
	if _lpf_tw != null:
		_lpf_tw.kill()
	_lpf_tw = create_tween()
	_lpf_tw.set_ignore_time_scale(true)
	_lpf_tw.tween_property(fx, "cutoff_hz", hz, maxf(dur, 0.01))


func _ambience_lpf() -> AudioEffectLowPassFilter:
	var idx: int = AudioServer.get_bus_index("Ambience")
	if idx < 0:
		return null
	for i in AudioServer.get_bus_effect_count(idx):
		var fx := AudioServer.get_bus_effect(idx, i)
		if fx is AudioEffectLowPassFilter:
			return fx as AudioEffectLowPassFilter
	return null


func _input(event: InputEvent) -> void:
	if _unlocked:
		return
	var press := false
	if event is InputEventMouseButton and event.pressed:
		press = true
	elif event is InputEventKey and event.pressed:
		press = true
	elif event is InputEventScreenTouch and event.pressed:
		press = true
	if not press:
		return
	_unlocked = true
	resume_intended("first_gesture")


func _after_ms(ms: float, cb: Callable) -> void:
	if ms <= 0.0:
		cb.call()
		return
	var t: SceneTreeTimer = get_tree().create_timer(ms / 1000.0, true, true, false)
	t.timeout.connect(cb)


func _process(delta: float) -> void:
	if _current_bed == &"" or music == null:
		_watch_s = 0.0
		return
	if music.playing:
		if not _last_logged_playing:
			_last_logged_playing = true
		_watch_s = 0.0
		return
	_watch_s += delta
	if _watch_s >= 0.45:
		_watch_s = 0.0
		_last_logged_playing = false
		resume_intended("watchdog_silence")


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_IN or what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		resume_intended("focus_in")
	elif what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		log_audio("focus_out", "os")
	elif what == NOTIFICATION_APPLICATION_RESUMED:
		resume_intended("app_resumed")
	elif what == NOTIFICATION_WM_SIZE_CHANGED:
		resume_web_context("size_changed")


func _hook_music_finished() -> void:
	for p in [_music_a, _music_b]:
		if p != null and not p.finished.is_connected(_on_music_finished):
			p.finished.connect(_on_music_finished.bind(p))


func _on_music_finished(player: AudioStreamPlayer) -> void:
	log_audio("stop", "finished", {"player": player.name if player else ""})
	if _current_bed == &"" or music != player:
		return
	resume_intended("stream_finished")


func _hook_web_audio() -> void:
	if not OS.has_feature("web"):
		return
	if not ClassDB.class_exists("JavaScriptBridge"):
		return
	JavaScriptBridge.eval("""
(function(){
  if (window._swipeAudioHooked) return;
  window._swipeAudioHooked = true;
  window._swipeAudioResume = function(){
    var c = null;
    try {
      if (typeof GodotAudio !== 'undefined') {
        c = GodotAudio.ctx || GodotAudio.context || null;
      }
    } catch (e) {}
    if (!c && window.Godot && window.Godot.audioContext) c = window.Godot.audioContext;
    if (c && c.state !== 'running' && c.resume) c.resume();
    return c ? String(c.state) : 'missing';
  };
  var resume = function(){ window._swipeAudioResume(); };
  document.addEventListener('visibilitychange', function(){ if (!document.hidden) resume(); });
  window.addEventListener('focus', resume);
  window.addEventListener('pageshow', resume);
  ['pointerdown','keydown','touchstart'].forEach(function(ev){
    window.addEventListener(ev, resume, true);
  });
  if (navigator.mediaDevices && navigator.mediaDevices.addEventListener) {
    navigator.mediaDevices.addEventListener('devicechange', resume);
  }
})();
""", true)
	log_audio("hook", "web_audiocontext")


func resume_web_context(reason: String) -> String:
	if not OS.has_feature("web"):
		return "native"
	if not ClassDB.class_exists("JavaScriptBridge"):
		return "no_js"
	var state: String = str(JavaScriptBridge.eval("window._swipeAudioResume ? window._swipeAudioResume() : 'nohook'", true))
	log_audio("resume_ctx", reason, {"state": state})
	return state


func resume_intended(reason: String) -> void:
	resume_web_context(reason)
	if _current_bed == &"" or not _beds.has(String(_current_bed)):
		return
	if music != null and music.playing:
		return
	var spec: Dictionary = _beds[String(_current_bed)]
	if music == null:
		music = _music_a
	var stream: AudioStream = spec.get("stream", null)
	if stream == null:
		return
	_maybe_loop(stream, str(spec.get("file", "")), true)
	music.stream = stream
	music.bus = "Music"
	music.volume_db = float(spec.get("gain_db", 0.0))
	var pos: float = 0.0
	if bool(spec.get("resume", false)):
		pos = float(_bed_pos.get(String(_current_bed), 0.0))
	music.play(pos)
	log_audio("start", reason)


func log_audio(op: String, reason: String, extra: Dictionary = {}) -> void:
	var row: Dictionary = {
		"t": Time.get_ticks_msec(),
		"op": op,
		"reason": reason,
		"bed": String(_current_bed),
		"playing": music != null and music.playing,
	}
	var mi: int = AudioServer.get_bus_index("Master")
	var mu: int = AudioServer.get_bus_index("Music")
	if mi >= 0:
		row["master_mute"] = AudioServer.is_bus_mute(mi)
	if mu >= 0:
		row["music_mute"] = AudioServer.is_bus_mute(mu)
	for k in extra.keys():
		row[str(k)] = extra[k]
	audio_log.append(row)
	while audio_log.size() > AUDIO_LOG_CAP:
		audio_log.pop_front()
	print("[audio] %s reason=%s bed=%s playing=%s" % [op, reason, _current_bed, row["playing"]])


func set_master(lin: float) -> void:
	master_lin = clampf(lin, 0.0, 1.0)
	apply_levels()
	_save()


func set_music(lin: float) -> void:
	music_lin = clampf(lin, 0.0, 1.0)
	apply_levels()
	_save()


func set_ambience(lin: float) -> void:
	ambience_lin = clampf(lin, 0.0, 1.0)
	apply_levels()
	_save()


func set_sfx(lin: float) -> void:
	sfx_lin = clampf(lin, 0.0, 1.0)
	apply_levels()
	_save()


func set_cutscene_autoplay(on: bool) -> void:
	cutscene_autoplay = on
	_save()


func set_ui(lin: float) -> void:
	ui_lin = clampf(lin, 0.0, 1.0)
	apply_levels()
	_save()


func apply_levels() -> void:
	_set_bus("Master", master_lin)
	_set_bus("Music", music_lin)
	_set_bus("Stings", music_lin)
	_set_bus("Ambience", ambience_lin)
	_set_bus("SFX", sfx_lin)
	_set_bus("UI", ui_lin)


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
	ambience_lin = clampf(float(d.get("ambience", 0.8)), 0.0, 1.0)
	sfx_lin = clampf(float(d.get("sfx", 1.0)), 0.0, 1.0)
	ui_lin = clampf(float(d.get("ui", 0.9)), 0.0, 1.0)
	cutscene_autoplay = bool(d.get("cutscene_autoplay", true))


func _save() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify({
		"version": 2,
		"master": master_lin,
		"music": music_lin,
		"ambience": ambience_lin,
		"sfx": sfx_lin,
		"ui": ui_lin,
		"cutscene_autoplay": cutscene_autoplay,
	}))
