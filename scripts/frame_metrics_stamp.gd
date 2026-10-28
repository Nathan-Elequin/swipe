extends RefCounted
class_name FrameMetricsStamp
## Short SHA printed on the frame overlay and written into capture JSON.
## Editor F5 reads the live checkout (BuildStamp). Exports fall back to the
## baked stamp file, then to GIT_SHA.
##
## Cache the live string: BuildStamp.from_repo() runs `git status` via
## OS.execute. The F8 overlay used to call this every 0.25s (and on every
## spike breadcrumb), which matches the Scorecard shared ~98–101 ms hitch
## across cabin/fight/spin/attack/lunge/transition.

const BUILD := preload("res://scripts/build_stamp.gd")
const GIT_SHA := "340b4b0f"
## Long enough that a capture's label refreshes reuse one status; short
## enough that a mid-session commit still shows up after a few seconds.
const CACHE_USEC := 5000000

static var _cache_text: String = ""
static var _cache_usec: int = -1


static func text() -> String:
	var now := Time.get_ticks_usec()
	if _cache_text != "" and _cache_usec >= 0 and now - _cache_usec < CACHE_USEC:
		return _cache_text
	var raw := _read_fresh()
	_cache_text = raw
	_cache_usec = now
	return raw


static func invalidate() -> void:
	_cache_text = ""
	_cache_usec = -1


static func _read_fresh() -> String:
	if OS.has_feature("editor"):
		var live: String = BUILD.from_repo()
		if live != "":
			return live
	var baked: String = BUILD.read_baked()
	if baked != "":
		return baked
	return GIT_SHA


static func sha_hex() -> String:
	var raw := text()
	var hex := ""
	for i in raw.length():
		var c := raw.substr(i, 1)
		var ok := (c >= "0" and c <= "9") or (c >= "a" and c <= "f")
		if not ok:
			break
		hex += c
	if hex == "":
		return GIT_SHA
	return hex


static func dirty() -> bool:
	return text().ends_with("*")
