extends Node
## POST playtest notes to the Cloudflare Worker. Clipboard if the Worker URL is empty or the POST fails.

const CFG_PATH := "res://data/playtest-inbox.json"
const COPY := preload("res://scripts/player_copy.gd")

signal finished(ok: bool, detail: String)

var _http: HTTPRequest
var _cfg: Dictionary = {}
var _busy: bool = false
var _pending_plain: String = ""


func setup() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_http = HTTPRequest.new()
	_http.timeout = 12.0
	add_child(_http)
	_http.request_completed.connect(_on_done)
	_load_cfg()


func _load_cfg() -> void:
	_cfg = {}
	if not FileAccess.file_exists(CFG_PATH):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(CFG_PATH))
	if typeof(parsed) == TYPE_DICTIONARY:
		_cfg = parsed


func configured() -> bool:
	return str(_cfg.get("url", "")).strip_edges() != ""


func send(payload: Dictionary) -> void:
	if _busy:
		return
	var body: String = JSON.stringify(payload)
	_pending_plain = format_plain(payload)
	if not configured():
		_copy_and_fail(_pending_plain, COPY.text("playtest.send_failed", "Could not send. Copied to the clipboard instead."))
		return
	_busy = true
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
		_copy_and_fail(_pending_plain, COPY.text("playtest.send_failed", "Could not send. Copied to the clipboard instead."))


func format_plain(payload: Dictionary) -> String:
	var lines: PackedStringArray = PackedStringArray()
	lines.append("[playtest] %s" % str(payload.get("title", "general")))
	var card_id: String = str(payload.get("card_id", "")).strip_edges()
	var card_name: String = str(payload.get("card_name", "")).strip_edges()
	if card_id != "" or card_name != "":
		lines.append("card: %s (%s)" % [card_name, card_id])
	var preset: String = str(payload.get("preset", "")).strip_edges()
	if preset != "":
		lines.append("preset: %s" % preset)
	var note: String = str(payload.get("note", "")).strip_edges()
	if note != "":
		lines.append("")
		lines.append(note)
	var fight_log: String = str(payload.get("log", "")).strip_edges()
	if fight_log != "":
		lines.append("")
		lines.append("Log:")
		lines.append(fight_log)
	var slog: Variant = payload.get("session_log", null)
	if typeof(slog) == TYPE_ARRAY and not (slog as Array).is_empty():
		lines.append("")
		lines.append("Session:")
		for ev in slog:
			if typeof(ev) != TYPE_DICTIONARY:
				continue
			lines.append("%s %s %s" % [ev.get("t", 0), ev.get("kind", ""), ev.get("msg", "")])
	var ranks: Variant = payload.get("ranks", null)
	if typeof(ranks) == TYPE_DICTIONARY and not (ranks as Dictionary).is_empty():
		lines.append("")
		lines.append("Tier list:")
		lines.append(JSON.stringify(ranks, "\t"))
	return "\n".join(lines)


func _copy_and_fail(body: String, msg: String) -> void:
	DisplayServer.clipboard_set(body)
	finished.emit(false, msg)


func _on_done(_result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	_busy = false
	if code >= 200 and code < 300:
		finished.emit(true, COPY.text("playtest.sent", "Sent. Thank you."))
		return
	_copy_and_fail(
		_pending_plain,
		COPY.text("playtest.send_failed", "Could not send. Copied to the clipboard instead.")
	)
