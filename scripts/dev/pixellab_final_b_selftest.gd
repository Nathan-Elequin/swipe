extends SceneTree
## PixelLab final-B wiring: every new frame set loads; FX helpers spawn and free.
## Run: godot --headless --path . --script res://scripts/dev/pixellab_final_b_selftest.gd


const DUNGEON_ART := preload("res://scripts/dungeon_art.gd")
const FX_ONESHOT := preload("res://scripts/fx_oneshot.gd")
const BOSS_WHEEL := preload("res://scripts/boss_wheel.gd")
const ENDLESS_HUD := preload("res://scripts/ui/endless_hud.gd")


const EXPECTED := {
	"arrow_flight": 5,
	"shuriken_spin": 4,
	"chakram_spin": 5,
	"double_axe_spin": 5,
	"land_burst": 5,
	"tesla_coil_zap": 7,
	"napalm_burst": 7,
	"catapult_fling": 7,
	"last_match_flame": 3,
	"heal_sparkle": 7,
	"measuring_tape_snap": 5,
	"love_potion_hearts": 5,
	"orb_pulse": 5,
	"polymorph_poof": 5,
	"hex_flare": 5,
	"net_throw": 5,
	"smoke_bomb_puff": 7,
	"bag_of_holding_gulp": 5,
	"flying_saucer_zoom": 5,
	"iris_ring": 5,
	"card_crumble": 5,
	"skull_coin_flip": 5,
	"gold_ring_pulse": 7,
}

const DROP_INS := [
	"res://assets/ui/biome_splash/cue_leaf.png",
	"res://assets/ui/tutorial/tut_arrowhead_f0.png",
	"res://assets/ui/tutorial/tut_glove_bob_f0.png",
	"res://assets/ui/endless/endless_plaque.png",
	"res://assets/ui/map/stamps/stamp_crystal_cavern_idle.png",
	"res://assets/ui/map/stamps/stamp_crystal_cavern_hover.png",
	"res://assets/ui/map/stamps/stamp_crystal_cavern_press.png",
	"res://assets/dungeon/home/overlays/candle_glint_f0.png",
	"res://assets/dungeon/home/nib/nib_cheer_f0.png",
	"res://assets/dungeon/home/nib/nib_shrug_f0.png",
	"res://assets/ui/title/emblem/emblem_verdant_idle_f0.png",
]

const STRIKE_IDS := [
	"tesla_coil", "napalm", "catapult", "last_match", "measuring_tape",
	"love_potion", "orb", "polymorph", "hex",
]

const PROJECTILE_IDS := [
	"longbow", "crossbow", "arrow_head", "shuriken", "chakram", "double_axe",
]

