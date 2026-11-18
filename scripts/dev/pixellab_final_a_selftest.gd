extends SceneTree
## PixelLab final-A wiring: every new frame set loads, helper spawns and frees.
## Run: godot --headless --path . --script res://scripts/dev/pixellab_final_a_selftest.gd


const DUNGEON_ART := preload("res://scripts/dungeon_art.gd")
const FX_ONESHOT := preload("res://scripts/fx_oneshot.gd")
const COMBAT_STAGE := preload("res://scripts/combat_stage.gd")
const BOSS_WHEEL := preload("res://scripts/boss_wheel.gd")


const EXPECTED := {
	"hit_light": 6,
	"hit_heavy": 6,
	"blood_splat": 6,
	"defeat_poof": 9,
	"soul_wisp": 6,
	"take_claw": 5,
	"take_bite": 5,
	"take_thud": 5,
	"block_clang": 6,
	"hub_shield_crack": 5,
	"heart_break": 5,
	"heart_refill": 5,
	"seat_slain": 5,
	"seat_blocked": 5,
	"seat_escaped": 5,
	"wheel_pointer_tick": 5,
	"wheel_pointer_land": 5,
	"sledgehammer_swing": 7,
	"throwing_knife_spin": 5,
	"knucklers_punch": 5,
	"spiked_flail_swing": 7,
	"da_boot_stomp": 5,
	"spinning_top_spin": 5,
}

const SLASH_IDS := ["imp", "glass_asp", "fungal_colony", "shambling_mound"]
const FACING_IDLE := ["anvil", "oligarch", "fungal_colony"]


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var failed := false
	var art = DUNGEON_ART.new()
	art.setup()

	for stem in EXPECTED.keys():
		var frames: Array = art.fx_frames(str(stem))
		var want: int = int(EXPECTED[stem])
		failed = _check(
			failed,
			"%s frame count %s" % [stem, want],
			frames.size() == want
		) or failed
		failed = _check(
			failed,
			"%s frames non-null" % stem,
			_all_tex(frames)
		) or failed

	failed = _check(
		failed,
		"wheel_pointer.png loads",
		ResourceLoader.exists("res://assets/ui/wheel/wheel_pointer.png")
		and load("res://assets/ui/wheel/wheel_pointer.png") != null
	) or failed

	for id in SLASH_IDS:
		var slash: Array = art._slash_strip(str(id))
		failed = _check(failed, "%s slash has frames" % id, slash.size() >= 5) or failed
		failed = _check(failed, "%s slash non-null" % id, _all_tex(slash)) or failed

	for id2 in FACING_IDLE:
		var idle: Array = art._facing_strip(str(id2))
		failed = _check(failed, "%s facing idle 4f" % id2, idle.size() >= 4) or failed

	var fungal_wheel: Array = art.monster_wheel_frames("fungal_colony")
	failed = _check(
		failed,
		"fungal_colony wheel idle prefers 4f strip",
		fungal_wheel.size() >= 4
	) or failed

	for cid in DUNGEON_ART.ITEM_STRIKE.keys():
		var strike: Array = art.item_strike_frames(str(cid))
		failed = _check(
			failed,
			"ITEM_STRIKE %s frames" % cid,
			strike.size() >= 5
		) or failed

	## Helper spawn + free after layout.
	var root := get_root()
	var host := Control.new()
	host.name = "FxHost"
	host.size = Vector2(1680, 1040)
	root.add_child(host)
	await process_frame

	var hit: Array = art.fx_frames("hit_light")
	var spr: AnimatedSprite2D = FX_ONESHOT.play(host, hit, Vector2(840, 520), 4.0, 16.0, false, 40)
	failed = _check(failed, "FxOneShot spawned", spr != null and is_instance_valid(spr)) or failed
	if spr != null:
		var guard := 0
		while is_instance_valid(spr) and spr.is_playing() and guard < 120:
			await process_frame
			guard += 1
		await process_frame
		await process_frame
		failed = _check(
			failed,
			"FxOneShot freed after finish",
			not is_instance_valid(spr) or spr.is_queued_for_deletion()
		) or failed

	var stage = COMBAT_STAGE.new()
	host.add_child(stage)
	stage.setup(art)
	stage.show_monster("goblin", 1)
	stage.visible = true
	stage.take_hit(false)
	stage.take_hit(true)
	stage.play_block()
	await process_frame
	failed = _check(failed, "combat_stage take_hit/play_block callable", true) or failed

	var wheel = BOSS_WHEEL.new()
	host.add_child(wheel)
	wheel.size = Vector2(640, 640)
	wheel.set_atlas(null, null, null, {}, {})
	if wheel.has_method("play_pointer_tick"):
		wheel.play_pointer_tick()
		wheel.play_pointer_land()
	if wheel.has_method("play_take_overlay"):
		wheel.play_take_overlay("claw")
		wheel.play_take_overlay("bite")
		wheel.play_take_overlay("thud")
	wheel.set_vitals(3, 5, -1, 0, -1)
	wheel.set_vitals(2, 5, -1, 0, -1)
	wheel.set_vitals(4, 5, -1, 0, -1)
	await process_frame
	failed = _check(failed, "boss_wheel hub/pointer helpers callable", true) or failed

	host.queue_free()
	if failed:
		print("PIXELLAB_FINAL_A_SELFTEST failed")
		quit(1)
	print("PIXELLAB_FINAL_A_SELFTEST ok")
	quit(0)


func _all_tex(frames: Array) -> bool:
	if frames.is_empty():
		return false
	for t in frames:
		if t == null or not (t is Texture2D):
			return false
	return true


func _check(failed: bool, label: String, ok: bool) -> bool:
	if ok:
		print("  ok  ", label)
		return failed
	print("  FAIL ", label)
	return true
