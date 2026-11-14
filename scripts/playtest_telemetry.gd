extends Node
## Quiet playtest events → the same Cloudflare Worker as F2 / tier lists.
## Itch and F5 only. F5 Sends are marked test. Never opens a GitHub Issue.

const CFG_PATH := "res://data/playtest-inbox.json"
const ANON_PATH := "user://playtest_anon.json"
const FLUSH_SEC := 12.0
const BATCH := 25
const PAYLOAD_CAP := 3500

var _http: HTTPRequest
var _cfg: Dictionary = {}
var _queue: Array = []
var _busy: bool = false
var _flush_left: float = FLUSH_SEC
var _anon: String = ""
var _session: String = ""
var _enabled: bool = false


func setup() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_http = HTTPRequest.new()
	_http.timeout = 12.0
	add_child(_http)
	_http.request_completed.connect(_on_done)
	_load_cfg()
	_enabled = (
		PlaytestFlag.on()
		and bool(_cfg.get("telemetry", false))
		and str(_cfg.get("url", "")).strip_edges() != ""
	)
	if not _enabled:
		return
	_anon = _load_anon()
	_session = _new_id()
	_hook_web_beacon()
	capture("session_start", {
		"web": OS.has_feature("web"),
		"editor": OS.has_feature("editor"),
	})


func capture(name: String, props: Dictionary = {}) -> void:
	if not _enabled:
		return
	var row := {
		"t": Time.get_ticks_msec(),
		"name": str(name),
		"props": _clip_props(props),
	}
	_queue.append(row)
	if _queue.size() >= BATCH:
		flush()


func flush() -> void:
	if not _enabled or _busy or _queue.is_empty():
		return
	var batch: Array = _queue.slice(0, mini(BATCH, _queue.size()))
	_queue = _queue.slice(batch.size())
	_busy = true
	var payload := {
		"kind": "telemetry",
		"anon_id": _anon,
		"session_id": _session,
		"when": Time.get_datetime_string_from_system(true, true),
		"build": "%s %s" % [OS.get_name(), Engine.get_architecture_name()],
		"source": "editor" if OS.has_feature("editor") else "export",
		"is_test": OS.has_feature("editor"),
		"events": batch,
	}
	var body: String = JSON.stringify(payload)
	var url: String = str(_cfg.get("url", "")).strip_edges()
	var token: String = str(_cfg.get("token", "")).strip_edges()
	var headers := PackedStringArray([
		"Content-Type: application/json",
		"X-Swipe-Playtest: %s" % token,
		"User-Agent: Mozilla/5.0 (SwipePlaytest)",
	])
	var err: Error = _http.request(url, headers, HTTPClient.METHOD_POST, body)
	if err != OK:
		_busy = false
		for ev in batch:
			_queue.append(ev)


func _process(delta: float) -> void:
	if not _enabled:
		return
	_flush_left -= delta
	if _flush_left <= 0.0:
		_flush_left = FLUSH_SEC
		flush()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		flush()
		_beacon_flush()
	elif what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		flush()


func _load_cfg() -> void:
	_cfg = {}
	if not FileAccess.file_exists(CFG_PATH):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(CFG_PATH))
	if typeof(parsed) == TYPE_DICTIONARY:
		_cfg = parsed


func _load_anon() -> String:
	if OS.has_feature("web") and ClassDB.class_exists("JavaScriptBridge"):
		var from_js: String = str(JavaScriptBridge.eval(
			"(function(){try{var k='swipe_pt_anon';var v=localStorage.getItem(k);if(!v){v=crypto.randomUUID();localStorage.setItem(k,v);}return v;}catch(e){return '';}})()",
			true
		)).strip_edges()
		if from_js != "":
			return from_js
	if FileAccess.file_exists(ANON_PATH):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(ANON_PATH))
		if typeof(parsed) == TYPE_DICTIONARY:
			var old: String = str(parsed.get("anon_id", "")).strip_edges()
			if old != "":
				return old
	var fresh: String = _new_id()
	var f := FileAccess.open(ANON_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({"anon_id": fresh}))
		f.close()
	return fresh


func _new_id() -> String:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	return "%08x-%04x-%04x-%04x-%04x%08x" % [
		rng.randi(),
		rng.randi() & 0xffff,
		(rng.randi() & 0x0fff) | 0x4000,
		(rng.randi() & 0x3fff) | 0x8000,
		rng.randi() & 0xffff,
		rng.randi(),
	]


func _clip_props(props: Dictionary) -> Dictionary:
	var raw: String = JSON.stringify(props)
	if raw.length() <= PAYLOAD_CAP:
		return props.duplicate(true)
	return {"truncated": true, "n": raw.length()}


func _hook_web_beacon() -> void:
	if not OS.has_feature("web"):
		return
	if not ClassDB.class_exists("JavaScriptBridge"):
		return
	var url: String = str(_cfg.get("url", "")).strip_edges()
	var token: String = str(_cfg.get("token", "")).strip_edges()
	JavaScriptBridge.eval(
		"(function(){window._swipePtUrl=%s;window._swipePtK=%s;})();" % [
			JSON.stringify(url),
			JSON.stringify(token),
		],
		true
	)


func _beacon_flush() -> void:
	if not _enabled or _queue.is_empty():
		return
	if not OS.has_feature("web") or not ClassDB.class_exists("JavaScriptBridge"):
		return
	var n: int = mini(15, _queue.size())
	var payload := {
		"kind": "telemetry",
		"anon_id": _anon,
		"session_id": _session,
		"when": Time.get_datetime_string_from_system(true, true),
		"build": "%s %s" % [OS.get_name(), Engine.get_architecture_name()],
		"source": "editor" if OS.has_feature("editor") else "export",
		"is_test": OS.has_feature("editor"),
		"events": _queue.slice(_queue.size() - n),
	}
	var body: String = JSON.stringify(payload)
	JavaScriptBridge.eval(
		"(function(){try{var u=window._swipePtUrl||'';var k=window._swipePtK||'';if(!u||!navigator.sendBeacon)return;var url=u+(u.indexOf('?')>=0?'&':'?')+'k='+encodeURIComponent(k);navigator.sendBeacon(url,new Blob([%s],{type:'text/plain'}));}catch(e){}})();" % JSON.stringify(body),
		true
	)
	_queue.clear()


func _on_done(_result: int, code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	_busy = false
	if code < 200 or code >= 300:
		return
	if _queue.size() >= BATCH:
		flush()
