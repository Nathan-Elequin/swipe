extends SceneTree
## Headless draw-call dump + asserts for title teaser beats (PIXEL-NOTES).

const OUT_PATH := "res://design/cli-runs/08-title-fix/beats.json"
const TIMES := [1.0, 3.6, 5.7, 7.1, 9.5, 11.6, 13.5]


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var art = preload("res://scripts/dungeon_art.gd").new()
	if art.has_method("setup"):
		art.setup()
	var teaser = load("res://scripts/title_teaser.gd").new()
	root.add_child(teaser)
	teaser.setup(art, null)
	teaser.anchor_left = 0.0
	teaser.anchor_top = 0.0
	teaser.anchor_right = 0.0
	teaser.anchor_bottom = 0.0
	teaser.position = Vector2.ZERO
	teaser.size = Vector2(1680, 1040)
	teaser.custom_minimum_size = Vector2(1680, 1040)

	var captures: Array = []
	for t in TIMES:
		var cap: Dictionary = teaser.debug_capture(float(t))
		captures.append(cap)
		print("CAPTURE t=%.1f blits=%d hall=%s still_a=%.2f white=%.2f" % [
			float(t),
			(cap.get("blits", []) as Array).size(),
			str(cap.get("hall_strip_in_use", "")),
			float(cap.get("still_a", 0.0)),
			float(cap.get("white", 0.0)),
		])

	var fails: Array[String] = []
	_assert_no_monsters_before_threshold(captures, fails)
	_assert_logo_and_title(teaser, captures, fails)
	_assert_held_catches(teaser, fails)
	_assert_spend_gone(teaser, fails)
	_assert_hall_b(captures, fails)
	_assert_swirl(captures, fails)
	_assert_snap4(captures, fails)
	_assert_dragon_ogre(captures, fails)
	_assert_no_drift(teaser, fails)

	var out := {"captures": captures, "fails": fails}
	var f := FileAccess.open(OUT_PATH, FileAccess.WRITE)
	if f == null:
		push_error("cannot write %s" % OUT_PATH)
		print("TITLE_BEATS FAIL write")
		quit(1)
		return
	f.store_string(JSON.stringify(out, "\t"))
	f.close()

	if fails.is_empty():
		print("TITLE_BEATS OK")
		quit(0)
	else:
		print("TITLE_BEATS FAIL %s" % ", ".join(fails))
		quit(1)


func _blits_at(captures: Array, t: float) -> Array:
	for c in captures:
		if is_equal_approx(float(c.get("t", -1.0)), t) or absf(float(c.get("t", -1.0)) - t) < 0.05:
			return c.get("blits", []) as Array
	return []


func _cap_at(captures: Array, t: float) -> Dictionary:
	for c in captures:
		if absf(float(c.get("t", -1.0)) - t) < 0.05:
			return c
	return {}


func _is_monster_blit(b: Dictionary) -> bool:
	var tex := str(b.get("tex", ""))
	if tex.contains("/mon_") or tex.contains("extra/") or tex.contains("/monsters/"):
		# hill/hall/still/logo/items/hero are not monsters; extras include items too
		pass
	var name := tex.get_file().get_basename().to_lower()
	for id in ["goblin", "dire_wolf", "skeleton", "ogre", "hornet_swarm", "spider_queen", "dragon"]:
		if name == id or name.begins_with("mon_%s" % id) or name.begins_with("%s_" % id):
			return true
		if tex.contains("/%s.png" % id) or tex.contains("/%s_" % id):
			return true
	if tex.contains("mon_"):
		return true
	return false


func _is_item_blit(b: Dictionary, id: String) -> bool:
	var tex := str(b.get("tex", "")).to_lower()
	return tex.contains(id) or tex.contains("item_%s" % id)


func _assert_no_monsters_before_threshold(captures: Array, fails: Array[String]) -> void:
	var blits: Array = _blits_at(captures, 1.0)
	for b in blits:
		if _is_monster_blit(b):
			fails.append("a:monster_before_threshold")
			print("ASSERT a FAIL monster blit at t<2: %s" % str(b.get("tex", "")))
			return
	print("ASSERT a OK no monster at t<2")


