class_name CollectionJourney
extends RefCounted
## Journey A shared state projection — seen / carried / banked / provisional / gate.
## Pure functions over save + run facts. UI must not invent alternate counts.
## OWNER-CONTRACT + SOURCE-AUDIT. No player-facing Tier. No new mechanics.


const CAMPAIGN_SHELL := preload("res://scripts/campaign_shell.gd")

## Item identity relative to collection ledgers.
## unknown | seen | carried | banked | banked_carried
const STATUS_UNKNOWN := "unknown"
const STATUS_SEEN := "seen"
const STATUS_CARRIED := "carried"
const STATUS_BANKED := "banked"
const STATUS_BANKED_CARRIED := "banked_carried"


## Distinct held card_ids that are not yet banked (duplicates collapse to one).
static func provisional_distinct_ids(held_ids: Array, banked: Dictionary) -> Array:
	var out: Array = []
	var seen_local := {}
	for raw in held_ids:
		var id := str(raw)
		if id == "" or seen_local.has(id):
			continue
		seen_local[id] = true
		if banked.has(id):
			continue
		out.append(id)
	return out


## Count of provisional distinct IDs whose catalog pool matches `pool` (e.g. "b1").
static func provisional_distinct_in_pool(
	held_ids: Array,
	banked: Dictionary,
	pools_by_id: Dictionary,
	pool: String
) -> int:
	var n := 0
	for id in provisional_distinct_ids(held_ids, banked):
		if str(pools_by_id.get(id, "")) == pool:
			n += 1
	return n


## Multiset quantity of one id in the haul / hotbar id list.
static func held_quantity(held_ids: Array, card_id: String) -> int:
	var want := str(card_id)
	if want == "":
		return 0
	var n := 0
	for raw in held_ids:
		if str(raw) == want:
			n += 1
	return n


## Classify one catalog id for contextual UI.
## seen_map / banked are authoritative saves; held_ids is current run haul (may be empty).
static func item_status(
	card_id: String,
	seen_map: Dictionary,
	banked: Dictionary,
	held_ids: Array = []
) -> String:
	var id := str(card_id)
	if id == "":
		return STATUS_UNKNOWN
	var qty: int = held_quantity(held_ids, id)
	var is_banked: bool = banked.has(id)
	if is_banked:
		return STATUS_BANKED_CARRIED if qty > 0 else STATUS_BANKED
	if qty > 0:
		return STATUS_CARRIED
	if bool(seen_map.get(id, false)):
		return STATUS_SEEN
	return STATUS_UNKNOWN


## Catalogue cell kind for progress menu: new | collected | seen | missing
## "new" = newly banked this return (in new_ids). Prefer over collected.
static func catalogue_cell_kind(
	card_id: String,
	seen_map: Dictionary,
	banked_or_swiped: Dictionary,
	new_ids: Array
) -> String:
	var id := str(card_id)
	if id == "":
		return "missing"
	if new_ids.has(id):
		return "new"
	if bool(banked_or_swiped.get(id, false)) or banked_or_swiped.has(id):
		return "collected"
	if bool(seen_map.get(id, false)):
		return "seen"
	return "missing"


## Would banking this haul cross the cabinet quota for `pool`?
## Uses CampaignShell.project_cabinet_count — carried fifth is NOT an open gate until banked.
static func gate_projection(
	rules: Dictionary,
	state: Dictionary,
	pool: String,
	held_ids: Array,
	pools_by_id: Dictionary
) -> Dictionary:
	var quota: int = CAMPAIGN_SHELL.quota_of(rules)
	var now: int = CAMPAIGN_SHELL.cabinet_count(state, pool)
	var projected: int = CAMPAIGN_SHELL.project_cabinet_count(state, pool, held_ids, pools_by_id)
	var provisional: int = provisional_distinct_in_pool(held_ids, state.get("banked", {}), pools_by_id, pool)
	return {
		"pool": pool,
		"banked": now,
		"quota": quota,
		"projected_if_banked": projected,
		"provisional_distinct": provisional,
		"gate_open_now": now >= quota,
		## True only after a successful bank would meet quota — not on pickup alone.
		"would_cross_on_bank": now < quota and projected >= quota,
	}


