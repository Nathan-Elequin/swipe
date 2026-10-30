class_name BucketRules
extends RefCounted

const MAX_BUCKET := 5
const ASIDE := 0
const TOKEN := "Token"
const ASIDE_LABEL := "Aside"
const TOKEN_COLOR := Color("6e675c")
const ALWAYS_STARTER_ITEMS: PackedStringArray = ["smoke_bomb"]
## Second card of a pair. Same bucket as its partner; does not fill the 10/5.
const PAIR_EXTRA_ITEMS: PackedStringArray = ["bracers"]
const WANT_ZERO := 10
const WANT_LATER := 5
const LATER_PER_ROW := 5
const ZERO_TIERS: PackedInt32Array = [5, 3, 2]
const LATER_TIERS: PackedInt32Array = [2, 2, 1]
const TIER_BRONZE := Color("c08050")
const TIER_SILVER := Color("c5cdd8")
const TIER_GOLD := Color("e8c36a")


static func options() -> PackedStringArray:
	var out := PackedStringArray()
	for i in range(1, MAX_BUCKET + 1):
		out.append(str(i))
	out.append(TOKEN)
	out.append(ASIDE_LABEL)
	return out


static func of_card(card: Variant) -> int:
	if typeof(card) != TYPE_DICTIONARY:
		return ASIDE
	var d: Dictionary = card
	if d.has("pool"):
		return parse(d.get("pool"))
	return parse(d.get("bucket", 0))


static func parse(v: Variant) -> int:
	if v == null:
		return ASIDE
	if typeof(v) == TYPE_STRING:
		var s: String = str(v).strip_edges()
		if s == "":
			return ASIDE
		var low := s.to_lower()
		if low == "token":
			return -1
		if low == "aside" or low == "hold":
			return ASIDE
		if s.is_valid_int():
			return _clamp_pool(int(s))
		if s.is_valid_float():
			return _clamp_pool(int(float(s)))
		return ASIDE
	return _clamp_pool(int(v))


static func _clamp_pool(n: int) -> int:
	if n < 0:
		return -1
	if n == 0:
		return ASIDE
	if n > MAX_BUCKET:
		return ASIDE
	return n


static func label_of(v: Variant) -> String:
	var n: int = parse(v)
	if n < 0:
		return TOKEN
	if n == ASIDE:
		return ASIDE_LABEL
	return str(n)


static func is_token(v: Variant) -> bool:
	if typeof(v) == TYPE_DICTIONARY:
		return of_card(v) < 0
	return parse(v) < 0


static func is_aside_status(card: Variant) -> bool:
	if typeof(card) != TYPE_DICTIONARY:
		return true
	var st: String = str(card.get("status", "live"))
	return st == "retired" or st == "hold"


static func display_pool(card: Variant) -> int:
	if typeof(card) != TYPE_DICTIONARY:
		return ASIDE
	if is_token(card):
		return -1
	if is_aside_status(card):
		return ASIDE
	if _skip(card):
		return ASIDE
	var n: int = of_card(card)
	if n < 1 or n > MAX_BUCKET:
		return ASIDE
	return n


static func mix_line(items: Array, monsters: Array) -> String:
	return "Items %s  ·  Monsters %s" % [_mix_side(items, true), _mix_side(monsters, false)]


static func _mix_side(cards: Array, as_item: bool) -> String:
	var t := [0, 0, 0]
	var fam := {"A": 0, "D": 0, "C": 0, "U": 0}
	for card in cards:
		if typeof(card) != TYPE_DICTIONARY:
			continue
		t[tier_of(card) - 1] += 1
		if as_item:
			fam[item_family(card)] = int(fam[item_family(card)]) + 1
	var line := "T1 %s · T2 %s · T3 %s" % [t[0], t[1], t[2]]
	if as_item:
		line += " · A%s D%s C%s U%s" % [fam["A"], fam["D"], fam["C"], fam["U"]]
	return line


static func review_letter(card: Variant) -> String:
	var id: String = ReviewStage.of_card(card) if typeof(card) == TYPE_DICTIONARY else "polish"
	match id:
		"finished":
			return "F"
		"polish":
			return "P"
		"refined":
			return "R"
		"change":
			return "C"
		_:
			return "N"


static func review_color(card: Variant) -> Color:
	var id: String = ReviewStage.of_card(card) if typeof(card) == TYPE_DICTIONARY else "polish"
	if id == "finished":
		return Color("3ddc6a")
	if id == "change":
		return Color("ff2a2a")
	return Color("ffd84a")


