extends RefCounted
class_name PlaytestCommitment
## Playtest commitment tiers (slice 1 — logic only).
## Owns tier choice, milestone reach flags, offramp gating, and persist/merge.
## No picker / offramp UI here — later slices listen to `milestone_reached`.

signal milestone_reached(id: String, tier: int, run_count: int)

const META_PATH := "user://playtest_meta.json"
const META_KEY := "commitment"
const LS_KEY := "swipe_pt_commitment"

const TIER_NONE := 0
const TIER_QUICK := 1
const TIER_DEEPER := 2
const TIER_BIG := 3

const M_QUICK := "quick"
const M_DEEPER := "deeper"
const M_BIG := "big"

const MILESTONES := [M_QUICK, M_DEEPER, M_BIG]
const VICTORY_CODE := preload("res://scripts/playtest_victory_code.gd")

## Live state (also mirrored into playtest_meta.json → commitment).
var tier: int = TIER_NONE
var reached_quick: bool = false
var reached_deeper: bool = false
var reached_big: bool = false
var offramp_shown_quick: bool = false
var offramp_shown_deeper: bool = false
var offramp_shown_big: bool = false
var feedback_sent_quick: bool = false
var feedback_sent_deeper: bool = false
var feedback_sent_big: bool = false
var run_count: int = 0
var chosen_at: String = ""
var upgraded_at: String = ""
var reached_at_quick: String = ""
var reached_at_deeper: String = ""
var reached_at_big: String = ""
var pending_milestone: String = ""
## Deterministic BIG victory code (ABYSS-XXXX-XXXX). Empty until first generate.
var victory_code: String = ""

## Ephemeral — current run only (not persisted).
var _run_active: bool = false
var _run_tutorial: bool = false
var _run_max_biome: int = 0
var _run_outcome: String = ""
var _awaiting_homecoming: bool = false

## Optional telem hook: Callable(name: String, props: Dictionary).
var telem: Callable = Callable()
var anon_id: String = ""


func load_state() -> void:
	var disk: Dictionary = _read_commitment_from_meta()
	var web: Dictionary = _read_commitment_from_ls()
	var merged: Dictionary = _merge_commitment(disk, web)
	_apply_dict(merged)
	_refresh_pending()
	_write_all()


func save_state() -> void:
	_refresh_pending()
	_write_all()


## First pick only. Returns true when applied.
func choose(p_tier: int) -> bool:
	var t: int = _clamp_tier(p_tier)
	if t <= TIER_NONE:
		return false
	if tier != TIER_NONE:
		return false
	tier = t
	chosen_at = _now()
	_refresh_pending()
	_write_all()
	return true


## Upgrade-only. Returns true when applied.
func upgrade(p_tier: int) -> bool:
	var t: int = _clamp_tier(p_tier)
	if t <= tier:
		return false
	tier = t
	if chosen_at == "":
		chosen_at = _now()
	upgraded_at = _now()
	_refresh_pending()
	_write_all()
	return true


func should_offramp(milestone: String) -> bool:
	var id := str(milestone).strip_edges().to_lower()
	var need: int = _tier_for_milestone(id)
	if need <= TIER_NONE:
		return false
	if not _reached(id):
		return false
	if _offramp_shown(id):
		return false
	## BIG carrot is open to every playtester who reaches Shadow Abyss —
	## tier gate does not apply (slice 4). Quick / deeper still need their tier.
	if id == M_BIG:
		return true
	return tier >= need


## Ensure a stable victory code is stored. Returns the code.
func ensure_victory_code() -> String:
	var existing := str(victory_code).strip_edges().to_upper()
	if existing != "" and VICTORY_CODE.is_valid_format(existing):
		victory_code = VICTORY_CODE.normalize(existing)
		return victory_code
	victory_code = VICTORY_CODE.generate(anon_id, M_BIG)
	_write_all()
	return victory_code


## Silent upgrade used when BIG milestone opens for a lower-tier player.
func ensure_big_tier() -> bool:
	if tier >= TIER_BIG:
		return false
	return upgrade(TIER_BIG)


func mark_offramp_shown(milestone: String) -> void:
	var id := str(milestone).strip_edges().to_lower()
	match id:
		M_QUICK:
			offramp_shown_quick = true
		M_DEEPER:
			offramp_shown_deeper = true
		M_BIG:
			offramp_shown_big = true
		_:
			return
	if pending_milestone == id:
		pending_milestone = ""
	_refresh_pending()
	_write_all()


func mark_feedback_sent(milestone: String) -> void:
	var id := str(milestone).strip_edges().to_lower()
	match id:
		M_QUICK:
			feedback_sent_quick = true
		M_DEEPER:
			feedback_sent_deeper = true
		M_BIG:
			feedback_sent_big = true
		_:
			return
	_write_all()


