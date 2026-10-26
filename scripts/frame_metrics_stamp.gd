extends RefCounted
class_name FrameMetricsStamp
## Short SHA printed on the frame overlay and written into capture JSON.
## Editor F5 reads the live checkout (BuildStamp). Exports fall back to the
## baked stamp file, then to GIT_SHA.

const BUILD := preload("res://scripts/build_stamp.gd")
const GIT_SHA := "340b4b0f"


static func text() -> String:
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
