class_name BiomeCabinets
extends RefCounted
## Five vertical trophy cases, one per biome pool.
## Visual source of truth is the Doop plate `rooms/cabinets_wall.png` (1680×1040).
## Live overlays are hit-only + slot icons aligned to CASE_GLASS — do not redraw case frames.
## Legacy frame PNGs kept on disk for reference / tooling; hall no longer paints them:
##   res://assets/dungeon/home/cabinets/case_verdant_hollow.png
##   res://assets/dungeon/home/cabinets/case_sunken_mire.png
##   res://assets/dungeon/home/cabinets/case_ashen_crypt.png
##   res://assets/dungeon/home/cabinets/case_cinder_forge.png
##   res://assets/dungeon/home/cabinets/case_shadow_abyss.png


## Native (420×260) rect covering all five plate cases. Hall `_hole` uses this.
const CASES_BOUNDS: Array = [76, 56, 298, 160]

## Native glass interiors per pool (inset inside each plate case). Order = CASES.
## Slot pitch: centers 60 native apart (240px at ×4). Doop SHIP-D cabs sit at
## left 300/544/788/1032/1276 (pitch 244) — within 4px; overlays keep CASE_GLASS.
## Height 121 (not 138): painted glass ends above the case accent/base on
## cabinets_wall.png; the old 138 spilled pegs onto the base and floor planks.
const CASE_GLASS: Array = [
	[82, 68, 48, 121],
	[142, 68, 48, 121],
	[202, 68, 48, 121],
	[262, 68, 48, 121],
	[322, 68, 48, 121],
]

const CASES: Array = [
	{
		"id": "b1",
		"name": "Verdant Hollow",
		"tint": "1c3320",
		"accent": "7dae62",
		"frame": "cabinets/case_verdant_hollow",
		"trophy": "cabinets/trophy_verdant_hollow",
	},
	{
		"id": "b2",
		"name": "Sunken Mire",
		"tint": "2a2916",
		"accent": "8a7a3e",
		"frame": "cabinets/case_sunken_mire",
		"trophy": "cabinets/trophy_sunken_mire",
	},
	{
		"id": "b3",
		"name": "Ashen Crypt",
		"tint": "2c2828",
		"accent": "8d3d3d",
		"frame": "cabinets/case_ashen_crypt",
		"trophy": "cabinets/trophy_ashen_crypt",
	},
	{
		"id": "b4",
		"name": "Cinder Forge",
		"tint": "241812",
		"accent": "d06a28",
		"frame": "cabinets/case_cinder_forge",
		"trophy": "cabinets/trophy_cinder_forge",
	},
	{
		"id": "b5",
		"name": "Shadow Abyss",
		"tint": "100e18",
		"accent": "4c4588",
		"frame": "cabinets/case_shadow_abyss",
		"trophy": "cabinets/trophy_shadow_abyss",
	},
]


## Null-safe biome trophy for a filled case slot. PNGs are 96×96 (24 native ×4);
## draw at Vector2(24, 24) * case_scale — never the full 96px at 1× case scale.
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


## Native trophy face size (art is 24×24; PNG ships at 96 = 24×4).
const TROPHY_NATIVE := 24.0
## Inset from the glass top so the pedestal clears the painted frame rim.
const TROPHY_PAD_TOP_NATIVE := 2.0
## Gap under the trophy before peg mounts begin (keeps shields clear).
const TROPHY_GAP_BELOW_NATIVE := 2.0


## Local rect for the pedestal trophy inside a glass Control (case pixels).
## Top-centered so it stays inside every CASE_GLASS shape (incl. arched b3)
## and never sits on the case base / peg column floor.
static func trophy_local_rect(glass_size: Vector2, case_scale: float) -> Rect2:
	var s: float = maxf(case_scale, 0.001)
	var tsize := Vector2(TROPHY_NATIVE, TROPHY_NATIVE) * s
	var pad_top: float = TROPHY_PAD_TOP_NATIVE * s
	var x: float = (glass_size.x - tsize.x) * 0.5
	var y: float = pad_top
	if y + tsize.y > glass_size.y:
		y = maxf(0.0, glass_size.y - tsize.y)
	return Rect2(Vector2(x, y), tsize)


