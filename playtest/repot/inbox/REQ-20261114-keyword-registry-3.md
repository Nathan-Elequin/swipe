---
id: REQ-20261114-keyword-registry-3
status: open
priority: high
pr: pending
branch: cursor/keyword-registry-3-4b75
tip_sha: f80ec53f
created: 2026-11-14T10:50:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → Brand New (fresh save) → Skip tutorial → enter Verdant Hollow fight. Real mouse only — no `_dev_*` / `preview_*` / forced `show_def`.
---

# Neighbor / Keep / Attack keyword cards

Three words that were only colored ink are now registered keyword defs and render as `kw:` chips, so the autoshow stack, first-sighting pulse, and log stacks pick them up: Neighbor, Keep, Attack. Bodies are the copy owner's exact lines.

## What to verify

- Fresh save. Real mouse only (no `_dev_*` / `preview_*` / forced `show_def`).
- Poison Flask hover: stack includes Neighbor + Poison parchment cards; text fully readable; cards stay on screen; do not cover the wheel or the plate.
- Draft pick with Keep and/or Attack on the plate (e.g. Throwing Knife): Keep and Attack cards appear in the stack beside the draft inspect plate; fit and stay inside 1680×1040; no wheel overlap.
- Wheel monster hover showing Attack (e.g. Needleback): Attack card beside the monster plate; fit; no wheel cover.
- No "Tier" / "ATK" labels invented on the cards. No player-copy rewrites beyond keyword markup.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | fight | Brand New → Verdant Hollow; hover hotbar **Poison Flask** | Neighbor + Poison parchment cards stacked beside plate; readable; no wheel/plate cover | 01-poison-flask-neighbor-poison.png |
| 02 | fight | same save; open a draft pick that shows Keep and Attack (Throwing Knife if offered, or any Keep/Attack plate) | Keep and Attack cards in the stack; fit on screen; no wheel cover | 02-draft-keep-attack.png |
| 03 | fight | hover a wheel monster whose ability names Attack (Needleback / similar) | Attack card beside monster plate; fit; no wheel cover | 03-wheel-monster-attack.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs). If the Play window framebuffer is smaller, scale design rects by `framebuffer/viewport` before cropping.
- Each `expect` readable in the PNG without guessing.
- Cards fit, stay on screen, and do not cover the wheel.
- `RESULT.md` marks each id pass/fail with one line of evidence.

## Outbox path

`playtest/repot/outbox/REQ-20261114-keyword-registry-3/`
