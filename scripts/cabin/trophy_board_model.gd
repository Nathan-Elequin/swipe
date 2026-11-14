class_name TrophyBoardModel
extends RefCounted
## Pure trophy-board membership, layout, lights and slot state.
## No nodes. Package B shared contract — A/C/D/E code against this.


const CAMPAIGN_SHELL := preload("res://scripts/campaign_shell.gd")

const STATUS_UNKNOWN := "unknown"
const STATUS_SEEN := "seen"
const STATUS_CARRIED := "carried"
const STATUS_BANKED := "banked"
const STATUS_BANKED_CARRIED := "banked_carried"

const SLUGS := {
	"b1": "verdant",
	"b2": "crystal",
	"b3": "ashen",
	"b4": "cinder",
	"b5": "shadow",
}

## Screen absolute board geometry (px @ 1680×1040).
const BOARD_OUTER := Rect2(176, 40, 1328, 776)
const FACE_VIEWPORT := Rect2(224, 128, 1232, 616)
const PYRAMID_AREA := Rect2(224, 272, 1232, 464)
const FACE_CENTER_X := 840.0

const SLOT_NORMAL := 128.0
const HGAP_NORMAL := 24.0
const VGAP_NORMAL := 40.0
const MAX_PER_LINE_NORMAL := 8

const SLOT_COMPACT := 80.0
const HGAP_COMPACT := 16.0
const VGAP_COMPACT := 16.0
const MAX_PER_LINE_COMPACT := 14
const MAX_COMPACT_LINES := 4

const SILHOUETTE := Color(0.04, 0.03, 0.025, 0.92)


## Membership for one pool. One function for board, lights and 100% checks.
static func board_ids(rules: Dictionary, items_by_id: Dictionary, pool_id: String) -> Array[String]:
	var out: Array[String] = []
	var want := str(pool_id)
	if want == "":
		return out
	for raw_id in items_by_id.keys():
		var card: Variant = items_by_id[raw_id]
		if typeof(card) != TYPE_DICTIONARY:
			continue
		if not _is_board_member(rules, card as Dictionary):
			continue
		if _pool_of(rules, card as Dictionary) != want:
			continue
		out.append(str((card as Dictionary).get("id", raw_id)))
	out.sort_custom(func(a: String, b: String) -> bool:
		var ca: Dictionary = items_by_id.get(a, {})
		var cb: Dictionary = items_by_id.get(b, {})
		var na := str(ca.get("name", a)).to_lower()
		var nb := str(cb.get("name", b)).to_lower()
		if na != nb:
			return na < nb
		return a < b
	)
	return out


static func faces(rules: Dictionary, items_by_id: Dictionary) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var biomes: Array = CAMPAIGN_SHELL.biomes_of(rules)
	var i := 0
	for raw in biomes:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var biome: Dictionary = raw
		var pool_id := str(biome.get("id", "b%d" % (i + 1)))
		var ids: Array[String] = board_ids(rules, items_by_id, pool_id)
		var rows := {3: [], 2: [], 1: []}
		for id in ids:
			var card: Dictionary = items_by_id.get(id, {})
			var tier: int = clampi(BucketRules.tier_of(card), 1, 3)
			(rows[tier] as Array).append(id)
		for t in [3, 2, 1]:
			var line: Array = rows[t]
			line.sort_custom(func(a, b) -> bool:
				var ca: Dictionary = items_by_id.get(str(a), {})
				var cb: Dictionary = items_by_id.get(str(b), {})
				var na := str(ca.get("name", a)).to_lower()
				var nb := str(cb.get("name", b)).to_lower()
				if na != nb:
					return na < nb
				return str(a) < str(b)
			)
			rows[t] = line
		out.append({
			"pool_id": pool_id,
			"name": str(biome.get("name", pool_id)),
			"slug": str(SLUGS.get(pool_id, pool_id)),
			"index": i,
			"rows": rows,
			"ids": ids,
		})
		i += 1
	return out


## Face-local pixel layout for the pyramid slots.
static func layout(face: Dictionary) -> Dictionary:
	var rows: Dictionary = face.get("rows", {3: [], 2: [], 1: []})
	var tiers: Array = []
	for t in [3, 2, 1]:
		var line: Array = rows.get(t, [])
		if line is Array and not (line as Array).is_empty():
			tiers.append({"tier": t, "ids": line})
	var need_compact := false
	for raw in tiers:
		if (raw["ids"] as Array).size() > MAX_PER_LINE_NORMAL:
			need_compact = true
			break
	if tiers.size() > 3:
		need_compact = true
	if need_compact:
		return _layout_compact(tiers)
	return _layout_normal(tiers)