## Peg-clip top inset when a trophy is shown: trophy band + gap, clamped to glass.
static func trophy_reserved_height(glass_size: Vector2, case_scale: float) -> float:
	var r := trophy_local_rect(glass_size, case_scale)
	var gap: float = TROPHY_GAP_BELOW_NATIVE * maxf(case_scale, 0.001)
	return minf(glass_size.y, r.position.y + r.size.y + gap)


## How many peg shields must fully fit in the glass column (more scroll).
## Live pools hold more items; cabinets scroll past this. Six matches a filled
## Middle Progress / fill_b1 column and the painted glass capacity.
const PEG_FIT_MAX := 6
## Preferred max scale for trophy_mount (128×160) inside a case clip.
const PEG_SCALE_MAX := 0.55


## Column height for n pegs at the given size / gap / top pad.
static func peg_column_height(n: int, msize_y: float, gap_y: float, pad_top: float) -> float:
	var count: int = maxi(0, n)
	if count <= 0:
		return pad_top
	return pad_top + float(count) * msize_y + float(count - 1) * gap_y


## Vertical peg column layout inside a glass Clip.
## Returns { msize, gap_y, pad_top, x0 } with integer-pixel msize (Nearest-safe).
## Fits up to PEG_FIT_MAX pegs fully inside clip_size.y; extra pegs scroll.
## Prefers gap/pad of 2 with a slightly smaller integer step; falls back to
## tighter spacing or larger pegs. Does not change art.
static func peg_column_layout(clip_size: Vector2, cell: Vector2, peg_count: int) -> Dictionary:
	var cw: float = maxf(1.0, clip_size.x)
	var ch: float = maxf(1.0, clip_size.y)
	var cell_x: float = maxf(1.0, cell.x)
	var cell_y: float = maxf(1.0, cell.y)
	var n_fit: int = clampi(maxi(peg_count, 1), 1, PEG_FIT_MAX)
	var max_s: float = PEG_SCALE_MAX
	max_s = minf(max_s, maxf(0.05, (cw - 6.0) / cell_x))
	var max_w: int = maxi(8, int(floor(cell_x * max_s)))
	## Prefer a little spacing (gap/pad 2) with a slightly smaller integer step,
	## then allow tighter / larger pegs. Never use a non-integer pixel size.
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
	## Fallback: shrink until PEG_FIT_MAX fits with zero gap/pad.
	var h_fallback: int = maxi(8, int(floor(ch / float(n_fit))))
	var w_fallback: int = maxi(8, int(round(float(h_fallback) * cell_x / cell_y)))
	w_fallback = mini(w_fallback, maxi(8, int(floor(cw - 6.0))))
	h_fallback = maxi(8, int(round(float(w_fallback) * cell_y / cell_x)))
	while peg_column_height(n_fit, float(h_fallback), 0.0, 0.0) > ch and h_fallback > 8:
		h_fallback -= 1
		w_fallback = maxi(8, int(round(float(h_fallback) * cell_x / cell_y)))
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

const STUB_NAMES := {
	"The Cellar": "Verdant Hollow",
	"The Warren": "Sunken Mire",
	"The Chapel": "Ashen Crypt",
	"The Vault": "Cinder Forge",
	"The Throat": "Shadow Abyss",
	"Torch Burrow": "Verdant Hollow",
	"Slime Pits": "Sunken Mire",
	"Bone Gallery": "Ashen Crypt",
	"Bog Mother": "Cinder Forge",
	"Gulp King": "Shadow Abyss",
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


## Collected ids stay in swipe order. Everything else fills the remaining slots
## in a stable scatter so silhouettes do not jump on every redraw.
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


## Crown over the case: n/5 while climbing the gate, then locked at 5/5.
## Past the gate the sub-line (cabin.hall.past_gate) carries the real found count.
static func progress_text(collected: int, total: int, quota: int = 5) -> String:
	if collected < quota:
		return "%d/%d" % [collected, quota]
	return "%d/%d" % [quota, quota]


static func past_gate(collected: int, quota: int = 5) -> bool:
	return collected >= quota


## Remaining uniques needed to cross the 5/5 map-piece gate (0 once past it).
static func next_piece_need(collected: int, quota: int = 5) -> int:
	return maxi(0, quota - collected)


static func crossed_gate(before: int, after: int, quota: int = 5) -> bool:
	return before < quota and after >= quota


## One newly banked id per step, in arrival order, across whichever cases they belong to.
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
