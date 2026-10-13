class_name BucketRules
extends RefCounted

const MAX_BUCKET := 12
const TOKEN := "Token"
const TOKEN_COLOR := Color("6e675c")


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


static func counts_warning(items: Array, monsters: Array) -> String:
	var item_n := {}
	var monster_n := {}
	for card in items:
		if _skip(card):
			continue
		var b: int = int(card.get("bucket", 0))
		item_n[b] = int(item_n.get(b, 0)) + 1
	for card2 in monsters:
		if _skip(card2):
			continue
		var b2: int = int(card2.get("bucket", 0))
		monster_n[b2] = int(monster_n.get(b2, 0)) + 1
	var seen := {}
	for k in item_n.keys():
		seen[k] = true
	for k2 in monster_n.keys():
		seen[k2] = true
	var nums: Array = seen.keys()
	nums.sort()
	var lines: PackedStringArray = PackedStringArray()
	for raw in nums:
		var b3: int = int(raw)
		var ni: int = int(item_n.get(b3, 0))
		var nm: int = int(monster_n.get(b3, 0))
		if ni == 0 and nm == 0:
			continue
		if b3 == 0:
			if ni != 9 or nm != 9:
				lines.append("Bucket 0 has %s items and %s monsters. It should be 9 and 9." % [ni, nm])
		elif ni != 3 or nm != 3:
			lines.append("Bucket %s has %s items and %s monsters. It should be 3 and 3." % [b3, ni, nm])
	return "\n".join(lines)


static func _skip(card: Variant) -> bool:
	if typeof(card) != TYPE_DICTIONARY:
		return true
	var st: String = str(card.get("status", "live"))
	if st == "retired" or st == "hold":
		return true
	return is_token(card.get("bucket", 0))
