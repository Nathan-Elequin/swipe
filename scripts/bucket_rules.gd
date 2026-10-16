class_name BucketRules
extends RefCounted

const MAX_BUCKET := 12
const TOKEN := "Token"
const TOKEN_COLOR := Color("6e675c")
const ALWAYS_STARTER_ITEMS: PackedStringArray = ["smoke_bomb"]
const WANT_ZERO := 9
const WANT_LATER := 4
const LATER_PER_ROW := 4
const TIER_BRONZE := Color("c08050")
const TIER_SILVER := Color("6e7f96")
const TIER_GOLD := Color("e8c36a")


static func options() -> PackedStringArray:
	var out := PackedStringArray()
	for i in range(MAX_BUCKET + 1):
		out.append(str(i))
	out.append(TOKEN)
	return out


static func parse(v: Variant) -> int:
	if v == null:
		return 0
	if typeof(v) == TYPE_STRING:
		var s: String = str(v).strip_edges()
		if s == "":
			return 0
		if s.to_lower() == "token":
			return -1
		if s.is_valid_int():
			return int(s)
		if s.is_valid_float():
			return int(float(s))
		return 0
	return int(v)


static func label_of(v: Variant) -> String:
	if parse(v) < 0:
		return TOKEN
	return str(parse(v))


static func is_token(v: Variant) -> bool:
	return parse(v) < 0


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
	var col: Color = TOKEN_COLOR if label == TOKEN else color_of(int(label))
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


static func want_items(bucket: int) -> int:
	if bucket < 0:
		return 0
	return WANT_ZERO if bucket == 0 else WANT_LATER


static func want_monsters(bucket: int) -> int:
	return want_items(bucket)


static func is_unbalanced(bucket: int, item_n: int, monster_n: int) -> bool:
	if bucket < 0:
		return false
	if item_n == 0 and monster_n == 0:
		return false
	return item_n != want_items(bucket) or monster_n != want_monsters(bucket)


static func counts_warning(items: Array, monsters: Array) -> String:
	var tallied: Dictionary = tally(items, monsters)
	var nums: Array = tallied.keys()
	nums.sort()
	var lines: PackedStringArray = PackedStringArray()
	for raw in nums:
		var b3: int = int(raw)
		if b3 < 0:
			continue
		var pair: Dictionary = tallied[raw]
		var ni: int = int(pair.get("items", 0))
		var nm: int = int(pair.get("monsters", 0))
		if not is_unbalanced(b3, ni, nm):
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
		var b: int = parse(card.get("bucket", 0))
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
		var b2: int = parse(card2.get("bucket", 0))
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
		var b: int = parse(card.get("bucket", 0))
		if not out.has(b):
			out[b] = {"items": 0, "monsters": 0}
		out[b]["items"] = int(out[b]["items"]) + 1
	for card2 in monsters:
		if _skip(card2):
			continue
		var b2: int = parse(card2.get("bucket", 0))
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
	if is_token(card.get("bucket", 0)):
		return true
	return is_always_starter(card)