func next_offramp() -> String:
	for id in MILESTONES:
		if should_offramp(str(id)):
			return str(id)
	return ""


## Call when a campaign (or adventure) run begins. Tutorial runs pass tutorial=true.
func note_run_start(tutorial: bool, biome_index: int = 0) -> void:
	_run_active = true
	_run_tutorial = bool(tutorial)
	_run_max_biome = maxi(0, int(biome_index))
	_run_outcome = ""
	_awaiting_homecoming = false


## Call when the run enters a biome (start or Push deeper). Index 0=b1 … 4=b5.
func note_biome(biome_index: int) -> void:
	if not _run_active:
		return
	_run_max_biome = maxi(_run_max_biome, maxi(0, int(biome_index)))


## Call just before going home after a real run end.
## outcome: "leave" (rope exit), "dead" (death / give-up), "push_block", or other.
func note_run_end(outcome: String) -> void:
	if not _run_active:
		return
	_run_outcome = str(outcome).strip_edges().to_lower()
	_awaiting_homecoming = true


## Call when cabin homecoming has finished (player has control again).
## kind: "win" | "loss" | "tutorial" | "tutorial_skipped" | …
func note_homecoming_settled(kind: String) -> Array:
	var fired: Array = []
	var k := str(kind).strip_edges().to_lower()
	if k.begins_with("tutorial"):
		_clear_run_ephemeral()
		fired = _emit_pending_if_any()
		return fired
	if not _awaiting_homecoming and not _run_active:
		## Cabin visit with no fresh run — still surface pending offramps.
		fired = _emit_pending_if_any()
		return fired
	if _run_tutorial:
		_clear_run_ephemeral()
		fired = _emit_pending_if_any()
		return fired

	run_count = maxi(0, run_count) + 1
	var outcome := _run_outcome
	var max_biome := _run_max_biome
	_clear_run_ephemeral()

	## quick: first non-tutorial run that ends via rope leave OR death.
	if not reached_quick and (outcome == "leave" or outcome == "dead"):
		if _mark_reached(M_QUICK):
			fired.append(M_QUICK)
	## deeper / big: first run that entered that biome and ended (win or lose).
	if k == "win" or k == "loss":
		if not reached_deeper and max_biome >= 1:
			if _mark_reached(M_DEEPER):
				fired.append(M_DEEPER)
		if not reached_big and max_biome >= 4:
			if _mark_reached(M_BIG):
				fired.append(M_BIG)

	_refresh_pending()
	_write_all()
	for id in fired:
		_emit_milestone(str(id), true)
	## If nothing new fired, still surface an older pending offramp on this cabin visit
	## (signal only — return value stays "newly reached" so callers can tell them apart).
	if fired.is_empty():
		_emit_pending_if_any()
	return fired


## Cabin open with no fresh homecoming (Continue / menu) — re-emit pending for UI.
func note_cabin_visit() -> Array:
	return _emit_pending_if_any()


## --- Editor / selftest debug (no-op guards for exported playtest) -----------------

func debug_set_tier(p_tier: int) -> void:
	if not _debug_ok():
		return
	tier = _clamp_tier(p_tier)
	if tier > TIER_NONE and chosen_at == "":
		chosen_at = _now()
	_refresh_pending()
	_write_all()


func debug_force_milestone(milestone: String) -> bool:
	if not _debug_ok():
		return false
	var id := str(milestone).strip_edges().to_lower()
	if _tier_for_milestone(id) <= TIER_NONE:
		return false
	var first: bool = _mark_reached(id)
	_refresh_pending()
	_write_all()
	_emit_milestone(id, first)
	return true


## DEV: mark this path done and fire its offramp / victory even if it already showed.
func debug_retrigger_offramp(milestone: String) -> bool:
	if not _debug_ok():
		return false
	var id := str(milestone).strip_edges().to_lower()
	var need: int = _tier_for_milestone(id)
	if need <= TIER_NONE:
		return false
	if id == M_BIG:
		ensure_big_tier()
	elif tier < need:
		tier = need
		if chosen_at == "":
			chosen_at = _now()
	_mark_reached(id)
	match id:
		M_QUICK:
			offramp_shown_quick = false
		M_DEEPER:
			offramp_shown_deeper = false
		M_BIG:
			offramp_shown_big = false
		_:
			return false
	pending_milestone = id
	_write_all()
	_emit_milestone(id, false)
	return true


func debug_reset() -> void:
	if not _debug_ok():
		return
	wipe_progress()


## Start over / selftest: clear tier, milestones, pending, victory. Keeps anon_id.
## Also clears the localStorage commitment mirror on web.
func wipe_progress() -> void:
	_apply_dict({})
	_clear_run_ephemeral()
	_write_all()
	_clear_ls()


