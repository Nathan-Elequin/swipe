# SCREEN — draft-gate · Direction A "Torchlit Burrow"

**Mockup(s):**
- [draft-gate_v2.png](mockups/draft-gate_v2.png) · Doop frame `b8K004zp1A` on [Swipe Art Refresh — Prep](https://doop.design/c/Evbwm-9bMX)

**Scene:** `scenes/ui/draft_gate.tscn` · **Theme:** `themes/swipe_theme.tres` · **Tokens:** [style-guide.md](style-guide.md)

## Purpose
**A v2 delta.** The prep patch's `design/visual/specs/DRAFT-GATE-SPEC.md` still holds except for the changes below. Tokens and theme now come from `style-guide.md` / `themes/swipe_theme.tres`. The gate is the column's plate content.

## Layout (1680×1040, px)
| Change | v1 (prep patch) | v2 (this pack) |
|---|---|---|
| Wheel centre | (710,350) | **(548,350), locked** |
| Hand | centred on x 710 | **centred on x 547**, 140×190 cards with a 14 px gap (124×190 / 10 px at 8 cards). The mockup shows 150 wide; use 140 |
| Small labels | THE MONSTER / THE LOOT | **`door.owner` / `door.shiny`**: locked copy is "THE MONSTER" / "THE LOOT". Draw them in VT323 26 dim so the wording from the copy file shows as written |
| Guard line | {tier} | `door.guard` "Guarded by a {tier} monster", with **{tier} filled from `tier.N.name`** (Weak/Tough/Deadly); the tier word sits in a TierPill-coloured chip |
| Theme source | `scripts/ui_palette.gd` | `themes/swipe_theme.tres` per style-guide.md |
| Fonts | `assets/fonts/` | `assets/ui/fonts/` |
| Scene | inside main.gd | `scenes/ui/draft_gate.tscn` (column plate) |
| Nib | bottom-left of the hand | (24,900) |

## States
As in DRAFT-GATE-SPEC.md.

## Motion
As in DRAFT-GATE-SPEC.md.

## Text keys (PLAYER_COPY; Jam owns the wording)
`cue.ask`, `door.help`, `door.owner`, `door.shiny`, `door.guard`, `tier.N.name`, `door.take`, `door.pass`, `door.pass_one`, `door.pass_none`

## Rules
- Never show the word "Tier". The tier word comes from `tier.N.name` (Weak / Tough / Deadly).
- Every player-facing string comes from `data/player-copy.json` via PLAYER_COPY by the keys below. Never hard-code a string, and don't edit anything under `data/`. If a key doesn't exist yet (Jam is adding `pause.master`, `pause.music`, `pause.sound`, `door.seat_hint`), show `TODO(copy):<key>` and list it in the QA notes.
- The wheel stays visible on every in-run screen. Only Pause dims it.
- Wheel centre (548,350) and the hand centred on x 547 are locked.

## Done when
- [ ] As in DRAFT-GATE-SPEC.md
- [ ] Wheel and hand positions match the other A screens exactly
- [ ] Labels come from door.owner / door.shiny (monster / loot, never owner / bait hard-coded), and the rank word from tier.N.name
- [ ] Leave uses `COPY.fill("door.pass", {"n": n})` when n ≥ 2, `door.pass_one` at 1, `door.pass_none` at 0. No literal `{n}` on screen
- [ ] Side-by-side QA saved to `design/visual/qa/draft_gate_qa_v1.png`, with differences listed

## Cursor prompt (copy-paste)
```text
Read design/visual/style-guide.md and design/visual/specs/DRAFT-GATE-SPEC.md and design/visual/SCREEN-draft-gate.md, and look at the mockup PNG(s) they link.
Build scenes/ui/draft_gate.tscn as its own Control scene using themes/swipe_theme.tres (create or extend the theme per style-guide.md section 4 if it doesn't exist yet). Wire it into main.gd in place of the current code-drawn version. Keep all game logic and signals the same: this is a visual change only.
Rules: no edits under data/. Every string comes from PLAYER_COPY by the keys in the spec. Never hard-code text; for a missing key show TODO(copy):<key> and list it. Never display the word "Tier" (tier names come from tier.N.name). Nearest filtering, snap 2D to pixel, fonts with antialiasing off. No blur, glass or full-screen colour washes. The wheel stays at centre (548,350) and stays visible.
Then run the game with godot-mcp, get to this state, take a 1680x1040 screenshot, save a side-by-side (mockup left, build right) to design/visual/qa/draft_gate_qa_v1.png, and list every spec item you couldn't match and why. Max 2 tweak rounds.
```
