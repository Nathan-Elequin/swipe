# QA — 2026-10-11 Sprites, theme, hand-card

## Feature

- Name / id: Direction A sprites + `hand_card.tscn`
- Spec: `design/visual/CURSOR-PROMPTS-A.md` (theme setup, then hand-card), `design/visual/SCREEN-hand-card.md`, `design/visual/style-guide.md`

## Result

PASS WITH NOTES

## Checklist

| Check | Expected | Actual | Evidence | Pass/Fail |
|---|---|---|---|---|
| Item sprites from `assets/sprites/` | `item_<id>.png` | Knife, book, watch, shield, jar, medallion, boot, bomb paths on cards | `design/visual/qa/sprites_qa_v1.png`; exec dump | Pass |
| Monster sprites from `assets/sprites/` | `mon_<id>_idle.png` | Skeleton, dragon, beggar, golem, goblin, ogre, hornet | same PNG; exec `mons[].src` | Pass |
| Unique pixels | no two new sprites share a hash | SHA256 groups empty | shell hash | Pass |
| Fallback ids listed | atlas/old PNG only if missing | left_bracer, caltrops, cursed_scroll, spider_egg | `art.missing_sprites` | Pass |
| Nib not Goblin atlas | `nib_talk.png` 128px | AtlasTexture region 16×16 from `nib_talk.png`, face 128×128 | `sprites_nib_qa_v1.png`; exec atlas path | Pass |
| Nearest / 4× | 64px board icons | icon min 64, filter nearest | dump `icon:64` | Pass |
| Hand 140×190; 8 cards 124 / gap 10 | | 124×190, sep 10 | dump | Pass |
| No "—" / "X" | `?` + tag | Pocketwatch `?`; no em dash | screenshot | Pass |
| No "Tier" | Weak/Tough/Deadly metals only | bronze/silver/gold borders; no Tier word | screenshot | Pass |
| PLAYER_COPY only | missing → `TODO(copy):<key>` | tags show TODO keys | screenshot + `COPY.missing_keys` | Pass |
| Locked copy untouched | no `data/` edits | none this turn | git | Pass |
| Errors | none new | stale `face_t` in editor log only | editor log | Pass |

## Bugs

None that fail the sprite rewire.

1. **Repro** — mill with Grief Jar: heart icon sits next to 0.
2. **Likely file** — `item_card.gd` `set_loss_icon`
3. **Suggested fix** — hide `_loss` on board cards (inspect can keep it)
4. **Severity** — polish (spec: one value)

## Balance notes

Visual only. Starter mill HP 6 / BLK 0. No combat this pass.

## Player-facing copy issues

Flag only. Do not rewrite locked fields.

- `hand.tag.atk`, `hand.tag.blk`, `hand.tag.heal`, `hand.tag.ko`, `hand.spent` are missing. Cards show `TODO(copy):…`. Jam owns the wording.

## What was fixed this loop

- Loop 1: compact width was reset by `show_formula`; mockup blit format mismatch (black left).
- Loop 2: TODO tags clipped to garbage; now wrap at 8px. KO TODO still does not fill The Boot slot.
- Still left: nine-slice PNGs, card pop-in, hand x 32–1062, Grief Jar heart, wheel screen.

## Next agent: start here

1. Resume Direction A at **wheel** (`design/visual/SCREEN-wheel.md`, mockups `wheel-ready_v1.png` / `wheel-spinning_v1.png`).
2. Do not restyle title / fight / draft-gate until that order.
3. Do not edit `data/`. Keep `TODO(copy):` until Jam saves those keys.
4. Wheel centre stays (548, 350).
