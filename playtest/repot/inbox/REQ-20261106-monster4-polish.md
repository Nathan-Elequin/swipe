---
id: REQ-20261106-monster4-polish
status: open
priority: normal
branch: cursor/monster4-polish-tip-fa6f
created: 2026-11-06T08:45:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → fight Huntsman / Quicksand Crab / Phantom / Collector (dev deck or seeded pool)
---

# Monster4 polish — slash plates + phantom/collector idle

Nathan-locked PixelLab slash strips for huntsman A, quicksand_crab B, phantom B, collector A. New 64×64 facing idle for phantom A + collector A only. Slash loader allowlists those four ids; other monsters keep facing/wheel fallback. Combat SFX unchanged (#426).

## What to verify

- Slash cut-in for Huntsman / Quicksand Crab / Phantom / Collector uses new `anim/slash/{id}_slash_f0..f3` (48×48, Nearest), not facing dupes.
- Phantom and Collector idle/facing loop uses new distinct idle frames (not facing-plate duplicates).
- Huntsman and Quicksand Crab facing idle unchanged from tip.
- Other monsters still ignore Kenney `anim/slash/` (facing/wheel fallback).
- No SFX / catalog number / combat-logic regressions.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | fight | Face Huntsman, trigger Attack callout slash | Bow-raise slash strip (A), 48×48 | 01-huntsman-slash.png |
| 02 | fight | Face Quicksand Crab, slash | Claw-lunge slash strip (B) | 02-crab-slash.png |
| 03 | fight | Face Phantom, slash | Flare/reach slash strip (B) | 03-phantom-slash.png |
| 04 | fight | Face Collector, slash | Specimen-jar thrust slash (A) | 04-collector-slash.png |
| 05 | fight | Face Phantom idle | New haze idle (frames differ) | 05-phantom-idle.png |
| 06 | fight | Face Collector idle | New vials/staff idle (frames differ) | 06-collector-idle.png |

## Pass criteria

- Each expect readable in the PNG; blurry Linear filter = fail.
- Wrong slash (facing still) for the four allowlisted ids = fail.
- Huntsman/crab idle look changed vs tip = fail.

## Outbox path

`playtest/repot/outbox/REQ-20261106-monster4-polish/`
