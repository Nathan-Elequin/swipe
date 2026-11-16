extends SceneTree
## Hotbar FX cleanup: no Rare fleck sparkles, subtler armed swirl, armed desat,
## NewStar on unclaimed uniques (not tokens / not claimed).
## Run: godot --headless --path . --script res://scripts/dev/hotbar_fx_cleanup_selftest.gd


const ITEM_CARD := preload("res://scripts/item_card.gd")
const RANK_SHIMMER := preload("res://scripts/rank_shimmer.gd")
const BUCKET := preload("res://scripts/bucket_rules.gd")


func _init() -> void:
	var failed := false
	var root := get_root()

	## --- Sparkle flecks gone ---
	var rare: Control = ITEM_CARD.new()
	root.add_child(rare)
	rare.setup(1, "napalm", "3", null, Color("5c2626"), Color("e8c36a"), "Napalm")
	rare.set_palette(Color("5c2626"), Color("e8c36a"), 3)
	rare.set_live("3", "", true)
	var sparkle_t := 0.0
	while sparkle_t < 3.2:
		rare._process(0.16)
		sparkle_t += 0.16
	failed = _check(failed, "no Sparkle child after process", rare.find_child("Sparkle", true, false) == null) or failed
	failed = _check(failed, "no _sparkle field", rare.get("_sparkle") == null) or failed
	failed = _check(
		failed,
		"item_card has no _tick_sparkle",
		not rare.has_method("_tick_sparkle")
	) or failed
	rare.queue_free()

	## --- Armed swirl: slower period, half strength, no orbiting dots ---
	failed = _check(
		failed,
		"armed period ~4s",
		is_equal_approx(RANK_SHIMMER.ARMED_PERIOD_S, 4.0)
	) or failed
	failed = _check(
		failed,
		"armed glint half of old 0.35",
		is_equal_approx(RANK_SHIMMER.ARMED_GLINT_STRENGTH, 0.175)
	) or failed
	var shader_src := FileAccess.get_file_as_string("res://shaders/rank_shimmer.gdshader")
	failed = _check(failed, "shader readable", shader_src != "") or failed
	failed = _check(
		failed,
		"shader has no orbiting-dot loop",
		shader_src.find("for (int s = 0; s < 3; s++)") < 0
		and shader_src.find("dotp") < 0
	) or failed
	failed = _check(
		failed,
		"shader armed period 4.0",
		shader_src.find("clock / 4.0") >= 0
	) or failed
	failed = _check(
		failed,
		"shader armed glint 0.175",
		shader_src.find("on_rim * 0.175") >= 0
	) or failed
	failed = _check(
		failed,
		"rarity sweep still present",
		shader_src.find("sweep_ratio") >= 0 and shader_src.find("diag") >= 0
	) or failed

	## --- Armed desat 0.2 vs unplayable 0.6 ---
	var armed_card: Control = ITEM_CARD.new()
	root.add_child(armed_card)
	armed_card.setup(2, "healing_potion", "", null, Color("5c2626"), Color("d4894e"), "Revival Potion")
	armed_card.set_palette(Color("5c2626"), Color("d4894e"), 2)
	armed_card.set_live("", "", false)
	armed_card.set_armed(true, "")
	armed_card._tick_shimmer()
	var armed_mat: ShaderMaterial = armed_card.get("_shimmer_mat") as ShaderMaterial
	failed = _check(failed, "armed has shimmer mat", armed_mat != null) or failed
	if armed_mat != null:
		failed = _check(
			failed,
			"armed unplayable desat 0.2",
			is_equal_approx(float(armed_mat.get_shader_parameter("desat")), 0.2)
		) or failed
		failed = _check(
			failed,
			"armed flag on",
			float(armed_mat.get_shader_parameter("armed")) > 0.5
		) or failed

	var grey_card: Control = ITEM_CARD.new()
	root.add_child(grey_card)
	grey_card.setup(3, "breastplate", "2", null, Color("5c2626"), Color("d4894e"), "Breastplate")
	grey_card.set_palette(Color("5c2626"), Color("d4894e"), 1)
	grey_card.set_live("2", "", false)
	grey_card.set_armed(false, "")
	grey_card._tick_shimmer()
	var grey_mat: ShaderMaterial = grey_card.get("_shimmer_mat") as ShaderMaterial
	failed = _check(failed, "unplayable has shimmer mat", grey_mat != null) or failed
	if grey_mat != null:
		failed = _check(
			failed,
			"plain unplayable desat 0.6",
			is_equal_approx(float(grey_mat.get_shader_parameter("desat")), 0.6)
		) or failed
		failed = _check(
			failed,
			"plain unplayable not armed",
			float(grey_mat.get_shader_parameter("armed")) < 0.5
		) or failed
	armed_card.queue_free()
	grey_card.queue_free()

	## --- NewStar: fresh unique on, claimed off, token off ---
	var CabinScr = load("res://scripts/home_cabin.gd")
	var cabin: Node = CabinScr.new()
	cabin.set("_persist_writes", false)
	cabin.set_process(false)
	cabin.set_physics_process(false)
	root.add_child(cabin)
	cabin.call("_apply_defaults")
	## Minimal catalog so is_token / claim lookups resolve.
	cabin.items_by_id = {
		"crossbow": {"id": "crossbow", "pool": 2, "status": "live", "name": "Crossbow"},
		"toll": {"id": "toll", "pool": -1, "status": "live", "name": "Toll"},
		"hex": {"id": "hex", "pool": 2, "status": "live", "name": "Hex"},
	}
	failed = _check(failed, "fresh unique not claimed", not cabin.is_cabinet_claimed("crossbow")) or failed

	var star_card: Control = ITEM_CARD.new()
	root.add_child(star_card)
	star_card.setup(4, "crossbow", "3", null, Color("5c2626"), Color("c5cdd8"), "Crossbow")
	star_card.custom_minimum_size = Vector2(ITEM_CARD.CARD_W, ITEM_CARD.CARD_H)
	star_card.size = Vector2(ITEM_CARD.CARD_W, ITEM_CARD.CARD_H)
	## Mimic main._apply_collection_item_badge for a fresh unique.
	var fresh_unique: bool = (not BUCKET.is_token(cabin.items_by_id["crossbow"])) and (not cabin.is_cabinet_claimed("crossbow"))
	star_card.set_new_star(fresh_unique)
	var star = star_card.get("_new_star")
	failed = _check(failed, "fresh unique creates NewStar", star != null) or failed
	if star != null:
		failed = _check(failed, "fresh unique NewStar visible", star.visible) or failed
		failed = _check(
			failed,
			"NewStar parented to card root",
			star.get_parent() == star_card
		) or failed
		failed = _check(
			failed,
			"NewStar top-right overhang pos",
			is_equal_approx(star.position.x, ITEM_CARD.CARD_W - 24.0)
			and is_equal_approx(star.position.y, -4.0)
		) or failed
		failed = _check(failed, "card root does not clip", star_card.clip_contents == false) or failed

	## Claimed → hidden.
	cabin.swiped["crossbow"] = true
	failed = _check(failed, "claimed unique on cabinet", cabin.is_cabinet_claimed("crossbow")) or failed
	star_card.set_new_star(not cabin.is_cabinet_claimed("crossbow"))
	star = star_card.get("_new_star")
	failed = _check(
		failed,
		"claimed unique hides NewStar",
		star == null or star.visible == false
	) or failed

	## Token (Toll, pool -1) → never starred.
	var token_card: Control = ITEM_CARD.new()
	root.add_child(token_card)
	token_card.setup(5, "toll", "6", null, Color("5c2626"), Color("6e675c"), "Toll")
	var is_tok := BUCKET.is_token(cabin.items_by_id["toll"])
	failed = _check(failed, "toll is token", is_tok) or failed
	token_card.set_new_star(not is_tok and not cabin.is_cabinet_claimed("toll"))
	var tok_star = token_card.get("_new_star")
	failed = _check(
		failed,
		"token has no visible NewStar",
		tok_star == null or tok_star.visible == false
	) or failed

	star_card.queue_free()
	token_card.queue_free()
	cabin.queue_free()

	if failed:
		print("HOTBAR_FX_CLEANUP_FAIL")
		quit(1)
	else:
		print("HOTBAR_FX_CLEANUP_OK")
		quit(0)


func _check(failed: bool, label: String, ok: bool) -> bool:
	if ok:
		print("  ok  ", label)
		return false
	print("  FAIL ", label)
	return true