static func claimed_unique(state: Dictionary, face: Dictionary) -> int:
	var banked: Dictionary = state.get("banked", {})
	if typeof(banked) != TYPE_DICTIONARY:
		banked = {}
	var n := 0
	for id in _face_ids(face):
		if banked.has(str(id)):
			n += 1
	return n


static func lights_lit(rules: Dictionary, state: Dictionary, face: Dictionary, held := []) -> int:
	if _portal_opened_for_next(rules, state, face):
		return 5
	var claimed := claimed_unique(state, face)
	var held_in := _held_in_face(face, held)
	return clampi(claimed - held_in, 0, 5)


static func lever_state(rules, state, face) -> StringName:
	var lit: int = lights_lit(rules, state, face, [])
	if lit < 5:
		return &"locked"
	if _portal_opened_for_next(rules, state, face):
		return &"spent"
	return &"ready"


static func is_complete(state, face) -> bool:
	var ids: Array = _face_ids(face)
	if ids.is_empty():
		return false
	return claimed_unique(state, face) == ids.size()


static func is_face_locked(rules: Dictionary, state: Dictionary, face: Dictionary) -> bool:
	var idx := int(face.get("index", 0))
	if idx <= 0:
		return false
	var biomes: Array = CAMPAIGN_SHELL.biomes_of(rules)
	if idx >= biomes.size():
		return true
	var biome: Dictionary = biomes[idx]
	return not _map_has(state, str(biome.get("id", "")))


## unseen / seen / claimed for board slots.
static func slot_state(cabin_seen: Dictionary, state: Dictionary, id: String, held := []) -> StringName:
	var sid := str(id)
	if sid == "":
		return &"unseen"
	var banked: Dictionary = state.get("banked", {})
	if typeof(banked) != TYPE_DICTIONARY:
		banked = {}
	var in_hold := _held_has(held, sid)
	if banked.has(sid) and not in_hold:
		return &"claimed"
	if banked.has(sid) and in_hold:
		return &"seen"
	if bool(cabin_seen.get(sid, false)):
		return &"seen"
	return &"unseen"


## Hotbar New! badge — absorbed from CollectionJourney.item_status.
static func item_status(
	card_id: String,
	seen_map: Dictionary,
	banked: Dictionary,
	held_ids: Array = []
) -> String:
	var id := str(card_id)
	if id == "":
		return STATUS_UNKNOWN
	var qty := 0
	for raw in held_ids:
		if str(raw) == id:
			qty += 1
	var is_banked: bool = banked.has(id)
	if is_banked:
		return STATUS_BANKED_CARRIED if qty > 0 else STATUS_BANKED
	if qty > 0:
		return STATUS_CARRIED
	if bool(seen_map.get(id, false)):
		return STATUS_SEEN
	return STATUS_UNKNOWN


static func face_ids_flat(face: Dictionary) -> Array:
	return _face_ids(face)


static func next_biome_id(rules: Dictionary, face: Dictionary) -> String:
	var idx := int(face.get("index", 0))
	var biomes: Array = CAMPAIGN_SHELL.biomes_of(rules)
	if idx + 1 >= biomes.size():
		var endless: Dictionary = rules.get("endless", {})
		return str(endless.get("id", "endless"))
	return str((biomes[idx + 1] as Dictionary).get("id", ""))


static func prev_biome_name(rules: Dictionary, face: Dictionary) -> String:
	var idx := int(face.get("index", 0))
	if idx <= 0:
		return ""
	var biomes: Array = CAMPAIGN_SHELL.biomes_of(rules)
	if idx - 1 >= biomes.size():
		return ""
	return str((biomes[idx - 1] as Dictionary).get("name", ""))


# --- internals ---------------------------------------------------------------


static func _is_board_member(rules: Dictionary, card: Dictionary) -> bool:
	var st := str(card.get("status", "live"))
	if st == "retired" or st == "hold":
		return false
	if BucketRules.is_token(card):
		return false
	if BucketRules.is_always_starter(card):
		return false
	var pool := _pool_of(rules, card)
	return pool != ""


static func _pool_of(rules: Dictionary, card: Dictionary) -> String:
	var bucket: int = BucketRules.of_card(card)
	if bucket < 1:
		return ""
	var mapped := CAMPAIGN_SHELL.pool_for_bucket(rules, bucket)
	if mapped != "":
		return mapped
	return "b%d" % mini(5, bucket)


static func _face_ids(face: Dictionary) -> Array:
	var ids: Variant = face.get("ids", null)
	if ids is Array:
		return ids as Array
	var out: Array = []
	var rows: Dictionary = face.get("rows", {})
	for t in [3, 2, 1]:
		for id in rows.get(t, []):
			out.append(str(id))
	return out


