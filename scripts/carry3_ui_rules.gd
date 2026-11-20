extends RefCounted
class_name Carry3UiRules
## Pure UI decision helpers for Carry-3 layout B.
## Keeps CarryLimit as the hand model; this only answers overlay / reminder /
## Delve-lock questions so headless selftests can cover the B flow without Main.

const CARRY_LIMIT := preload("res://scripts/carry_limit.gd")


static func should_show_room_bag(items: Array) -> bool:
	return CARRY_LIMIT.needs_choice(items)


static func should_show_reminder(needs_choice: bool, bag_opened: bool) -> bool:
	return needs_choice and not bag_opened


static func delve_locked(packed_n: int) -> bool:
	return packed_n > CARRY_LIMIT.CARRY_MAX


static func delve_ready(packed_n: int) -> bool:
	return packed_n <= CARRY_LIMIT.CARRY_MAX


## Toggle uid membership. Over-cap adds are allowed so Delve can lock at 4+.
static func toggle_uid(selection: Array, uid: int) -> Array:
	var out: Array = []
	var found := false
	for raw in selection:
		var u: int = int(raw)
		if u == uid:
			found = true
			continue
		out.append(u)
	if not found:
		out.append(uid)
	return out


## Portal click while over cap: "reminder" | "blocked" | "commit".
static func portal_action(needs_choice: bool, bag_opened: bool, packed_n: int) -> String:
	if not needs_choice:
		return "proceed"
	if not bag_opened:
		return "reminder"
	if delve_locked(packed_n):
		return "blocked"
	return "commit"
