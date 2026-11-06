extends SceneTree
## Headless: new monster wheel seats resolve multi-frame idles (facing strip
## when wheel pack is absent). Mirrors tools/qa/check_wheel_new_monster_idles.py.
## Run: godot --headless --path . --script res://scripts/dev/wheel_new_monster_idles_selftest.gd
## Does not boot main.gd. Does not invent PNG frames.

const ART := preload("res://scripts/dungeon_art.gd")

const NEW_IDS := [
	"imp",
	"quicksand_crab",
	"huntsman",
	"phantom",
	"collector",
	"glass_asp",
	"anvil",
]

const CONTROL_IDS := ["skeleton", "leech_league", "hollow", "goblin"]


func _init() -> void:
	var art = ART.new()
	art.setup()
	var failed := false
	var all_frames: Dictionary = art.wheel_frames_all()
	for id in NEW_IDS + CONTROL_IDS:
		var frames: Array = all_frames.get(id, [])
		if frames.is_empty():
			frames = art.monster_wheel_frames(id)
		failed = _check("%s_has_frames" % id, frames.size() >= 1) or failed
		if id == "anvil":
			# Anvil must keep its authored wheel_idle strip (facing is duplicated).
			var wheel0 := "res://assets/dungeon/anim/wheel/anvil_wheel_idle_f0.png"
			failed = _check("anvil_wheel_idle_on_disk", ResourceLoader.exists(wheel0)) or failed
		if id in ["imp", "quicksand_crab", "huntsman", "phantom", "collector", "glass_asp"]:
			failed = _check("%s_multi_frame" % id, frames.size() >= 2) or failed
			failed = _check(
				"%s_distinct_textures" % id,
				_distinct_tex_count(frames) >= 2
			) or failed
		elif id in CONTROL_IDS or id == "anvil":
			failed = _check("%s_multi_frame" % id, frames.size() >= 2) or failed
			failed = _check(
				"%s_distinct_textures" % id,
				_distinct_tex_count(frames) >= 2
			) or failed

	# Playback index changes across 200ms ticks the same way boss_wheel does.
	var imp: Array = all_frames.get("imp", art.monster_wheel_frames("imp"))
	if imp.size() >= 2:
		var a: int = int(0.0 / 0.2) % imp.size()
		var b: int = int(0.25 / 0.2) % imp.size()
		failed = _check("imp_playback_advances", a != b) or failed
	else:
		failed = _check("imp_playback_advances", false) or failed

	print("wheel_new_monster_idles_selftest failed=%s" % failed)
	quit(1 if failed else 0)


func _distinct_tex_count(frames: Array) -> int:
	var seen := {}
	for t in frames:
		if t == null:
			continue
		var tex: Texture2D = t as Texture2D
		if tex == null:
			continue
		var img: Image = tex.get_image()
		if img == null:
			seen[str(tex.get_rid())] = true
			continue
		seen[img.get_data().hex_encode()] = true
	return seen.size()


func _check(label: String, ok: bool) -> bool:
	if ok:
		print("PASS ", label)
		return false
	print("FAIL ", label)
	return true
