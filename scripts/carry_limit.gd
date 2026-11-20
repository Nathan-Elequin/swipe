extends RefCounted
class_name CarryLimit
## Carry-3 (slice 1 — logic only).
## Pure between-dungeon carry cap. main.gd calls these so combat and the
## selftest share one reading. No UI here — later slices listen to
## `carry_limit_choice_needed` on Main and call `apply_choice`.

const CARRY_MAX := 3

## Temporary until the carry-choice UI ships. When true, Main keeps the first
## CARRY_MAX items (hotbar order) instead of waiting on a picker.
const DEV_FALLBACK_KEEP_FIRST := true


static func needs_choice(items: Array) -> bool:
	return _count_carryable(items) > CARRY_MAX


## Returns true when kept_ids is a legal subset: size ≤ CARRY_MAX, no dupes,
## every id present in items. Empty / short lists are allowed.
static func validate(items: Array, kept_ids: Array) -> bool:
	if kept_ids.size() > CARRY_MAX:
		return false
	var seen: Dictionary = {}
	var available: Dictionary = _uid_set(items)
	for raw in kept_ids:
		var uid: int = int(raw)
		if uid < 0:
			return false
		if seen.has(uid):
			return false
		seen[uid] = true
		if not available.has(uid):
			return false
	return true


## Keep only items whose uid is in kept_ids (order preserved). Everything else
## is removed for the rest of the run — not carried, not recoverable this run.
## Returns {ok: bool, kept: Array, removed: Array}. ok is false when validate fails;
## then kept/removed are empty and the caller must not mutate the hand.
static func apply_choice(items: Array, kept_ids: Array) -> Dictionary:
	if not validate(items, kept_ids):
		return {"ok": false, "kept": [], "removed": []}
	var keep_set: Dictionary = {}
	for raw in kept_ids:
		keep_set[int(raw)] = true
	var kept: Array = []
	var removed: Array = []
	for it in items:
		if typeof(it) != TYPE_DICTIONARY:
			continue
		var uid: int = int(it.get("uid", -1))
		if uid < 0:
			continue
		if keep_set.has(uid):
			kept.append(it)
		else:
			removed.append(it)
	return {"ok": true, "kept": kept, "removed": removed}


## Dev fallback: first CARRY_MAX carryable uids in list order.
static func first_n_ids(items: Array, n: int = CARRY_MAX) -> Array:
	var out: Array = []
	var limit: int = maxi(0, n)
	for it in items:
		if out.size() >= limit:
			break
		if typeof(it) != TYPE_DICTIONARY:
			continue
		var uid: int = int(it.get("uid", -1))
		if uid < 0:
			continue
		out.append(uid)
	return out


## Resolve a between-dungeon hand. When over cap and DEV_FALLBACK_KEEP_FIRST,
## keeps the first CARRY_MAX. When under/at cap, returns items unchanged.
## Returns {ok, needed_choice, kept, removed, kept_ids}.
static func resolve_for_transition(items: Array) -> Dictionary:
	if not needs_choice(items):
		var all_ids: Array = first_n_ids(items, items.size())
		return {
			"ok": true,
			"needed_choice": false,
			"kept": _copy_carryable(items),
			"removed": [],
			"kept_ids": all_ids,
		}
	var ids: Array = first_n_ids(items, CARRY_MAX) if DEV_FALLBACK_KEEP_FIRST else []
	if ids.is_empty() and not DEV_FALLBACK_KEEP_FIRST:
		return {
			"ok": false,
			"needed_choice": true,
			"kept": [],
			"removed": [],
			"kept_ids": [],
		}
	var applied: Dictionary = apply_choice(items, ids)
	applied["needed_choice"] = true
	applied["kept_ids"] = ids
	return applied


static func _count_carryable(items: Array) -> int:
	var n := 0
	for it in items:
		if typeof(it) != TYPE_DICTIONARY:
			continue
		if int(it.get("uid", -1)) < 0:
			continue
		n += 1
	return n


static func _uid_set(items: Array) -> Dictionary:
	var out: Dictionary = {}
	for it in items:
		if typeof(it) != TYPE_DICTIONARY:
			continue
		var uid: int = int(it.get("uid", -1))
		if uid < 0:
			continue
		out[uid] = true
	return out


static func _copy_carryable(items: Array) -> Array:
	var out: Array = []
	for it in items:
		if typeof(it) != TYPE_DICTIONARY:
			continue
		if int(it.get("uid", -1)) < 0:
			continue
		out.append(it)
	return out
