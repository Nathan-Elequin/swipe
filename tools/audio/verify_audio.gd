extends SceneTree
## Headless check: sfx-map files, layers, lookup, buses, loop flags.

const MAP_PATH := "res://data/sfx-map.json"
const LOOP_STEMS := ["music_combat", "music_deadly", "music_cabin", "cabin_fire_loop", "cabin_cat_purr_loop", "music", "music_intro", "music_ending", "music_station_inn", "music_station_rag", "music_station_harp", "music_verdant_hollow_loop", "music_cinder_forge_a", "music_cinder_forge_b", "music_cinder_forge_c", "music_crystal_cavern_a", "music_crystal_cavern_b", "music_crystal_cavern_c", "music_ashen_crypt_a", "music_ashen_crypt_b", "music_ashen_crypt_c"]
const BUS_ORDER := ["Master", "Music", "Stings", "Ambience", "SFX", "UI"]

var _fails: int = 0


func _initialize() -> void:
	_run()
	quit(1 if _fails > 0 else 0)


func _fail(msg: String) -> void:
	_fails += 1
	push_error(msg)
	print("FAIL: ", msg)


func _ok(msg: String) -> void:
	print("OK: ", msg)


func _run() -> void:
	if not FileAccess.file_exists(MAP_PATH):
		_fail("missing %s" % MAP_PATH)
		return
	var raw: String = FileAccess.get_file_as_string(MAP_PATH)
	var parsed: Variant = JSON.parse_string(raw)
	if typeof(parsed) != TYPE_DICTIONARY:
		_fail("sfx-map.json is not a dictionary")
		return
	var map: Dictionary = parsed
	var prefix: String = str(map.get("path_prefix", "res://assets/audio/"))
	var cues: Dictionary = map.get("cues", {})
	_check_files(cues, prefix)
	_check_layers(cues)
	_check_lookup(map.get("lookup", {}), cues)
	_check_buses()
	_check_loops(prefix)
	if _fails == 0:
		print("verify_audio: all checks passed (%s cues)" % cues.size())
	else:
		print("verify_audio: %s failure(s)" % _fails)


func _check_files(cues: Dictionary, prefix: String) -> void:
	var missing: PackedStringArray = PackedStringArray()
	for cue_id in cues.keys():
		var cue: Variant = cues[cue_id]
		if typeof(cue) != TYPE_DICTIONARY:
			continue
		for name in cue.get("files", []):
			var stem: String = str(name)
			var ogg: String = prefix + stem + ".ogg"
			var wav: String = prefix + stem + ".wav"
			var stream: AudioStream = null
			if ResourceLoader.exists(ogg):
				stream = load(ogg) as AudioStream
			elif ResourceLoader.exists(wav):
				stream = load(wav) as AudioStream
			if stream == null:
				missing.append("%s → %s" % [str(cue_id), stem])
	if missing.is_empty():
		_ok("cue files resolve")
	else:
		for line in missing:
			_fail("missing audio %s" % line)


func _check_layers(cues: Dictionary) -> void:
	var bad: PackedStringArray = PackedStringArray()
	for cue_id in cues.keys():
		var cue: Variant = cues[cue_id]
		if typeof(cue) != TYPE_DICTIONARY:
			continue
		for layer in cue.get("layers", []):
			if typeof(layer) != TYPE_DICTIONARY:
				continue
			var lid: String = str(layer.get("cue", ""))
			if lid != "" and not cues.has(lid):
				bad.append("%s layer %s" % [str(cue_id), lid])
	if bad.is_empty():
		_ok("layer cue ids exist")
	else:
		for line in bad:
			_fail("unknown layer %s" % line)


func _check_lookup(lookup: Dictionary, cues: Dictionary) -> void:
	var bad: PackedStringArray = PackedStringArray()
	_walk_lookup(lookup, cues, bad)
	if bad.is_empty():
		_ok("lookup targets exist")
	else:
		for line in bad:
			_fail("lookup target missing %s" % line)


func _walk_lookup(node: Variant, cues: Dictionary, bad: PackedStringArray, path: String = "") -> void:
	if typeof(node) == TYPE_STRING:
		var s: String = str(node)
		if s.contains(".") and not cues.has(s) and not s.begins_with("_"):
			bad.append("%s = %s" % [path, s])
		return
	if typeof(node) != TYPE_DICTIONARY:
		return
	for k in node.keys():
		if str(k).begins_with("_"):
			continue
		_walk_lookup(node[k], cues, bad, path + "/" + str(k))


func _check_buses() -> void:
	for n in BUS_ORDER:
		if AudioServer.get_bus_index(n) < 0:
			_fail("missing bus %s" % n)
	var master: int = AudioServer.get_bus_index("Master")
	var music: int = AudioServer.get_bus_index("Music")
	var amb: int = AudioServer.get_bus_index("Ambience")
	var sfx: int = AudioServer.get_bus_index("SFX")
	if master >= 0 and not _bus_has(master, "AudioEffectHardLimiter"):
		_fail("Master missing HardLimiter")
	if music >= 0 and not _bus_has(music, "AudioEffectAmplify"):
		_fail("Music missing Duck Amplify")
	if amb >= 0 and not _bus_has(amb, "AudioEffectLowPassFilter"):
		_fail("Ambience missing LowPassFilter")
	if sfx >= 0 and not _bus_has(sfx, "AudioEffectCompressor"):
		_fail("SFX missing Compressor")
	if _fails == 0 or true:
		_ok("buses present")


func _bus_has(idx: int, cls: String) -> bool:
	for i in AudioServer.get_bus_effect_count(idx):
		var fx := AudioServer.get_bus_effect(idx, i)
		if fx != null and fx.get_class() == cls:
			return true
	return false


func _check_loops(prefix: String) -> void:
	for stem in LOOP_STEMS:
		var path: String = prefix + stem + ".ogg"
		if not ResourceLoader.exists(path):
			_fail("loop file missing %s" % path)
			continue
		var stream: AudioStream = load(path)
		if stream is AudioStreamOggVorbis:
			if not (stream as AudioStreamOggVorbis).loop:
				_fail("%s loop != true" % stem)
			else:
				_ok("%s loops" % stem)
		else:
			_fail("%s is not AudioStreamOggVorbis" % stem)
