class_name BiomeCabinets
extends RefCounted
## Five biome trophy cases + fixed peg pages. Hall chrome lives in TrophyCase.
## Legacy frame PNGs (incl. sunken_mire) stay on disk unused by the hall.

const _SHELL := preload("res://scripts/campaign_shell.gd")


## Full room native bounds — hall hole no longer clips crowns / plaques / lamps.
const CASES_BOUNDS: Array = [0, 0, 420, 260]

## Native glass interiors per pool. Order = CASES.
## b2 window is canvas (6,44) on the Crystal Cavern body at room (132,24)
## → CASE_GLASS[1] = (138,68,48,121).
const CASE_GLASS: Array = [
	[82, 68, 48, 121],
	[138, 68, 48, 121],
	[202, 68, 48, 121],
	[262, 68, 48, 121],
	[322, 68, 48, 121],
]

## Outer case rects (room native). Sheet / gild / hit use these.
const CASE_OUTER: Array = [
	[75, 37, 48, 163],
	[132, 24, 60, 176],
	[198, 38, 48, 162],
	[259, 38, 48, 162],
	[320, 38, 48, 162],
]

## Crown label rects (room native).
const CASE_CROWN: Array = [
	[77, 40, 44, 13],
	[137, 40, 44, 13],
	[200, 44, 44, 11],
	[261, 40, 44, 13],
	[322, 40, 44, 13],
]

## Lamp top-centre anchors (room native).
const CASE_LAMP: Array = [
	[99, 22],
	[159, 14],
	[222, 22],
	[283, 22],
	[344, 22],
]

## Brass plaque rects (room native).
const CASE_PLAQUE: Array = [
	[76, 201, 46, 12],
	[137, 201, 46, 12],
	[199, 201, 46, 12],
	[260, 201, 46, 12],
	[321, 201, 46, 12],
]

## PageBar strip on the case base (glass.x, 190, 48, 6).
const PAGE_BAR_Y := 190
const PAGE_BAR_H := 6
const PAGE_SLOTS := 10

## Shape key per case index: rect / spires / arch.
const CASE_SHAPE: Array = ["rect", "spires", "arch", "rect", "rect"]

## Sheet / gild origin offsets for spires (room native). Others = glass − (8,32).
const SPIRES_SHEET_ORIGIN := Vector2(126, 22)

enum CaseState { LOCKED, IN_PROGRESS, OPENED, COMPLETE }
enum PegState { UNSEEN, SEEN, CLAIMED }
enum PageState { PAGE_OPEN, PAGE_FULL }

const CASES: Array = [
	{
		"id": "b1",
		"name": "Verdant Hollow",
		"tint": "1c3320",
		"accent": "7dae62",
		"frame": "cabinets/case_verdant_hollow",
		"trophy": "cabinets/trophy_verdant_hollow",
		"shape": "rect",
	},
	{
		"id": "b2",
		"name": "Crystal Cavern",
		"tint": "2a4a60",
		"accent": "b4d6ea",
		"frame": "cabinets/case_crystal_cavern",
		"trophy": "cabinets/trophy_crystal_cavern",
		"shape": "spires",
	},
	{
		"id": "b3",
		"name": "Ashen Crypt",
		"tint": "2c2828",
		"accent": "a8a29a",
		"frame": "cabinets/case_ashen_crypt",
		"trophy": "cabinets/trophy_ashen_crypt",
		"shape": "arch",
	},
	{
		"id": "b4",
		"name": "Cinder Forge",
		"tint": "241812",
		"accent": "d06a28",
		"frame": "cabinets/case_cinder_forge",
		"trophy": "cabinets/trophy_cinder_forge",
		"shape": "rect",
	},
	{
		"id": "b5",
		"name": "Shadow Abyss",
		"tint": "100e18",
		"accent": "4c4588",
		"frame": "cabinets/case_shadow_abyss",
		"trophy": "cabinets/trophy_shadow_abyss",
		"shape": "rect",
	},
]