static func _held_has(held: Array, id: String) -> bool:
	for raw in held:
		if str(raw) == id:
			return true
	return false


static func _held_in_face(face: Dictionary, held: Array) -> int:
	var face_set := {}
	for id in _face_ids(face):
		face_set[str(id)] = true
	var seen := {}
	var n := 0
	for raw in held:
		var sid := str(raw)
		if sid == "" or seen.has(sid) or not face_set.has(sid):
			continue
		seen[sid] = true
		n += 1
	return n


static func _map_has(state: Dictionary, biome_id: String) -> bool:
	var pieces: Variant = state.get("map_pieces", [])
	if typeof(pieces) != TYPE_ARRAY:
		return false
	for raw in pieces as Array:
		if str(raw) == biome_id:
			return true
	return false


static func _portal_opened_for_next(rules: Dictionary, state: Dictionary, face: Dictionary) -> bool:
	var nxt := next_biome_id(rules, face)
	if nxt == "" or nxt == "endless":
		return bool(state.get("endless_unlocked", false))
	return _map_has(state, nxt)


static func _layout_normal(tiers: Array) -> Dictionary:
	var slot := SLOT_NORMAL
	var hgap := HGAP_NORMAL
	var vgap := VGAP_NORMAL
	var line_h := slot
	var block_h: float = float(tiers.size()) * line_h + float(maxi(0, tiers.size() - 1)) * vgap
	var area_local := Rect2(
		PYRAMID_AREA.position - FACE_VIEWPORT.position,
		PYRAMID_AREA.size
	)
	var y0: float = area_local.position.y + (area_local.size.y - block_h) * 0.5
	## Prefer top-aligned fill when three lines exactly match 464.
	if tiers.size() == 3 and is_equal_approx(block_h, area_local.size.y):
		y0 = area_local.position.y
	var rects := {}
	var y := y0
	for raw in tiers:
		var ids: Array = raw["ids"]
		var n: int = ids.size()
		var w: float = float(n) * slot + float(maxi(0, n - 1)) * hgap
		var x0: float = FACE_CENTER_X - FACE_VIEWPORT.position.x - w * 0.5
		## Convert to absolute screen x for callers that want board space:
		## store absolute px (screen) in rects so slot_global_center is simple.
		var abs_x0: float = FACE_VIEWPORT.position.x + x0
		var abs_y: float = FACE_VIEWPORT.position.y + y
		for i in n:
			var id := str(ids[i])
			rects[id] = Rect2(abs_x0 + float(i) * (slot + hgap), abs_y, slot, slot)
		y += line_h + vgap
	return {"mode": "normal", "slot": int(slot), "rects": rects}


static func _layout_compact(tiers: Array) -> Dictionary:
	var slot := SLOT_COMPACT
	var hgap := HGAP_COMPACT
	var vgap := VGAP_COMPACT
	## Expand wrapped lines per tier.
	var lines: Array = []
	for raw in tiers:
		var ids: Array = raw["ids"]
		var i := 0
		while i < ids.size():
			var chunk: Array = ids.slice(i, mini(ids.size(), i + MAX_PER_LINE_COMPACT))
			lines.append(chunk)
			i += MAX_PER_LINE_COMPACT
	if lines.size() > MAX_COMPACT_LINES:
		push_warning(
			"TrophyBoardModel: compact overflow (%d lines > %d)" % [lines.size(), MAX_COMPACT_LINES]
		)
	var use_lines: Array = lines.slice(0, mini(lines.size(), MAX_COMPACT_LINES))
	var block_h: float = float(use_lines.size()) * slot + float(maxi(0, use_lines.size() - 1)) * vgap
	var area_local := Rect2(
		PYRAMID_AREA.position - FACE_VIEWPORT.position,
		PYRAMID_AREA.size
	)
	var y0: float = area_local.position.y + (area_local.size.y - block_h) * 0.5
	var rects := {}
	var y := y0
	for chunk in use_lines:
		var ids: Array = chunk
		var n: int = ids.size()
		var w: float = float(n) * slot + float(maxi(0, n - 1)) * hgap
		var x0: float = FACE_CENTER_X - FACE_VIEWPORT.position.x - w * 0.5
		var abs_x0: float = FACE_VIEWPORT.position.x + x0
		var abs_y: float = FACE_VIEWPORT.position.y + y
		for i in n:
			rects[str(ids[i])] = Rect2(abs_x0 + float(i) * (slot + hgap), abs_y, slot, slot)
		y += slot + vgap
	return {"mode": "compact", "slot": int(slot), "rects": rects, "overflow": lines.size() > MAX_COMPACT_LINES}
