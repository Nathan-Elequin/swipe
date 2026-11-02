---
id: REQ-20261102-hotbar-item-card-layout
status: open
priority: high
branch: cursor/hotbar-item-card-layout-888f
base: playtest/latest
created: 2026-11-02T17:30:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress / Continue → any fight with a full-ish hotbar (weapon + block + skull/effect + multi-icon). Idle shots only — do not hover the target slots.
---

# Hotbar item-card idle layout pass

Shared `ItemCard` / `ItemFace` idle stack on the H3-B2 172×148 plates. Title closer to the top edge, sprite ~+20%, idle effect glyphs ~+50% and vertically centered in the leftover band under the sprite. Hover / showcase keeps its richer layout. Nearest filter. No player-facing copy changes. Stay out of Take arc / move arrows.

## Before → after constants (exact)

| knob | before | after |
|------|--------|-------|
| `CARD_W` × `CARD_H` | 172 × 148 (unchanged) | 172 × 148 |
| StyleBox `content_margin_top` (idle) | 3 | **1** (`IDLE_CONTENT_MARGIN_TOP`) |
| Pad `margin_top` | 3 | **1** (`IDLE_PAD_TOP`) |
| Idle VBox `alignment` | `CENTER` | **`BEGIN`** (title at top; face host fills leftover) |
| Title min height (idle) | 22 | **16** (`IDLE_TITLE_H`) |
| Item sprite min size (idle) | 48×48 | **58×58** (`IDLE_ICON`, +20%) |
| Face / number host min height | 32 | **40** (`IDLE_FACE_HOST_MIN_H`) + `SIZE_EXPAND_FILL` |
| `ItemFace.SIZE_HOTBAR` | 24 | **36** (+50%) |
| Face number font (hotbar) | 14 | **18** |
| Face text font (hotbar) | 12 | **16** |
| Offer / showcase sizes | 48 glyph / 128 sprite / etc. | unchanged |
| Offer detection | host height ≥ 50 | explicit `set_offer_mode` (idle host now expands) |

Approx title-to-top: was ~content 3 + pad 3 + ~half VBox slack (~16) ≈ **22px**; now content 1 + pad 1 + short title box ≈ **~6–8px** (about one third).

## What to verify

- Idle title sits near the top of every hotbar plate (no large empty band above the name).
- Item sprite reads larger than tip-before (~20%).
- Idle effect glyphs (skull, shield pip, impact burst, multi-icon rows) are clearly bigger and vertically centered between sprite and bottom edge — not stuck under the sprite with empty space below.
- Multi-icon rows (Fangs / Left Bracer / Throwing Knife) still fit without clipping.
- Hover / inspect showcase still shows ability text; idle spacing does not fight it.
- Nearest filter; no soft blur. No “Tier” word anywhere on the card.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | fight hotbar | idle Chakram / any ATK weapon with impact+number | title near top; larger sprite; bigger centered impact glyph | 01-weapon-chakram.png |
| 02 | fight hotbar | idle Left Bracer (shield + direction) | multi-icon row larger + vertically centered under sprite | 02-block-bracer.png |
| 03 | fight hotbar | idle The Boot (single skull) | skull ~36px, centered in lower band | 03-skull-boot.png |
| 04 | fight hotbar | idle Fangs or Throwing Knife (3–4 icons) | multi-icon row fits; still centered; no clip | 04-multi-icon.png |
| 05 | fight hotbar | full 2×5 row at 1680×1040, no hover | every plate shares the new stack; titles consistently high | 05-full-hotbar.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs).
- Each `expect` readable in the PNG without guessing.
- `RESULT.md` marks each id pass/fail with one line of evidence.

## Outbox path

`playtest/repot/outbox/REQ-20261102-hotbar-item-card-layout/`