## Null-safe biome trophy for a filled case slot. PNGs are 96×96 (24 native ×4).
static func trophy_texture(case: Dictionary, hover := false) -> Texture2D:
	var stem := str(case.get("trophy", ""))
	if stem == "":
		return null
	var path := "res://assets/dungeon/home/%s%s.png" % [stem, "_hover" if hover else ""]
	if not ResourceLoader.exists(path):
		return null
	var tex: Variant = load(path)
	if tex is Texture2D:
		return tex as Texture2D
	return null


static func trophy_grey_texture(case: Dictionary) -> Texture2D:
	var stem := str(case.get("trophy", ""))
	if stem == "":
		return null
	var path := "res://assets/dungeon/home/%s_grey.png" % stem
	if not ResourceLoader.exists(path):
		return trophy_texture(case, false)
	var tex: Variant = load(path)
	if tex is Texture2D:
		return tex as Texture2D
	return null


## Native trophy face size (art is 24×24; PNG ships at 96 = 24×4).
const TROPHY_NATIVE := 24.0
const TROPHY_PAD_TOP_NATIVE := 2.0
const TROPHY_GAP_BELOW_NATIVE := 2.0


## Local rect for the pedestal trophy inside a glass Control (case pixels).
## Kept for callers outside the hall; hall uses crest instead.
static func trophy_local_rect(glass_size: Vector2, case_scale: float) -> Rect2:
	var s: float = maxf(case_scale, 0.001)
	var tsize := Vector2(TROPHY_NATIVE, TROPHY_NATIVE) * s
	var pad_top: float = TROPHY_PAD_TOP_NATIVE * s
	var x: float = (glass_size.x - tsize.x) * 0.5
	var y: float = pad_top
	if y + tsize.y > glass_size.y:
		y = maxf(0.0, glass_size.y - tsize.y)
	return Rect2(Vector2(x, y), tsize)


static func trophy_reserved_height(glass_size: Vector2, case_scale: float) -> float:
	var r := trophy_local_rect(glass_size, case_scale)
	var gap: float = TROPHY_GAP_BELOW_NATIVE * maxf(case_scale, 0.001)
	return minf(glass_size.y, r.position.y + r.size.y + gap)


const PEG_FIT_MAX := 6
const PEG_SCALE_MAX := 0.55


static func peg_column_height(n: int, msize_y: float, gap_y: float, pad_top: float) -> float:
	var count: int = maxi(0, n)
	if count <= 0:
		return pad_top
	return pad_top + float(count) * msize_y + float(count - 1) * gap_y


## Legacy vertical column layout — kept for non-hall callers / selftests.
static func peg_column_layout(clip_size: Vector2, cell: Vector2, peg_count: int) -> Dictionary:
	var cw: float = maxf(1.0, clip_size.x)
	var ch: float = maxf(1.0, clip_size.y)
	var cell_x: float = maxf(1.0, cell.x)
	var cell_y: float = maxf(1.0, cell.y)
	var n_fit: int = clampi(maxi(peg_count, 1), 1, PEG_FIT_MAX)
	var max_s: float = PEG_SCALE_MAX
	max_s = minf(max_s, maxf(0.05, (cw - 6.0) / cell_x))
	var max_w: int = maxi(8, int(floor(cell_x * max_s)))
	var gap_order: Array = [2, 3, 4, 1, 0]
	var pad_order: Array = [2, 3, 4, 1, 0]
	for gap_v in gap_order:
		var gap: int = int(gap_v)
		for pad_v in pad_order:
			var pad: int = int(pad_v)
			for w in range(max_w, 7, -1):
				var h: int = maxi(1, int(round(cell_y * float(w) / cell_x)))
				var need: float = peg_column_height(n_fit, float(h), float(gap), float(pad))
				if need > ch + 0.01:
					continue
				return {
					"msize": Vector2(float(w), float(h)),
					"gap_y": float(gap),
					"pad_top": float(pad),
					"x0": maxf(0.0, floor((cw - float(w)) * 0.5)),
				}
	var h_fallback: int = maxi(8, int(floor(ch / float(n_fit))))
	var w_fallback: int = maxi(8, int(round(float(h_fallback) * cell_x / cell_y)))
	w_fallback = mini(w_fallback, maxi(8, int(floor(cw - 6.0))))
	h_fallback = maxi(8, int(round(float(w_fallback) * cell_y / cell_x)))
	while peg_column_height(n_fit, float(h_fallback), 0.0, 0.0) > ch and h_fallback > 8:
		h_fallback -= 1
		w_fallback = maxi(8, int(round(float(h_fallback) * cell_y / cell_x)))
	return {
		"msize": Vector2(float(w_fallback), float(h_fallback)),
		"gap_y": 0.0,
		"pad_top": 0.0,
		"x0": maxf(0.0, floor((cw - float(w_fallback)) * 0.5)),
	}


