# SCREEN — hand-card · Direction A "Torchlit Burrow"

**Mockup(s):**
- [wheel-ready_v1.png](mockups/wheel-ready_v1.png) · Doop frame `eNckh5XnDR` on [Swipe Art Refresh — Prep](https://doop.design/c/Evbwm-9bMX)
- [fight-blocked_v1.png](mockups/fight-blocked_v1.png) · Doop frame `FB7xQp1Eil` on [Swipe Art Refresh — Prep](https://doop.design/c/Evbwm-9bMX)
- [inspect_v1.png](mockups/inspect_v1.png) · Doop frame `aawVUQrO53` on [Swipe Art Refresh — Prep](https://doop.design/c/Evbwm-9bMX)

**Scene:** `scenes/ui/hand_card.tscn` · **Theme:** `themes/swipe_theme.tres` · **Tokens:** [style-guide.md](style-guide.md)

## Purpose
One card component used everywhere (fixes Cursor note 8, inconsistent stats).

## Layout (1680×1040, px)
| Node | Rect / anchor | Theme |
|---|---|---|
| Root | PanelContainer **140×190**; **124×190 when the hand holds 8 cards** (gap 14 → 10). 6 px border in the tier colour, bg oak | `assets/ui/panels/ui_card_{weak,tough,deadly}.png`, 8 px 9-slice |
| ↳ Name | item name from data, Silkscreen 12, parchment, centred, autowrap, max 2 lines, 10 px top padding | — |
| ↳ Sprite | 64×64 TextureRect (16×16 at 4×), centred | — |
| ↳ Value row | value in Pixelify 46 + tag in Silkscreen 12, baseline-aligned, gap 6, 10 px bottom padding | — |

The hand cap is a game rule. This spec only covers how 8 cards fit, not how many are allowed.

## States
Value and tag: ATK red `3 ATK` · BLK blue `4 BLK` · HEAL green `3 HEAL` · KO plum `#A866C9` `KO` (no tag) · fight-dependent `?` plus its tag. Exactly one value per card. Hover / spent / disabled / drag as in style guide §6.

## Motion
New card pops in from the door side (x +60 → 0, 0.18 s). Spending fades `modulate:a` 1 → 0.38 over 0.12 s. After the fight, removed cards scale 1 → 0.8 and fade over 0.15 s, then the row re-centres (0.15 s EASE_OUT).

## Text keys (PLAYER_COPY; Jam owns the wording)
`item names and values from data (no new copy)`

## Rules
- Never show the word "Tier". The tier word comes from `tier.N.name` (Weak / Tough / Deadly).
- Every player-facing string comes from `data/player-copy.json` via PLAYER_COPY by the keys below. Never hard-code a string, and don't edit anything under `data/`. If a key doesn't exist yet (Jam is adding `pause.master`, `pause.music`, `pause.sound`, `door.seat_hint`), show `TODO(copy):<key>` and list it in the QA notes.
- The wheel stays visible on every in-run screen. Only Pause dims it.
- Wheel centre (548,350) and the hand centred on x 547 are locked.

## Done when
- [ ] Every card in the game uses this scene
- [ ] No card shows "—", "X", two numbers or icon-only stats
- [ ] The border colour matches the tier
- [ ] 8 cards fit between x 32 and 1062 at 124 px
- [ ] Side-by-side QA saved to `design/visual/qa/hand_card_qa_v1.png`, with differences listed

## Cursor prompt (copy-paste)
```text
Read design/visual/style-guide.md and design/visual/SCREEN-hand-card.md, and look at the mockup PNG(s) they link.
Build scenes/ui/hand_card.tscn as its own Control scene using themes/swipe_theme.tres (create or extend the theme per style-guide.md section 4 if it doesn't exist yet). Wire it into main.gd in place of the current code-drawn version. Keep all game logic and signals the same: this is a visual change only.
Rules: no edits under data/. Every string comes from PLAYER_COPY by the keys in the spec. Never hard-code text; for a missing key show TODO(copy):<key> and list it. Never display the word "Tier" (tier names come from tier.N.name). Nearest filtering, snap 2D to pixel, fonts with antialiasing off. No blur, glass or full-screen colour washes. The wheel stays at centre (548,350) and stays visible.
Then run the game with godot-mcp, get to this state, take a 1680x1040 screenshot, save a side-by-side (mockup left, build right) to design/visual/qa/hand_card_qa_v1.png, and list every spec item you couldn't match and why. Max 2 tweak rounds.
```