func _clear_ls() -> void:
	if not OS.has_feature("web") or not ClassDB.class_exists("JavaScriptBridge"):
		return
	JavaScriptBridge.eval(
		"(function(){try{localStorage.removeItem(%s);}catch(e){}})();" % JSON.stringify(LS_KEY),
		true
	)


func to_dict() -> Dictionary:
	return {
		"tier": tier,
		"reached_quick": reached_quick,
		"reached_deeper": reached_deeper,
		"reached_big": reached_big,
		"offramp_shown_quick": offramp_shown_quick,
		"offramp_shown_deeper": offramp_shown_deeper,
		"offramp_shown_big": offramp_shown_big,
		"feedback_sent_quick": feedback_sent_quick,
		"feedback_sent_deeper": feedback_sent_deeper,
		"feedback_sent_big": feedback_sent_big,
		"run_count": run_count,
		"chosen_at": chosen_at,
		"upgraded_at": upgraded_at,
		"reached_at_quick": reached_at_quick,
		"reached_at_deeper": reached_at_deeper,
		"reached_at_big": reached_at_big,
		"pending_milestone": pending_milestone,
		"victory_code": victory_code,
	}


## Pure merge helper (selftest / localStorage). Higher tier wins; flags OR; counts max.
static func merge_dicts(a: Dictionary, b: Dictionary) -> Dictionary:
	var out := {
		"tier": maxi(int(a.get("tier", 0)), int(b.get("tier", 0))),
		"reached_quick": bool(a.get("reached_quick", false)) or bool(b.get("reached_quick", false)),
		"reached_deeper": bool(a.get("reached_deeper", false)) or bool(b.get("reached_deeper", false)),
		"reached_big": bool(a.get("reached_big", false)) or bool(b.get("reached_big", false)),
		"offramp_shown_quick": bool(a.get("offramp_shown_quick", false)) or bool(b.get("offramp_shown_quick", false)),
		"offramp_shown_deeper": bool(a.get("offramp_shown_deeper", false)) or bool(b.get("offramp_shown_deeper", false)),
		"offramp_shown_big": bool(a.get("offramp_shown_big", false)) or bool(b.get("offramp_shown_big", false)),
		"feedback_sent_quick": bool(a.get("feedback_sent_quick", false)) or bool(b.get("feedback_sent_quick", false)),
		"feedback_sent_deeper": bool(a.get("feedback_sent_deeper", false)) or bool(b.get("feedback_sent_deeper", false)),
		"feedback_sent_big": bool(a.get("feedback_sent_big", false)) or bool(b.get("feedback_sent_big", false)),
		"run_count": maxi(int(a.get("run_count", 0)), int(b.get("run_count", 0))),
		"chosen_at": _later_stamp(str(a.get("chosen_at", "")), str(b.get("chosen_at", ""))),
		"upgraded_at": _later_stamp(str(a.get("upgraded_at", "")), str(b.get("upgraded_at", ""))),
		"reached_at_quick": _later_stamp(str(a.get("reached_at_quick", "")), str(b.get("reached_at_quick", ""))),
		"reached_at_deeper": _later_stamp(str(a.get("reached_at_deeper", "")), str(b.get("reached_at_deeper", ""))),
		"reached_at_big": _later_stamp(str(a.get("reached_at_big", "")), str(b.get("reached_at_big", ""))),
		"pending_milestone": "",
		"victory_code": _prefer_code(str(a.get("victory_code", "")), str(b.get("victory_code", ""))),
	}
	## Recompute pending from merged flags + tier.
	var tmp := PlaytestCommitment.new()
	tmp._apply_dict(out)
	tmp._refresh_pending()
	out["pending_milestone"] = tmp.pending_milestone
	return out


## --- internals -----------------------------------------------------------------

func _apply_dict(d: Dictionary) -> void:
	tier = _clamp_tier(int(d.get("tier", TIER_NONE)))
	reached_quick = bool(d.get("reached_quick", false))
	reached_deeper = bool(d.get("reached_deeper", false))
	reached_big = bool(d.get("reached_big", false))
	offramp_shown_quick = bool(d.get("offramp_shown_quick", false))
	offramp_shown_deeper = bool(d.get("offramp_shown_deeper", false))
	offramp_shown_big = bool(d.get("offramp_shown_big", false))
	feedback_sent_quick = bool(d.get("feedback_sent_quick", false))
	feedback_sent_deeper = bool(d.get("feedback_sent_deeper", false))
	feedback_sent_big = bool(d.get("feedback_sent_big", false))
	run_count = maxi(0, int(d.get("run_count", 0)))
	chosen_at = str(d.get("chosen_at", ""))
	upgraded_at = str(d.get("upgraded_at", ""))
	reached_at_quick = str(d.get("reached_at_quick", ""))
	reached_at_deeper = str(d.get("reached_at_deeper", ""))
	reached_at_big = str(d.get("reached_at_big", ""))
	pending_milestone = str(d.get("pending_milestone", ""))
	victory_code = str(d.get("victory_code", "")).strip_edges().to_upper()