static func cases_bounds_rect() -> Rect2:
	return Rect2(
		float(CASES_BOUNDS[0]),
		float(CASES_BOUNDS[1]),
		float(CASES_BOUNDS[2]),
		float(CASES_BOUNDS[3])
	)


static func glass_rect(index: int) -> Rect2:
	if index < 0 or index >= CASE_GLASS.size():
		return Rect2()
	var g: Array = CASE_GLASS[index]
	return Rect2(float(g[0]), float(g[1]), float(g[2]), float(g[3]))


static func outer_rect(index: int) -> Rect2:
	if index < 0 or index >= CASE_OUTER.size():
		return Rect2()
	var g: Array = CASE_OUTER[index]
	return Rect2(float(g[0]), float(g[1]), float(g[2]), float(g[3]))


static func crown_rect(index: int) -> Rect2:
	if index < 0 or index >= CASE_CROWN.size():
		return Rect2()
	var g: Array = CASE_CROWN[index]
	return Rect2(float(g[0]), float(g[1]), float(g[2]), float(g[3]))


static func lamp_anchor(index: int) -> Vector2:
	if index < 0 or index >= CASE_LAMP.size():
		return Vector2.ZERO
	var g: Array = CASE_LAMP[index]
	return Vector2(float(g[0]), float(g[1]))


static func plaque_rect(index: int) -> Rect2:
	if index < 0 or index >= CASE_PLAQUE.size():
		return Rect2()
	var g: Array = CASE_PLAQUE[index]
	return Rect2(float(g[0]), float(g[1]), float(g[2]), float(g[3]))


static func shape_of(index: int) -> String:
	if index < 0 or index >= CASE_SHAPE.size():
		return "rect"
	return str(CASE_SHAPE[index])


static func case_index(pool: String) -> int:
	for i in CASES.size():
		if str((CASES[i] as Dictionary).get("id", "")) == pool:
			return i
	return -1


const STUB_NAMES := {
	"The Cellar": "Verdant Hollow",
	"The Warren": "Crystal Cavern",
	"The Chapel": "Ashen Crypt",
	"The Vault": "Cinder Forge",
	"The Throat": "Shadow Abyss",
	"Torch Burrow": "Verdant Hollow",
	"Slime Pits": "Crystal Cavern",
	"Bone Gallery": "Ashen Crypt",
	"Bog Mother": "Cinder Forge",
	"Gulp King": "Shadow Abyss",
	"Sunken Mire": "Crystal Cavern",
}


static func resolved_cases(rules: Dictionary) -> Array:
	var names := {}
	var raw_biomes: Variant = rules.get("biomes", [])
	if typeof(raw_biomes) == TYPE_ARRAY:
		for raw in raw_biomes:
			if typeof(raw) != TYPE_DICTIONARY:
				continue
			var biome: Dictionary = raw
			names[str(biome.get("id", ""))] = str(biome.get("name", ""))
	var out: Array = []
	for raw_spec in CASES:
		var spec: Dictionary = (raw_spec as Dictionary).duplicate()
		var fallback := str(spec.get("name", ""))
		var from_rules := str(names.get(str(spec.get("id", "")), ""))
		spec["name"] = display_name(from_rules, fallback)
		out.append(spec)
	return out


static func case_names(rules: Dictionary) -> Array:
	var out: Array = []
	for raw in resolved_cases(rules):
		out.append(str((raw as Dictionary).get("name", "")))
	return out