static func color_of(n: int) -> Color:
	var cols: Array[Color] = [
		Color("5d8a45"),
		Color("2f6f9f"),
		Color("6d4c9a"),
		Color("b8860b"),
		Color("b85c2a"),
		Color("8f3048"),
		Color("1f6f6a"),
		Color("4a5a8a"),
		Color("7a5a2a"),
		Color("3d5a32"),
		Color("5a3d55"),
		Color("2a4a62"),
		Color("6a3a2a"),
	]
	var i: int = n
	if i < 0:
		i = 0
	return cols[i % cols.size()]


static func paint(e: OptionButton) -> void:
	if e == null or e.selected < 0:
		return
	var label: String = e.get_item_text(e.selected)
	var col: Color = TOKEN_COLOR if label == TOKEN or label == ASIDE_LABEL else color_of(parse(label))
	var ink: Color = ink_for(col)
	e.add_theme_color_override("font_color", ink)
	e.add_theme_color_override("font_hover_color", ink)
	e.add_theme_color_override("font_focus_color", ink)
	e.add_theme_color_override("font_pressed_color", ink)
	for state in ["normal", "hover", "pressed", "focus"]:
		var sb := StyleBoxFlat.new()
		sb.bg_color = col
		sb.border_color = col.darkened(0.28)
		sb.set_border_width_all(2 if state != "focus" else 3)
		sb.set_corner_radius_all(5)
		sb.content_margin_left = 8
		sb.content_margin_right = 8
		sb.content_margin_top = 4
		sb.content_margin_bottom = 4
		e.add_theme_stylebox_override(state, sb)


static func ink_for(col: Color) -> Color:
	if col.get_luminance() > 0.45:
		return Color("1c120c")
	return Color("f0e6d8")


static func tier_of(card: Variant) -> int:
	if typeof(card) != TYPE_DICTIONARY:
		return 1
	return maxi(1, mini(3, int(card.get("tier", 1))))


static func tier_color(tier: int) -> Color:
	if tier >= 3:
		return TIER_GOLD
	if tier == 2:
		return TIER_SILVER
	return TIER_BRONZE


static func tier_fill(tier: int) -> Color:
	if tier >= 3:
		return Color("f6e7c4")
	if tier == 2:
		return Color("dde3eb")
	return Color("f3ddcc")


static func tier_label(tier: int) -> String:
	if tier >= 3:
		return "Gold"
	if tier == 2:
		return "Silver"
	return "Bronze"


static func is_always_starter(card: Variant) -> bool:
	if typeof(card) != TYPE_DICTIONARY:
		return false
	return is_always_starter_id(str(card.get("id", "")))


static func is_always_starter_id(id: String) -> bool:
	return ALWAYS_STARTER_ITEMS.has(id)


static func counts_for_mill(card: Variant) -> bool:
	return not _skip(card)


static func item_family(card: Variant) -> String:
	if typeof(card) != TYPE_DICTIONARY:
		return "U"
	var col: String = str(card.get("card_color", "")).strip_edges().to_lower()
	if col == "atk":
		return "A"
	if col == "blk" or col == "heal":
		return "D"
	if col == "defeat":
		return "C"
	return "U"


static func family_fill(card: Variant) -> Color:
	match item_family(card):
		"A":
			return Color("5c2626")
		"D":
			return Color("1c3d52")
		"C":
			return Color("3a2450")
		_:
			return Color("4a3d14")


static func want_items(bucket: int) -> int:
	if bucket < 0:
		return 0
	return WANT_ZERO if bucket == 0 else WANT_LATER


static func want_monsters(bucket: int) -> int:
	return want_items(bucket)


static func want_tier(bucket: int, tier: int) -> int:
	if bucket < 0:
		return 0
	var t: int = maxi(1, mini(3, tier))
	if bucket == 0:
		return int(ZERO_TIERS[t - 1])
	return int(LATER_TIERS[t - 1])


static func is_unbalanced(bucket: int, item_n: int, monster_n: int, last_used: int = -1) -> bool:
	if bucket < 0:
		return false
	if item_n == 0 and monster_n == 0:
		return false
	var want: int = want_items(bucket)
	if last_used >= 0 and bucket == last_used:
		if item_n > want or monster_n > want:
			return true
		if item_n <= 0 or monster_n <= 0:
			return true
		return false
	return item_n != want or monster_n != want_monsters(bucket)


static func counts_warning(_items: Array, _monsters: Array) -> String:
	return ""