func _mark_reached(id: String) -> bool:
	match id:
		M_QUICK:
			if reached_quick:
				return false
			reached_quick = true
			reached_at_quick = _now()
		M_DEEPER:
			if reached_deeper:
				return false
			reached_deeper = true
			reached_at_deeper = _now()
		M_BIG:
			if reached_big:
				return false
			reached_big = true
			reached_at_big = _now()
		_:
			return false
	return true


func _emit_milestone(id: String, send_telem: bool = true) -> void:
	var t: int = _tier_for_milestone(id)
	milestone_reached.emit(id, t, run_count)
	if send_telem and telem.is_valid():
		telem.call("milestone", {
			"id": id,
			"tier": t,
			"run_count": run_count,
			"anon_id": anon_id,
		})


func _emit_pending_if_any() -> Array:
	_refresh_pending()
	if pending_milestone == "":
		return []
	## Re-signal so a reload before the offramp UI still gets an event.
	## No second telemetry — `milestone` already fired when first reached.
	_emit_milestone(pending_milestone, false)
	return [pending_milestone]


func _refresh_pending() -> void:
	pending_milestone = next_offramp()


func _clear_run_ephemeral() -> void:
	_run_active = false
	_run_tutorial = false
	_run_max_biome = 0
	_run_outcome = ""
	_awaiting_homecoming = false


func _reached(id: String) -> bool:
	match id:
		M_QUICK:
			return reached_quick
		M_DEEPER:
			return reached_deeper
		M_BIG:
			return reached_big
	return false


func _offramp_shown(id: String) -> bool:
	match id:
		M_QUICK:
			return offramp_shown_quick
		M_DEEPER:
			return offramp_shown_deeper
		M_BIG:
			return offramp_shown_big
	return true


func _tier_for_milestone(id: String) -> int:
	match id:
		M_QUICK:
			return TIER_QUICK
		M_DEEPER:
			return TIER_DEEPER
		M_BIG:
			return TIER_BIG
	return TIER_NONE


func _clamp_tier(t: int) -> int:
	return clampi(int(t), TIER_NONE, TIER_BIG)


func _debug_ok() -> bool:
	return OS.has_feature("editor") or OS.is_debug_build()


func _now() -> String:
	return Time.get_datetime_string_from_system(true, true)


static func _later_stamp(a: String, b: String) -> String:
	if a == "":
		return b
	if b == "":
		return a
	return a if a >= b else b


static func _prefer_code(a: String, b: String) -> String:
	var aa := str(a).strip_edges()
	var bb := str(b).strip_edges()
	if aa != "" and VICTORY_CODE.is_valid_format(aa):
		return VICTORY_CODE.normalize(aa)
	if bb != "" and VICTORY_CODE.is_valid_format(bb):
		return VICTORY_CODE.normalize(bb)
	return aa if aa != "" else bb


func _merge_commitment(a: Dictionary, b: Dictionary) -> Dictionary:
	if a.is_empty():
		return b.duplicate(true)
	if b.is_empty():
		return a.duplicate(true)
	return merge_dicts(a, b)


func _read_meta_root() -> Dictionary:
	if not FileAccess.file_exists(META_PATH):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(META_PATH))
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}


func _read_commitment_from_meta() -> Dictionary:
	var root: Dictionary = _read_meta_root()
	var raw: Variant = root.get(META_KEY, {})
	return raw if typeof(raw) == TYPE_DICTIONARY else {}


func _read_commitment_from_ls() -> Dictionary:
	if not OS.has_feature("web") or not ClassDB.class_exists("JavaScriptBridge"):
		return {}
	var raw: String = str(JavaScriptBridge.eval(
		"(function(){try{var v=localStorage.getItem('%s');return v||'';}catch(e){return '';}})()" % LS_KEY,
		true
	)).strip_edges()
	if raw == "":
		return {}
	var parsed: Variant = JSON.parse_string(raw)
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}


func _write_all() -> void:
	var data: Dictionary = to_dict()
	var root: Dictionary = _read_meta_root()
	root[META_KEY] = data
	var f := FileAccess.open(META_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(root))
		f.close()
	_write_ls(data)


func _write_ls(data: Dictionary) -> void:
	if not OS.has_feature("web") or not ClassDB.class_exists("JavaScriptBridge"):
		return
	## Embed as a JS string literal (JSON.stringify the JSON text).
	JavaScriptBridge.eval(
		"(function(){try{localStorage.setItem(%s,%s);}catch(e){}})();" % [
			JSON.stringify(LS_KEY),
			JSON.stringify(JSON.stringify(data)),
		],
		true
	)