static func display_name(rules_name: String, fallback: String) -> String:
	var n := rules_name.strip_edges()
	if STUB_NAMES.has(n):
		return str(STUB_NAMES[n])
	if n == "":
		return fallback
	return n


static func quota_of(rules: Dictionary) -> int:
	var q := int(rules.get("cabinet_quota", 5))
	if q <= 0:
		return 5
	return q


static func pool_for_bucket(rules: Dictionary, bucket: int) -> String:
	if bucket < 1:
		return ""
	var map: Variant = rules.get("card_pools", rules.get("bucket_pools", {}))
	if typeof(map) == TYPE_DICTIONARY:
		var mapped := str((map as Dictionary).get(str(bucket), ""))
		if mapped != "":
			return mapped
	var n: int = mini(5, bucket)
	return "b%d" % n


## Collected ids stay in swipe order. Legacy helper — hall uses fixed_slots instead.
static func order_mounts(cards: Array, swiped_order: Array) -> Array:
	var by_id := {}
	for raw in cards:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var card: Dictionary = raw
		by_id[str(card.get("id", ""))] = card
	var out: Array = []
	for raw_id in swiped_order:
		var id := str(raw_id)
		if not by_id.has(id):
			continue
		out.append(by_id[id])
		by_id.erase(id)
	var rest: Array = []
	for key in by_id.keys():
		rest.append(by_id[key])
	rest.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var ha := int(str(a.get("id", "")).hash())
		var hb := int(str(b.get("id", "")).hash())
		if ha == hb:
			return str(a.get("id", "")) < str(b.get("id", ""))
		return ha < hb
	)
	for raw_rest in rest:
		out.append(raw_rest)
	return out


## Stable fixed peg order: tier asc, name asc, id asc. Never trims the pool.
static func fixed_slots(cards: Array) -> Array:
	var out: Array = []
	for raw in cards:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		out.append(raw)
	out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var ta := int(a.get("tier", 1))
		var tb := int(b.get("tier", 1))
		if ta != tb:
			return ta < tb
		var na := str(a.get("name", "")).to_lower()
		var nb := str(b.get("name", "")).to_lower()
		if na != nb:
			return na < nb
		return str(a.get("id", "")) < str(b.get("id", ""))
	)
	return out


static func page_count(n: int) -> int:
	return maxi(1, int(ceili(float(maxi(0, n)) / float(PAGE_SLOTS))))


static func slot_page(i: int) -> int:
	if i < 0:
		return 0
	return int(i / PAGE_SLOTS)


static func slot_cell(i: int) -> Vector2i:
	## local slot → column (i%10)%2, row (i%10)/2
	var local := i % PAGE_SLOTS
	if local < 0:
		local = 0
	return Vector2i(local % 2, int(local / 2))


static func page_state(slot_ids: Array, page: int, banked: Dictionary) -> int:
	var start := page * PAGE_SLOTS
	var end := mini(slot_ids.size(), start + PAGE_SLOTS)
	if start >= end:
		return PageState.PAGE_FULL
	for i in range(start, end):
		var id := str(slot_ids[i])
		if id == "" or not banked.has(id):
			return PageState.PAGE_OPEN
	return PageState.PAGE_FULL


static func crown_text(claimed: int, total: int) -> String:
	return "%d/%d" % [maxi(0, claimed), maxi(0, total)]


static func pips_lit(count: int, quota: int) -> int:
	return mini(maxi(0, count), maxi(0, quota))