static func _counts_warning_legacy(items: Array, monsters: Array) -> String:
	var tallied: Dictionary = tally(items, monsters)
	var nums: Array = tallied.keys()
	nums.sort()
	var last_used: int = -1
	for raw0 in nums:
		var b0: int = int(raw0)
		if b0 < 0:
			continue
		var pair0: Dictionary = tallied[raw0]
		if int(pair0.get("items", 0)) > 0 or int(pair0.get("monsters", 0)) > 0:
			last_used = b0
	var lines: PackedStringArray = PackedStringArray()
	for raw in nums:
		var b3: int = int(raw)
		if b3 < 0:
			continue
		var pair: Dictionary = tallied[raw]
		var ni: int = int(pair.get("items", 0))
		var nm: int = int(pair.get("monsters", 0))
		if not is_unbalanced(b3, ni, nm, last_used):
			continue
		var want: int = want_items(b3)
		lines.append("Bucket %s has %s items and %s monsters. It should be %s and %s." % [b3, ni, nm, want, want])
	for extra in tier_warning_lines(items, monsters):
		lines.append(str(extra))
	return "\n".join(lines)


static func missing_tiers(cards: Array) -> PackedInt32Array:
	var seen := [false, false, false, false]
	var n: int = 0
	for card in cards:
		if typeof(card) != TYPE_DICTIONARY:
			continue
		var st: String = str(card.get("status", "live"))
		if st == "retired" or st == "hold":
			continue
		n += 1
		seen[tier_of(card)] = true
	var out := PackedInt32Array()
	if n < 3:
		return out
	for t in range(1, 4):
		if not seen[t]:
			out.append(t)
	return out


static func tier_warning_lines(items: Array, monsters: Array) -> PackedStringArray:
	var by_b: Dictionary = {}
	for card in items:
		if typeof(card) != TYPE_DICTIONARY:
			continue
		var st: String = str(card.get("status", "live"))
		if st == "retired" or st == "hold":
			continue
		var b: int = of_card(card)
		if b < 0:
			continue
		if not by_b.has(b):
			by_b[b] = {"item": [], "monster": []}
		(by_b[b]["item"] as Array).append(card)
	for card2 in monsters:
		if typeof(card2) != TYPE_DICTIONARY:
			continue
		var st2: String = str(card2.get("status", "live"))
		if st2 == "retired" or st2 == "hold":
			continue
		var b2: int = of_card(card2)
		if b2 < 0:
			continue
		if not by_b.has(b2):
			by_b[b2] = {"item": [], "monster": []}
		(by_b[b2]["monster"] as Array).append(card2)
	var nums: Array = by_b.keys()
	nums.sort()
	var lines := PackedStringArray()
	for raw in nums:
		var b3: int = int(raw)
		var pair: Dictionary = by_b[raw]
		_append_tier_gap(lines, b3, "items", pair["item"])
		_append_tier_gap(lines, b3, "monsters", pair["monster"])
	return lines


static func _append_tier_gap(lines: PackedStringArray, bucket: int, side: String, cards: Array) -> void:
	var miss: PackedInt32Array = missing_tiers(cards)
	if miss.is_empty():
		return
	var names: PackedStringArray = PackedStringArray()
	for t in miss:
		names.append(tier_label(int(t)).to_lower())
	lines.append("Bucket %s %s are missing %s." % [bucket, side, " and ".join(names)])


static func tally(items: Array, monsters: Array) -> Dictionary:
	var out := {}
	for card in items:
		if _skip(card):
			continue
		var b: int = of_card(card)
		if not out.has(b):
			out[b] = {"items": 0, "monsters": 0}
		out[b]["items"] = int(out[b]["items"]) + 1
	for card2 in monsters:
		if _skip(card2):
			continue
		var b2: int = of_card(card2)
		if not out.has(b2):
			out[b2] = {"items": 0, "monsters": 0}
		out[b2]["monsters"] = int(out[b2]["monsters"]) + 1
	return out


static func pool_count(cards: Array) -> int:
	var n: int = 0
	for card in cards:
		if _skip(card):
			continue
		n += 1
	return n


static func _skip(card: Variant) -> bool:
	if typeof(card) != TYPE_DICTIONARY:
		return true
	var st: String = str(card.get("status", "live"))
	if st == "retired" or st == "hold":
		return true
	if is_token(card):
		return true
	if is_always_starter(card):
		return true
	if PAIR_EXTRA_ITEMS.has(str(card.get("id", ""))):
		return true
	var mode: String = str(card.get("mode_pool", "all")).strip_edges().to_lower()
	mode = mode.replace(" ", "").replace("_", "-")
	if mode != "" and mode != "all":
		return true
	return false
