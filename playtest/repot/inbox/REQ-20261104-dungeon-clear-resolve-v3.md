---
id: REQ-20261104-dungeon-clear-resolve-v3
status: open
priority: high
tip_sha: pending
branch: playtest/latest
created: 2026-11-04T07:40:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress → campaign delve 0 → clear the wheel. Viewport 1680×1040. Shots 01–07 use clear_parade.freeze_at. Shot 08 uses freeze_at = -1.
---

# Dungeon-clear resolve v3 — proud hold + slow fold + quiet sting

Nathan lock 2026-11-04: kill victory dance loop; brief proud hold on one pose; fold ~1.10 s; duck `sting.clear` −10 dB under victory music. Spec: `design/visual/dungeon-clear-resolve/SCREEN-dungeon-clear-resolve.md` (v3). Prior fix REQ is done (`REQ-20261103-dungeon-clear-resolve-fix`).

`freeze_at` values (v3): **0.45**, **0.95**, **1.25**, **1.50**, **1.95**, **2.30**, **2.65** (01–07). Leave `freeze_at = -1` for normal play and for shot 08. Total ≈ **2.80 s**.

## What to verify

- Fold is the slow ~1.10 s reverse accordion (readable mid-fold gaps at 0.45; nearly done / aura at 0.95).
- Proud hold at 1.25 is a **still** (f2 arms-up), not a looping `sprout_victory` dance.
- Crouch → jump → fall → wipe → Rope Exit fall-in → land handoff A still continuous.
- Spin / arrows / counter hard-hidden for the whole resolve.
- Exactly one overlay Sprout (`hub_parade_hide`); no burrow / curtain / mound / arrive / dust / burst / embers.
- No `_nest_wheel` slide on this path.
- `sting.clear` plays at fold start but is soft under victory music (−10 dB / not a metal slap).
- Log contains exactly one `end dungeon N` per clear (`freeze_at` holds must not stack extras).
- Rope Exit opens at full alpha and is interactive after ~2.80 s.
- Clicks blocked during the resolve.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | fight | freeze_at 0.45 | wheel mid-fold: wedges fanned toward the bottom hinge, gaps showing **dungeon BG** (not black, not a transparent disc). ONE overlay Sprout (f0) on the hub spot, no hub Sprout under it. Spin arrows/counter fading or hidden. No rope | 01-fold-mid.png |
| 02 | fight | freeze_at 0.95 | wheel almost gone (thin blade or nothing at the hinge), gold aura bloom at the hinge, dungeon BG fully visible, Sprout on hub. No burrow mouth, mound or curtain | 02-fold-bloom.png |
| 03 | fight | freeze_at 1.25 | Sprout **proud hold** on one `sprout_victory` still (f2 arms-up), facing right, unmirrored, at 96 px, gear (if worn) aligned. No dance loop, no wheel, no burst, no embers | 03-proud-hold.png |
| 04 | fight | freeze_at 1.50 | crouch squash on f0, feet still on the same baseline as 03 | 04-crouch.png |
| 05 | fight | freeze_at 1.95 | Sprout falling (f2) in the lower third, black dissolve front rising from the bottom with chunky pixel teeth. Spin / arrows / counter hidden. No curtain | 05-fall-wipe.png |
| 06 | black→rope | freeze_at 2.30 | screen mostly black, the bottom band of the **Rope Exit chamber** revealed under a dissolve edge, Sprout entering from the **top** above the black. No arrive pop-up, no land dust | 06-fall-in.png |
| 07 | rope | freeze_at 2.65 | Sprout landing squash on the Rope Exit hero spot. Rope Exit fully visible at full alpha (no half-faded chrome). Only ONE hero visible | 07-land.png |
| 08 | rope | freeze_at -1, ~0.5 s after return | rope exit open and interactive, hub flags restored, `dungeons_cleared` incremented exactly once (check the log line `end dungeon N`), clicks blocked during the resolve and live after | 08-after.png |

## Pass criteria

- All PNGs at 1680×1040 under `playtest/repot/outbox/REQ-20261104-dungeon-clear-resolve-v3/shots/`.
- No burrow mouth, curtain, mound, hero_arrive or land dust in any shot. No wax seal. Nothing mirrored.
- No transparent empty wheel disc or wheel slide in any shot.
- 01 shows fanned wedges with dungeon BG in the gaps (slow fold mid).
- 03 is a proud **still**, not a dance.
- 05 shows lower-third fall + rising wipe; Spin stays hidden.
- 06 vs 05: the wipe edge moves the same direction (up); no long all-black hold.
- Log contains exactly one `end dungeon N` per clear (including across freeze_at holds in one session).
- Outbox: `playtest/repot/outbox/REQ-20261104-dungeon-clear-resolve-v3/shots/`.

## Outbox path

`playtest/repot/outbox/REQ-20261104-dungeon-clear-resolve-v3/`