## Ordered durable milestones from a bank commit (facts only — presentation is UI).
## before/after are campaign state snapshots; never invent room unlocks here (cabin owns those).
static func milestones_from_bank(
	rules: Dictionary,
	before: Dictionary,
	after: Dictionary,
	touched_pools: Array = []
) -> Array:
	var out: Array = []
	var quota: int = CAMPAIGN_SHELL.quota_of(rules)
	var pools: Array = touched_pools.duplicate()
	if pools.is_empty():
		for raw in CAMPAIGN_SHELL.biomes_of(rules):
			var pid := str((raw as Dictionary).get("id", ""))
			if pid != "":
				pools.append(pid)
	for pool in pools:
		var pid := str(pool)
		var b0: int = CAMPAIGN_SHELL.cabinet_count(before, pid)
		var b1: int = CAMPAIGN_SHELL.cabinet_count(after, pid)
		if b0 < quota and b1 >= quota:
			var nxt: Dictionary = CAMPAIGN_SHELL.next_after_pool(rules, pid)
			out.append({
				"kind": "gate",
				"pool": pid,
				"from": b0,
				"to": b1,
				"quota": quota,
				"next_id": str(nxt.get("id", "")),
				"next_name": str(nxt.get("name", "")),
			})
		## Full biome cabinet = every eligible roster id banked — caller may pass roster sizes.
		## Here: only signal when count jumps and equals a provided roster_total in touched meta.
	var won0 := bool(before.get("won", false))
	var won1 := bool(after.get("won", false))
	if not won0 and won1:
		out.append({"kind": "collection_complete"})
	return out


## Full-cabinet recognition when banked count for pool equals roster_total (>0).
static func cabinet_complete_milestone(
	pool: String,
	before_count: int,
	after_count: int,
	roster_total: int
) -> Dictionary:
	if roster_total <= 0:
		return {}
	if before_count < roster_total and after_count >= roster_total:
		return {
			"kind": "cabinet_full",
			"pool": pool,
			"count": after_count,
			"total": roster_total,
		}
	return {}


## Build pools_by_id from catalog item rows + campaign rules (same as banking selftest).
static func pools_from_catalog(catalog: Dictionary, rules: Dictionary) -> Dictionary:
	var out := {}
	var rows: Variant = catalog.get("items", [])
	if typeof(rows) != TYPE_ARRAY:
		return out
	for raw in rows:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var card: Dictionary = raw
		var id := str(card.get("id", ""))
		if id == "":
			continue
		out[id] = CAMPAIGN_SHELL.pool_for_bucket(rules, BucketRules.of_card(card))
	return out


## Quiet in-run summary facts (no player copy). UI formats via approved keys later.
static func quiet_run_summary(
	rules: Dictionary,
	state: Dictionary,
	held_ids: Array,
	pools_by_id: Dictionary,
	focus_pool: String = ""
) -> Dictionary:
	var pool := focus_pool
	if pool == "":
		pool = CAMPAIGN_SHELL.current_biome_id(rules, state)
	var gate: Dictionary = gate_projection(rules, state, pool, held_ids, pools_by_id)
	var provisional: Array = provisional_distinct_ids(held_ids, state.get("banked", {}))
	return {
		"focus_pool": pool,
		"banked": int(gate.get("banked", 0)),
		"quota": int(gate.get("quota", 5)),
		"provisional_ids": provisional,
		"provisional_count": provisional.size(),
		"provisional_in_focus": int(gate.get("provisional_distinct", 0)),
		"would_cross_on_bank": bool(gate.get("would_cross_on_bank", false)),
		"gate_open_now": bool(gate.get("gate_open_now", false)),
	}