## Derive case state from campaign unlock + claimed counts.
## slot_ids = fixed_slots ids for the pool (all pages). claimed_ids = set of claimed.
static func case_state(rules: Dictionary, state: Dictionary, pool: String, slot_ids: Array, claimed_ids: Dictionary = {}) -> int:
	if not _SHELL.pool_unlocked(rules, state, pool):
		return CaseState.LOCKED
	var claimed := 0
	var banked: Dictionary = claimed_ids
	if banked.is_empty():
		var raw: Variant = state.get("banked", {})
		if typeof(raw) == TYPE_DICTIONARY:
			banked = raw as Dictionary
	var all_claimed := slot_ids.size() > 0
	for raw_id in slot_ids:
		var id := str(raw_id)
		if id == "":
			continue
		if banked.has(id):
			claimed += 1
		else:
			all_claimed = false
	if slot_ids.is_empty():
		all_claimed = false
	if all_claimed and slot_ids.size() > 0:
		return CaseState.COMPLETE
	var quota := quota_of(rules)
	var cab: int = int(_SHELL.cabinet_count(state, pool))
	## Prefer explicit claimed_ids size when provided (bank-hold aware).
	if not claimed_ids.is_empty():
		cab = claimed
	if cab >= quota:
		return CaseState.OPENED
	return CaseState.IN_PROGRESS


static func peg_state(id: String, banked: Dictionary, seen: Dictionary) -> int:
	var sid := str(id)
	if banked.has(sid):
		return PegState.CLAIMED
	if seen.has(sid) and bool(seen[sid]):
		return PegState.SEEN
	return PegState.UNSEEN


## Crown over the case: legacy n/5 while climbing — hall uses crown_text instead.
static func progress_text(collected: int, total: int, quota: int = 5) -> String:
	if collected < quota:
		return "%d/%d" % [collected, quota]
	return "%d/%d" % [quota, quota]


static func past_gate(collected: int, quota: int = 5) -> bool:
	return collected >= quota


static func next_piece_need(collected: int, quota: int = 5) -> int:
	return maxi(0, quota - collected)


static func crossed_gate(before: int, after: int, quota: int = 5) -> bool:
	return before < quota and after >= quota


static func bank_sequence(ids: Array, pools_by_id: Dictionary) -> Array:
	var out: Array = []
	for raw in ids:
		var id := str(raw)
		if id == "":
			continue
		out.append({
			"id": id,
			"pool": str(pools_by_id.get(id, "")),
		})
	return out


## Hall zoom target: RoomHall sits at layout x = room_index * ROOM_W (e.g. 6720).
## Spec clamps the *offset* from the room origin, not absolute position — otherwise
## the tween drives the hall toward 0 and leaves a black viewport.
static func hall_zoom_offset(
	case_center: Vector2,
	vp_center: Vector2 = Vector2(840, 520),
	room_size: Vector2 = Vector2(1680, 1040)
) -> Vector2:
	var offset := vp_center - case_center * 2.0
	offset.x = clampf(offset.x, -room_size.x, 0.0)
	offset.y = clampf(offset.y, -room_size.y, 0.0)
	return offset


static func hall_zoom_target(
	pre_pos: Vector2,
	case_center: Vector2,
	vp_center: Vector2 = Vector2(840, 520),
	room_size: Vector2 = Vector2(1680, 1040)
) -> Vector2:
	return pre_pos + hall_zoom_offset(case_center, vp_center, room_size)


## Clip-space rect of a case after 2× zoom, when rooms_host is snapped to pre_pos
## (rooms_host.position = -pre_pos). True when it intersects the 1680×1040 viewport.
static func hall_zoom_case_in_viewport(
	pre_pos: Vector2,
	case_rect: Rect2,
	vp_size: Vector2 = Vector2(1680, 1040),
	vp_center: Vector2 = Vector2(840, 520)
) -> bool:
	var target := hall_zoom_target(pre_pos, case_rect.position + case_rect.size * 0.5, vp_center, vp_size)
	## visible = rooms_host + hall_pos + local * scale = -pre + target + local * 2
	var origin := target - pre_pos + case_rect.position * 2.0
	var zoomed := Rect2(origin, case_rect.size * 2.0)
	return zoomed.intersects(Rect2(Vector2.ZERO, vp_size))


## First page index that still has an unclaimed item, or 0 if Complete / empty.
static func default_page(slot_ids: Array, banked: Dictionary) -> int:
	for i in slot_ids.size():
		var id := str(slot_ids[i])
		if id != "" and not banked.has(id):
			return slot_page(i)
	return 0
