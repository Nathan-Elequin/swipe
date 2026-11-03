---
id: REQ-20261103-dungeon-clear-resolve
status: done
priority: high
tip_sha: e855e7e6
branch: playtest/latest
created: 2026-11-03T23:30:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress → campaign delve 0 → clear the wheel. Viewport 1680×1040. Shots 01–07 use clear_parade.freeze_at. Shot 08 uses freeze_at = -1.
---

# Dungeon-clear resolve v2 (fold → victory → jump → Rope Exit)

Adventure full dungeon clear no longer burrows. The combat wheel reverse-accordion folds (~0.42s), `sting.clear` fires at fold start, Sprout dances `sprout_victory_f0–f3`, then crouches / jumps / falls off the bottom through an upward dissolve wipe into Rope Exit as one continuous jump. Landing handoff A: overlay → Rope Exit hero on the squash frame. Spec: `design/visual/dungeon-clear-resolve/SCREEN-dungeon-clear-resolve.md`.

`freeze_at` values for deterministic shots: **0.16**, **0.40**, **0.80**, **1.35**, **1.75**, **2.06**, **2.40** (01–07). Leave `freeze_at = -1` for normal play and for shot 08.

## What to verify

- No burrow mouth, curtain, mound, hero_arrive, land dust, clear_burst, or clear_embers in any shot.
- No transparent empty wheel disc or `_nest_wheel` slide on this path.
- Wheel fold fans toward the bottom hinge with dungeon BG visible through gaps.
- Exactly one overlay Sprout (hub Sprout hidden via `hub_parade_hide`).
- Wipe edge moves bottom→top on both cover and reveal; no long all-black hold.
- Log contains exactly one `end dungeon N` per clear (`resolve swap t=1.98` also logged).
- Rope Exit opens at full alpha and is interactive after ~2.5s.
- Clicks blocked during the resolve.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | fight | freeze_at 0.16 | wheel mid-fold: wedges fanned toward the bottom hinge, gaps showing **dungeon BG** (not black, not a transparent disc). ONE overlay Sprout on the hub spot, no hub Sprout under it. Spin arrows/counter fading. No rope | 01-fold-mid.png |
| 02 | fight | freeze_at 0.40 | wheel almost gone (thin blade or nothing at the hinge), gold aura bloom at the hinge, dungeon BG fully visible, Sprout on victory frame. No burrow mouth, mound or curtain | 02-fold-bloom.png |
| 03 | fight | freeze_at 0.80 | Sprout dancing `sprout_victory` (arms up, f1/f2), facing right, unmirrored, at 96 px, gear (if worn) aligned. No wheel, no burst, no embers | 03-victory.png |
| 04 | fight | freeze_at 1.35 | crouch squash on f0, feet still on the same baseline as 03 | 04-crouch.png |
| 05 | fight | freeze_at 1.75 | Sprout falling (f2) in the lower third, black dissolve front rising from the bottom with chunky pixel teeth. No curtain | 05-fall-wipe.png |
| 06 | black→rope | freeze_at 2.06 | screen mostly black, the bottom band of the **Rope Exit chamber** revealed under a dissolve edge, Sprout entering from the **top** above the black. No arrive pop-up, no land dust | 06-fall-in.png |
| 07 | rope | freeze_at 2.40 | Sprout landing squash on the Rope Exit hero spot. Rope Exit fully visible at full alpha (no half-faded chrome). Only ONE hero visible | 07-land.png |
| 08 | rope | freeze_at -1, ~0.5 s after return | rope exit open and interactive, hub flags restored, `dungeons_cleared` incremented exactly once (check the log line `end dungeon N`), clicks blocked during the resolve and live after | 08-after.png |

## Pass criteria

- All PNGs at 1680×1040 under `playtest/repot/outbox/REQ-20261103-dungeon-clear-resolve/shots/`.
- No burrow mouth, curtain, mound, hero_arrive or land dust in any shot. No wax seal. Nothing mirrored.
- No transparent empty wheel disc or wheel slide in any shot.
- 06 vs 05: the wipe edge moves the same direction (up), and there is no all-black hold frame longer than 1 frame.
- Log contains exactly one `end dungeon N` per clear.
- Outbox: `playtest/repot/outbox/REQ-20261103-dungeon-clear-resolve/shots/`.

## Outbox path

`playtest/repot/outbox/REQ-20261103-dungeon-clear-resolve/`