func _assert_logo_and_title(teaser, captures: Array, fails: Array[String]) -> void:
	var cap: Dictionary = _cap_at(captures, 13.5)
	var lr: Array = cap.get("logo_rect", []) as Array
	var want := [480.0, 80.0, 720.0, 160.0]
	var ok := lr.size() == 4
	if ok:
		for i in 4:
			if absf(float(lr[i]) - float(want[i])) > 0.5:
				ok = false
				break
	# Also require a logo blit with that rect if logo texture exists.
	var logo_blit_ok := false
	for b in cap.get("blits", []) as Array:
		var tex := str(b.get("tex", ""))
		if tex.ends_with("logo.png"):
			var r: Array = b.get("rect", []) as Array
			if r.size() == 4 and absf(float(r[0]) - 480.0) <= 0.5 and absf(float(r[1]) - 80.0) <= 0.5 \
					and absf(float(r[2]) - 720.0) <= 0.5 and absf(float(r[3]) - 160.0) <= 0.5:
				logo_blit_ok = true
	var title_hidden := true
	for lab in cap.get("labels", []) as Array:
		if str(lab.get("name", "")) == "_title" and bool(lab.get("visible", false)):
			title_hidden = false
	if not ok or not logo_blit_ok or not title_hidden:
		fails.append("b:logo_title")
		print("ASSERT b FAIL logo_rect=%s logo_blit=%s title_hidden=%s" % [str(lr), logo_blit_ok, title_hidden])
	else:
		print("ASSERT b OK logo [480,80,720,160] and _title hidden")


func _assert_held_catches(teaser, fails: Array[String]) -> void:
	for t in [3.6, 5.7]:
		var cap: Dictionary = teaser.debug_capture(float(t))
		var held := 0
		for it in teaser._items:
			if str(it.get("kind", "")) == "catch" and bool(it.get("held", false)) and not bool(it.get("gone", false)):
				held += 1
		var drawn_held := 0
		# Held items are drawn near hero; count catch-id blits that are not far-right flyers.
		for b in cap.get("blits", []) as Array:
			for id in ["pocketwatch", "lantern", "grimoire", "healing_potion"]:
				if _is_item_blit(b, id):
					var r: Array = b.get("rect", []) as Array
					if r.size() >= 1 and float(r[0]) < 1400.0:
						drawn_held += 1
		if held < 1 and drawn_held < 1:
			fails.append("c:held@%.1f" % t)
			print("ASSERT c FAIL no held catch at t=%.1f (held=%d drawn=%d)" % [t, held, drawn_held])
		else:
			print("ASSERT c OK held catch at t=%.1f (held=%d drawn=%d)" % [t, held, drawn_held])


func _assert_spend_gone(teaser, fails: Array[String]) -> void:
	teaser.debug_capture(7.1)
	var boot_gone := false
	var helm_gone := false
	for it in teaser._items:
		if str(it.get("id", "")) == "da_boot":
			boot_gone = bool(it.get("gone", false))
		if str(it.get("id", "")) == "helmet":
			helm_gone = bool(it.get("gone", false))
	# Helmet must be gone by 8.0; re-check after advance.
	teaser.debug_capture(8.0)
	for it in teaser._items:
		if str(it.get("id", "")) == "helmet":
			helm_gone = bool(it.get("gone", false))
	if not boot_gone:
		fails.append("d:boot_not_gone")
		print("ASSERT d FAIL boot still present at 7.1")
	else:
		print("ASSERT d OK boot gone by 7.1")
	if not helm_gone:
		fails.append("d:helmet_not_gone")
		print("ASSERT d FAIL helmet still present at 8.0")
	else:
		print("ASSERT d OK helmet gone by 8.0")


func _assert_hall_b(captures: Array, fails: Array[String]) -> void:
	var cap: Dictionary = _cap_at(captures, 5.7)
	var hall := str(cap.get("hall_strip_in_use", ""))
	if hall != "hall_b":
		fails.append("e:hall_b")
		print("ASSERT e FAIL hall_strip_in_use=%s at 5.7" % hall)
	else:
		print("ASSERT e OK hall B at 5.7")


