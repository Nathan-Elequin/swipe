---
id: REQ-20261114-keyword-teach-halo
status: open
priority: high
branch: cursor/keyword-teach-halo-visible-b31b
tip_sha: dbd5ecd1
created: 2026-11-14T09:20:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress / Continue into a fight (fresh save or clear seen_keywords for one id)
---

# Keyword teach halo — gold pulse visible on chip

First-sighting teach used to parent `TeachHalo` under the parchment card, so `modulate.a=0` during the pulse phase hid the gold wash. Halo now lives on Main (sibling host), `top_level`, at the chip/pip global rect; card fades in with `new_star` only after the three pulses.

## What to verify

- First-sighting: three gold pulses are visible **on the chip or wheel pip** while the parchment card is still fully transparent.
- Mid open: card fading in; halo already gone/hidden.
- Card open: parchment at full alpha with `new_star`.
- No copy changes.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | fight | fresh/unseen keyword teach, mid pulse (halo.a high, card a≈0) | gold halo visible on the chip/pip; parchment still invisible | 01-teach-pulse-halo.png |
| 02 | fight | same teach, mid open | card mid alpha; star starting; halo hidden | 02-teach-mid.png |
| 03 | fight | same teach, open | parchment fully open, `new_star` visible | 03-teach-card-open.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs). If the Play window framebuffer is smaller (e.g. 1550×960), scale design rects by `framebuffer/viewport` before cropping — do not crop 1680-space rects on a smaller buffer.
- Row 01 must show a readable gold pulse on the chip/pip (not a near-black card crop).
- `RESULT.md` marks each id pass/fail with one line of evidence.

## Outbox path

`playtest/repot/outbox/REQ-20261114-keyword-teach-halo/`
