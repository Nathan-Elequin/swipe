---
id: REQ-20261108-collection-A
status: done
priority: high
tip_sha: 59e8ca511259155995eef52b98b21850fbae027e
branch: playtest/latest
created: 2026-11-08T04:30:00-06:00
created_by: collection-a-cloud
viewport: 1680x1040
entry: F5 playtest hub → Brand New or Middle Progress → Verdant campaign loop; Progress menu + optional Cabin. Use isolated disposable userdata only.
note: >
  Merged code PRs #474/#475/#476/#477 are tip-smoke CI only — NOT runtime acceptance.
  Drained on tip 59e8ca51 (includes Collection A + buckler). Outbox RESULT.md + shots committed.
---

# Collection Journey A — runtime acceptance matrix (Cherry)

**Authority:** OWNER-CONTRACT + approved-A-build. Doop PNGs are design refs only — not evidence.

**CI vs acceptance:** Tip-smoke SUCCESS on #474/#475/#476 proves headless rail smoke only. Screen-by-screen **runtime** verification on the exact tip below is required before any slice is called accepted. Do **not** claim F5-ready from cloud.

## Tip under test

| Field | Value |
|-------|--------|
| Repo | `Nathan-Elequin/swipe` |
| Branch | `playtest/latest` |
| Exact tip SHA | `4a1696778624cdf2d78007294c63cf83683df8c7` (#477 merge; includes #474+#475+#476+#477) |
| Note | Tip-smoke ≠ runtime acceptance. Cherry drains this SHA before any slice is accepted. |

## Required evidence (all required)

1. **Exact full tip SHA** recorded in RESULT.md (`git rev-parse HEAD` of the checkout that ran shots).
2. **`./tools/qa/run_collection_journey.sh`** → `COLLECTION_JOURNEY_OK` (Cherry Godot 4.7.2; cloud lacks Godot).
3. **Actual game screenshots** 1680×1040 from Godot runtime (godot-mcp or shot harness) — not Doop exports. Note any scaling/viewport mismatch.
4. **Isolated disposable saves** — temp `XDG_DATA_HOME` / override cabin+campaign paths; never mutate Nathan’s live profile.
5. **Input / persistence outcomes** logged pass/fail:
   - mouse + keyboard reach same choices
   - visible focus, Tab, Enter, Back/Esc restore caller
   - Skip recap / skip milestone queue → durable facts still shown; no double grant
   - reduced-motion (if setting exists): final states without stagger pans
   - reload mid-stagger / after bank / after cabin visit → idempotent; seen persists; no lost haul → banked on death
6. **Baseline failures** listed separately from new regressions.
7. **Copy audit** (placeholders only until Spin authors):

| Key | Status in code | Production? |
|-----|----------------|-------------|
| `postrun.collection.item_seen` | internal placeholder via `PLAYER_COPY.text` fallback | **No** — not final |
| `run.collection.quiet_summary` | internal placeholder | **No** |
| `run.collection.quiet_summary_threshold` | internal placeholder | **No** |
| Existing `postrun.collection.item_*` / `cabin.tip.*` / `postrun.summary.*` | reuse approved keys where wired | Yes if key exists in `player-copy.json` |

Do not invent substitute player wording. Do not treat `[Spin copy: …]` strings as final.

## Screenshots required (1680×1040)

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | progress Collection | Isolated save: ≥1 seen-unbanked + ≥1 banked in b1 | Seen cell ≠ missing (pattern+text); banked = Collected | 01-catalogue-seen-vs-banked.png |
| 02 | progress Overview | Same return with ≥1 new banked | Truthful summary; New! path | 02-return-receipt-overview.png |
| 03 | progress Collection | Locked later area tab | Locked badge; no future spoiler names | 03-area-locked.png |
| 04 | dungeon ready | Campaign run, 1+ unbanked held | Quiet strip banked X/5 + held new; New! only unbanked | 04-inrun-quiet-strip.png |
| 05 | progress Overview | Return crossing 4→5 banked | Milestone gate line; Skip durable | 05-milestone-gate.png |
| 06 | cabin hall | Progress → Visit Cabin after hall unlocked | Hall (not forced fireplace); focus played case; no S7 bank replay | 06-cabin-optional-focus.png |
| 07 | progress / reload | Reload during bank stagger or mid-milestone | Already-committed receipt; no double credit | 07-reload-idempotent.png |
| 08 | loss receipt | Die with seen-unbanked held | No bank credit; seen retained in catalogue | 08-loss-seen-retained.png |

## Pass criteria

- Every row shot at **1680×1040** from **real Godot** on the recorded tip SHA (or document exact viewport).
- `./tools/qa/run_collection_journey.sh` OK on that checkout.
- Input + reload checks filled in RESULT.md.
- Copy table filled: reuse vs placeholder — no placeholders marked final.
- Baseline failures named separately.
- Cloud agents must **not** set `status: done`.

## Outbox path

`playtest/repot/outbox/REQ-20261108-collection-A/`

## Pasteable Cherry drain prompt

```
Collection Journey A — RUNTIME acceptance drain (NOT tip-smoke)

1) Sync: git fetch origin playtest/latest && git checkout playtest/latest && git pull --ff-only
   Confirm: git rev-parse HEAD
   Expected tip now: f644a44ae0079e16adccc9de0e593ef3caf17a0b
   If #477 cabin already merged, use that newer tip and update playtest/repot/inbox/REQ-20261108-collection-A.md tip_sha to match.

2) Headless: GODOT=<Godot_v4.7.2-stable_*> ./tools/qa/run_collection_journey.sh
   Require COLLECTION_JOURNEY_OK. Record command + exit in RESULT.md.

3) Isolated userdata only (do not touch live home_cabin/campaign saves).
   F5 playtest hub → exercise Verdant leave / death / Visit Cabin paths for rows 01–08 in REQ-20261108-collection-A.md.
   Shoot 1680×1040 in-game into playtest/repot/outbox/REQ-20261108-collection-A/shots/.
   Cover mouse+keyboard, focus/Tab/Enter, Esc/back, Skip, reduced-motion if available, reload idempotence.

4) Write playtest/repot/outbox/REQ-20261108-collection-A/RESULT.md:
   - exact tip SHA tested
   - collection_journey.sh result
   - pass/fail per shot id + input/reload notes
   - copy audit: postrun.collection.item_seen, run.collection.quiet_summary, run.collection.quiet_summary_threshold = placeholders (not final); list reused approved keys
   - baseline failures separate from new fails

5) Set inbox status done only after matrix complete. Commit+push:
   [repot] fulfill REQ-20261108-collection-A

Do NOT claim F5-ready or MVP accepted from tip-smoke alone. Doop screenshots are not evidence.
```