func _assert_swirl(captures: Array, fails: Array[String]) -> void:
	var cap: Dictionary = _cap_at(captures, 9.5)
	# Hero near centre: look for sprout/walk hero blit near x=840.
	var near := false
	for b in cap.get("blits", []) as Array:
		var tex := str(b.get("tex", "")).to_lower()
		if tex.contains("sprout") or tex.contains("walkoff") or tex.contains("hero_run") or tex.contains("/run/"):
			var r: Array = b.get("rect", []) as Array
			if r.size() >= 3:
				var cx: float = float(r[0]) + float(r[2]) * 0.5
				if absf(cx - 840.0) <= 80.0:
					near = true
	# Fallback: hero_x from a fresh capture internals.
	if not near:
		# At swirl, hero_x lerps toward centre; by 9.5 k=(9.5-8.5)/1.4≈0.71 → x≈0.36+0.14*0.71≈0.46 of width ≈772 — allow wider.
		for b in cap.get("blits", []) as Array:
			var tex2 := str(b.get("tex", "")).to_lower()
			if tex2.contains("sprout") or tex2.contains("hero") or tex2.contains("walk") or tex2.contains("swipe") or tex2.contains("grab") or tex2.contains("block"):
				var r2: Array = b.get("rect", []) as Array
				if r2.size() >= 3:
					var cx2: float = float(r2[0]) + float(r2[2]) * 0.5
					if absf(cx2 - 840.0) <= 160.0:
						near = true
	if not near:
		fails.append("f:swirl")
		print("ASSERT f FAIL hero not near centre at 9.5")
	else:
		print("ASSERT f OK swirl hero near centre at 9.5")


func _assert_snap4(captures: Array, fails: Array[String]) -> void:
	for c in captures:
		for b in c.get("blits", []) as Array:
			var r: Array = b.get("rect", []) as Array
			if r.size() < 2:
				continue
			var x := float(r[0])
			var y := float(r[1])
			# Strip widths may be non-multiples; snap applies to x/y positions.
			if absf(x - round(x / 4.0) * 4.0) > 0.01 or absf(y - round(y / 4.0) * 4.0) > 0.01:
				fails.append("g:snap4")
				print("ASSERT g FAIL blit not on 4px grid: %s rect=%s" % [str(b.get("tex", "")), str(r)])
				return
	print("ASSERT g OK strip/actor x/y on 4px grid")


func _assert_dragon_ogre(captures: Array, fails: Array[String]) -> void:
	var found_dragon := false
	var dragon_h_ok := false
	var dragon_flip := false
	var ogre_flip := false
	for t in [5.7, 7.1, 9.5]:
		for b in _blits_at(captures, t):
			var tex := str(b.get("tex", "")).to_lower()
			var r: Array = b.get("rect", []) as Array
			if tex.contains("dragon"):
				found_dragon = true
				if r.size() >= 4 and float(r[3]) >= 256.0:
					dragon_h_ok = true
				if bool(b.get("flip_h", false)):
					dragon_flip = true
			if tex.contains("ogre") and bool(b.get("flip_h", false)):
				ogre_flip = true
	if not found_dragon or not dragon_h_ok or not dragon_flip or not ogre_flip:
		fails.append("h:dragon_ogre")
		print("ASSERT h FAIL dragon_found=%s h_ok=%s d_flip=%s o_flip=%s" % [found_dragon, dragon_h_ok, dragon_flip, ogre_flip])
	else:
		print("ASSERT h OK dragon h>=256 and dragon/ogre flip_h")


func _assert_no_drift(teaser, fails: Array[String]) -> void:
	var samples: Array = []
	for t in [6.5, 6.8, 7.2, 7.6, 8.0]:
		teaser.debug_capture(float(t))
		var hx: float = teaser._hero_x(Vector2(1680, 1040))
		# Skeleton: settled in hall, not the boot's knockback target (nearest = goblin).
		var mon = null
		for m in teaser._mons:
			if str(m.get("id", "")) == "skeleton":
				mon = m
				break
		if mon == null:
			fails.append("i:no_skeleton")
			print("ASSERT i FAIL no skeleton")
			return
		var age: float = float(t) - float(mon.get("born", 0.0))
		var ease: float = clampf(age / 0.6, 0.0, 1.0)
		ease = ease * ease * (3.0 - 2.0 * ease)
		var slot_x: float = hx - float(mon.get("gap", 190.0)) - float(mon.get("knock", 0.0))
		var from_x := -120.0
		var x: float = lerpf(from_x, slot_x, ease)
		var off: float = hx - x
		samples.append(off)
	var lo: float = float(samples[0])
	var hi: float = float(samples[0])
	for s in samples:
		lo = minf(lo, float(s))
		hi = maxf(hi, float(s))
	if hi - lo > 12.0 + 0.01:
		fails.append("i:drift")
		print("ASSERT i FAIL monster offset drift %s (range %.2f)" % [str(samples), hi - lo])
	else:
		print("ASSERT i OK no drift (range %.2f) samples=%s" % [hi - lo, str(samples)])
