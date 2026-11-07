---
id: REQ-20261107-cabinet-homecoming-restore
status: open
priority: high
branch: cursor/cabinet-homecoming-restore-9880
base: playtest/latest
created: 2026-11-07
created_by: cursor-agent
viewport: 1680x1040
entry: F5 playtest hub → campaign Verdant Hollow → extract Leave with new uniques
---

# Cabinet homecoming restoration — local runtime checklist

Scope: **one system only** (S7 bank ceremony + Spin lessons + pending reveal queue). No room flips, door matrix, Outpost consolidation, ROOM_ORDER, map launch, or unlock-math changes.

## Source checks (CI / cloud OK) — not runtime proof

```bash
python3 tools/qa/check_cabinet_homecoming.py
# expect HOMECOMING_RESTORE_OK
# prints DISTINCTION source-qa-ok-does-not-equal-runtime-verified
```

## Engine checks (Nathan local Cursor — Godot required)

Godot is **unavailable** in the cloud agent image. Source PASS ≠ runtime verified. Do **not** run the selftest against Nathan’s live play profile until isolation is confirmed.

### Runner precautions (`./tools/qa/run_homecoming_ceremony.sh`)

1. **Application seam:** selftest sets `cabin._persist_writes=false` before any `_ack_bank_presented` / `_save` (direct `godot --script` must still be safe).
2. **User-data isolation:** runner redirects `XDG_DATA_HOME` / `XDG_CONFIG_HOME` / `XDG_CACHE_HOME` / `HOME` into `mktemp` — logs-only isolation is not enough.
3. **Probe hash:** suite compares `user://home_cabin.json` meta (exists/mtime/size/md5) before vs after; runner refuses pass without `PASS ASSERT SAFE.ack_save_noop_same_meta`.
4. **Labels:** suite must print `UNCOVERED.live_dialog_fx_cancel` (bare instance ≠ live H11).
5. No Godot → exit `2` `RUNTIME_UNAVAILABLE` (not a fake green).

```bash
export GODOT="$HOME/godot/Godot_v4.7.2-stable_linux.x86_64"  # or mac/windows build
./tools/qa/run_homecoming_ceremony.sh   # expect HOMECOMING_CEREMONY_OK + SAFE.ack_save_noop_same_meta
./tools/qa/run_banking_contract.sh      # existing ledger contract still green
# Optional headless cabin nav probe if your tree has it:
# ./tools/qa/run_cabin_nav_lock_probe.sh
```

Bare-instance protocol covers: gen invalidate, stale ack, staging-token clear, tween kill, arc mid-invalidate ownership, persist noop, haul gate. It does **not** drive live give-home + full FX cancel under CabinRoot (H11 still UNCOVERED — do manually).
## Screenshot / audio / input matrix

| id | setup | expect | evidence |
|----|-------|--------|----------|
| H1 | Fresh campaign, pick uncollected item, ready phase | Hotbar shows **New!**; once, Nib: `nib.lesson.new_mark` | screenshot + note |
| H2 | First b1 extract with ≥1 NEW UNIQUE before Leave | NEW UNIQUE chips visible; once, Nib: `nib.lesson.extract_haul` (Verdant text) | screenshot |
| H3 | Leave with new uniques (hall already unlocked) | Auto pan/focus case → “Let's give these a home.” → bag smoke/rays/arcs → loud count → pegs filled | recording preferred |
| H4 | Same as H3, buses: SFX on / Music on | Arrival uses existing `cabin.item_whoosh` / `cabin.item_pop` / `cabin.shelf_chime` (user buses respected) | ears + mixer |
| H5 | Return that crosses b1 4→5 | After celebration: threshold line, then existing unlock/map-piece beat (not a fresh D2 start) | screenshot |
| H5b | New return from **non-b1** while b1 still under quota / lessons unset | **No** Verdant `nib.lesson.five_finds`; ceremony still mounts the non-b1 haul | screenshot + note |
| H6 | Duplicate-only Leave (all already banked) | No give-home, no flight, no false credit | note |
| H7 | Death / loss homecoming | No bank ceremony, no new pending | note |
| H8 | Tutorial Yes-complete → cabin | “Back in one piece…” once; **zero** swipe/bank credit; empty `bank_pending` | screenshot |
| H9 | Mid-ceremony reload | On reload: remaining `bank_pending` resumes once; already-acked IDs do not replay; ledger counts unchanged | save inspect + note |
| H10 | Push-block interrupt under 5/5 | Lands at case with existing push dialog; **no** S7 FX / no map piece; items still mount | note (intentional) |
| H11 | Cancel mid give-home / mid-flight, then re-enter ceremony | Busy/staging release without softlock; **stale coroutine must not ack pending or clear the new ceremony's locks**; earned `swiped`/`banked` unchanged; remaining `bank_pending` preserved for resume | input + save inspect (runtime required; source pattern alone insufficient) |
| H12 | Second campaign return after lessons | No repeat of New!/extract/five-finds/tutorial lines | note |

## Unavailable in cloud (enumerate)

- Windowed Godot play / audio bus verification
- Shot harness captures (`21a`/`21b`/`75`/`76`)
- Real pause-tree cabin interaction timing
- Save-file roundtrip under exported user:// on device
- `./tools/qa/run_homecoming_ceremony.sh` (no Godot binary) — exit 2 `RUNTIME_UNAVAILABLE`
- Full live give-home cancel→reentry under cabin tree (even the Godot selftest leaves this UNCOVERED)

## Pass criteria

- H3–H5 feel like restored S7, not a new FX system
- H5b: non-b1 haul never teaches Verdant five-finds
- H11: ceremony gen ownership holds under real cancel/reentry
- No double-bank; pending never equals full historic banked
- Spin lines match `data/player-copy.json` exactly (no agent string edits)
- Glint lesson left pending (Spin revising); no CLAIMED peg-twinkle teaching
- Do not merge on source QA alone
