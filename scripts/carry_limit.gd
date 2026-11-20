extends RefCounted
class_name CarryLimit
## Carry-3 (slice 1 — logic only).
## Pure between-dungeon carry cap. Carry-over is whatever is in the bag when
## the player goes through the portal. Over CARRY_MAX with an empty bag →
## carry nothing. main.gd + the selftest share this reading. No UI here —
## later slices set the bag selection and call portal commit on Main.

const CARRY_MAX := 3

## Temporary until the carry-choice UI ships. When true, an over-cap
## transition with no picker uses an empty selection (carry nothing) so the
## game stays playable and Nathan can test the empty-bag path.
## Flip off only when a real picker is waiting on portal commit.
const DEV_FALLBACK_EMPTY_SELECTION := true


static func needs_choice(items: Array) -> bool:
	return _count_carryable(items) > CARRY_MAX


## Returns true when kept_ids is a legal subset: size ≤ CARRY_MAX, no dupes,
## every id present in items. Empty / short lists are allowed (empty bag).
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
## Empty kept_ids with an over-cap hand is valid: carry nothing.
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


## Uids of carryable items in list order (helper for UI / tests).
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


## All carryable uids in list order.
static func all_ids(items: Array) -> Array:
	return first_n_ids(items, items.size())


## Resolve a between-dungeon hand from the bag selection at portal time.
## - ≤ CARRY_MAX: keep everything (no choice).
## - Over cap: apply bag_kept_ids. Empty bag → carry nothing.
## When over cap and DEV_FALLBACK_EMPTY_SELECTION with no selection yet, uses [].
## Returns {ok, needed_choice, kept, removed, kept_ids}.
static func resolve_for_transition(items: Array, bag_kept_ids: Array = []) -> Dictionary:
	if not needs_choice(items):
		var all: Array = all_ids(items)
		return {
			"ok": true,
			"needed_choice": false,
			"kept": _copy_carryable(items),
			"removed": [],
			"kept_ids": all,
		}
	var ids: Array = bag_kept_ids.duplicate()
	if ids.is_empty() and DEV_FALLBACK_EMPTY_SELECTION:
		ids = []
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