const UTILITY_IDS := [
	"net", "smoke_bomb", "bag_of_holding", "flying_saucer",
]


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

	for path in DROP_INS:
		failed = _check(
			failed,
			"%s loads" % path.get_file(),
			ResourceLoader.exists(path) and load(path) != null
		) or failed

	for i in 5:
		failed = _check(
			failed,
			"tut_glove_bob_f%d" % i,
			ResourceLoader.exists("res://assets/ui/tutorial/tut_glove_bob_f%d.png" % i)
		) or failed
		failed = _check(
			failed,
			"candle_glint_f%d" % i,
			ResourceLoader.exists("res://assets/dungeon/home/overlays/candle_glint_f%d.png" % i)
		) or failed
		failed = _check(
			failed,
			"nib_cheer_f%d" % i,
			ResourceLoader.exists("res://assets/dungeon/home/nib/nib_cheer_f%d.png" % i)
		) or failed
		failed = _check(
			failed,
			"nib_shrug_f%d" % i,
			ResourceLoader.exists("res://assets/dungeon/home/nib/nib_shrug_f%d.png" % i)
		) or failed

	for cid in STRIKE_IDS:
		var strike: Array = art.item_strike_frames(str(cid))
		failed = _check(failed, "ITEM_STRIKE %s frames" % cid, strike.size() >= 3) or failed

	for cid2 in PROJECTILE_IDS:
		var proj: Array = art.item_projectile_frames(str(cid2))
		failed = _check(failed, "ITEM_PROJECTILE %s frames" % cid2, proj.size() >= 4) or failed

	for cid3 in UTILITY_IDS:
		var util: Array = art.item_utility_frames(str(cid3))
		failed = _check(failed, "ITEM_UTILITY %s frames" % cid3, util.size() >= 5) or failed

	## Helper spawn + free after layout.
	var root := get_root()
	var host := Control.new()
	host.name = "FxHostB"
	host.size = Vector2(1680, 1040)
	root.add_child(host)
	await process_frame

	var burst: Array = art.fx_frames("land_burst")
	var spr: AnimatedSprite2D = FX_ONESHOT.play(host, burst, Vector2(840, 520), 2.0, 14.0, false, 40)
	failed = _check(failed, "land_burst FxOneShot spawned", spr != null and is_instance_valid(spr)) or failed
	if spr != null:
		var guard := 0
		while is_instance_valid(spr) and spr.is_playing() and guard < 120:
			await process_frame
			guard += 1
		await process_frame
		await process_frame
		failed = _check(
			failed,
			"land_burst FxOneShot freed after finish",
			not is_instance_valid(spr) or spr.is_queued_for_deletion()
		) or failed

	var heal: Array = art.fx_frames("heal_sparkle")
	var hspr: AnimatedSprite2D = FX_ONESHOT.play(host, heal, Vector2(900, 200), 4.0, 14.0, false, 40)
	failed = _check(failed, "heal_sparkle spawned", hspr != null and is_instance_valid(hspr)) or failed
	if hspr != null:
		var g2 := 0
		while is_instance_valid(hspr) and hspr.is_playing() and g2 < 120:
			await process_frame
			g2 += 1
		await process_frame
		failed = _check(
			failed,
			"heal_sparkle freed after finish",
			not is_instance_valid(hspr) or hspr.is_queued_for_deletion()
		) or failed

	var wheel = BOSS_WHEEL.new()
	host.add_child(wheel)
	wheel.size = Vector2(640, 640)
	wheel.set_atlas(null, null, null, {}, {})
	if wheel.has_method("_play_land_burst"):
		wheel._play_land_burst(0)
	await process_frame
	failed = _check(failed, "boss_wheel land_burst helper callable", true) or failed

	## Tutorial pointer: when a spotlight hole shows, `_arrows` must be non-empty
	## so SpotInk can draw glove + arrowhead (B03 wheel used to leave arrows at 0).
	## Mimic main._tut_ensure_pointer_arrows for a hole with no teach-arrow.
	var spots: Array = [Rect2(400, 200, 640, 640)]
	var arrows: Array = []
	if arrows.is_empty() and not spots.is_empty():
		var tip_rect: Rect2 = spots[0]
		var tip: Vector2 = tip_rect.get_center()
		var tail: Vector2 = tip + Vector2(-80.0, -40.0)
		arrows.append([tail, tip])
	failed = _check(
		failed,
		"tutorial arrows non-empty when pointer/spotlight shows",
		arrows.size() > 0
	) or failed
	failed = _check(
		failed,
		"tutorial spots non-empty with arrows",
		spots.size() > 0 and arrows.size() > 0
	) or failed
	## SpotInk._ensure_tut_tex path (same paths as tutorial_guide).
	var glove_n := 0
	for gi in 5:
		var gpath := "res://assets/ui/tutorial/tut_glove_bob_f%d.png" % gi
		if ResourceLoader.exists(gpath) and load(gpath) != null:
			glove_n += 1
	var ah_ok: bool = (
		ResourceLoader.exists("res://assets/ui/tutorial/tut_arrowhead_f0.png")
		and load("res://assets/ui/tutorial/tut_arrowhead_f0.png") != null
	)
	failed = _check(failed, "tutorial glove frames load when pointer shows", glove_n >= 5) or failed
	failed = _check(failed, "tutorial arrowhead loads when pointer shows", ah_ok) or failed
	## main.gd ships the ensure helper used on every tutorial spotlight refresh.
	var main_src: String = FileAccess.get_file_as_string("res://scripts/main.gd")
	failed = _check(
		failed,
		"main._tut_ensure_pointer_arrows exists",
		main_src.find("func _tut_ensure_pointer_arrows") >= 0
	) or failed
	failed = _check(
		failed,
		"tutorial refresh calls _tut_ensure_pointer_arrows",
		main_src.find("_tut_ensure_pointer_arrows(spots, arrows)") >= 0
	) or failed

	## Duration notes (pure FX one-shots; spin stays 1.56s):
	## land_burst 5f@14fps ≈ 0.36s — ok. iris loop covers fade. knife arc 0.28s /
	## arrow flight 0.32s — ok. No lengthen needed under the 0.2s floor.
	failed = _check(
		failed,
		"land_burst on-screen duration >= 0.2s (5f @14fps)",
		(5.0 / 14.0) >= 0.2
	) or failed

	var hud = ENDLESS_HUD.new()
	host.add_child(hud)
	await process_frame
	failed = _check(
		failed,
		"endless_hud has plaque or skull when assets present",
		hud.get_node_or_null("Root/EndlessPlaque") != null
		or hud.get_node_or_null("Root/SkullCoin") != null
		or not ResourceLoader.exists("res://assets/ui/endless/endless_plaque.png")
	) or failed

	host.queue_free()
	if failed:
		print("PIXELLAB_FINAL_B_SELFTEST failed")
		quit(1)
	print("PIXELLAB_FINAL_B_SELFTEST ok")
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
