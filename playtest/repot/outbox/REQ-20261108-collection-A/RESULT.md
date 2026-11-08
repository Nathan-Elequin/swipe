---
id: REQ-20261108-collection-A
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-08T09:21:00-06:00
machine: Cherry
environment: Cherry sandbox (%TEMP%/collection-a-sandbox ? Godot/app_userdata/Spinheritance)
base_tip: 1a13e353574e3a2f6d4d8e03ca4f28e1f0cd1f94
branch_fixes: cursor/collection-a-clear-commit-trace-e524
runtime_watermark: 1a13e353*
godot: windowed isolated Godot 4.7.2-stable process (not MCP seat 6550; owner editor 41644 untouched)
viewport: 1680x1040
final_clear: production _commit_dungeon_clear ? elig ? Leave
local_tip_smoke: TIP_SMOKE_OK
milestone_selftest: MILESTONE_SELFTEST_OK
wip_safe_sync: stash wip-before-playtest-latest-1a13e353-* kept; Nathan data Saves restored
---

# Result ? production clear-commit trace (consolidated)

No all-24 claim. No owner F5. No preference mutation. Seat 6550 untouched. Real saves/WIP preserved.

## N07 contract (Pixel gap closed)

| step | proof |
|------|-------|
| 1. Production clear | Harness calls `Main._commit_dungeon_clear` only ? **no direct** `final_clear_eligible` / `note_tip` assignment on POS |
| 2. Eligibility | `CLEAR_COMMIT_TRACE before_elig=false after_elig=true ? phase=rest` |
| 3. Leave return | `N07_POS_TRACE clear?elig=true flag_before_leave=false` then milestone emits |
| 4. Once-only | Save/reload ? clear-commit ? Leave ? `N07_ONCE ? leave_final=false once_ok=true` |
| 5. Wiring excerpt | `CLEAR-COMMIT-WIRING.md` |

### Shots
- `N07-early-return-no-final.png` ? NEG early Leave (no Final line)
- `N07-final-dungeon-victory.png` ? POS 13/66, Final dungeon cleared, Abyss unlocked
- `N07-once-only-reload.png` ? once-only after reload (no second Final from replay Leave)

### Log anchors
```
CLEAR_COMMIT_TRACE before_elig=false after_elig=true ?
N07_NEG early_leave_final=false ? push_after_elig=true abort_flag=false
N07_POS_TRACE clear?elig=true flag_before_leave=false
N07_POS ? has_final=true ? abyss_locked=false COPY_GAP_summary=true
N07_ONCE reload_clear_elig=true leave_final=false flag=true
```

**COPY_GAP** `postrun.summary.final_clear` remains non-final.

## ca479497 ? 1a13e353 mapping
- Prior #491 merged as `1a13e353` into `playtest/latest`
- This lane retested on exact merged head (watermark `1a13e353*` dirty: `.import` + Nathan Save WIP + this branch)

## Other cases (unchanged honesty)
| case | verdict |
|------|---------|
| 01 tutorial | PASS reachable finish; **full in-dungeon rails still unautomated** |
| 05 offer-decline | PASS live `_make_item` seen; decline no bank; **full mill click UI unautomated** |
| 23 N08 | PASS fixture bank (**not physical acquisition**) |
| RM | NOTRUN ? no `reduce_motion` ProjectSettings key; preference mutation banned |
| SC | PARTIAL ? SCALE viewport/window log only |

## Remaining precise limits
1. Full mill click offer-decline UI  
2. Full in-dungeon tutorial rails  
3. Physical N08 acquisition  
4. RM OS/editor a11y toggle (unsupported from harness)  
5. SC full UI scale mutation suite  
6. COPY_GAP `postrun.summary.final_clear`  
7. No all-24 acceptance  

## Tip-smoke
`TIP_SMOKE_OK` on this checkout before merge packaging.
