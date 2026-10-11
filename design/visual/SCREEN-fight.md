# SCREEN — fight · Direction A "Torchlit Burrow"

**Mockup(s):**
- [fight-hit_v1.png](mockups/fight-hit_v1.png) · Doop frame `qnOGfbexd8` on [Swipe Art Refresh — Prep](https://doop.design/c/Evbwm-9bMX)
- [fight-blocked_v1.png](mockups/fight-blocked_v1.png) · Doop frame `FB7xQp1Eil` on [Swipe Art Refresh — Prep](https://doop.design/c/Evbwm-9bMX)
- [fight-slain_v1.png](mockups/fight-slain_v1.png) · Doop frame `HsXVM55X71` on [Swipe Art Refresh — Prep](https://doop.design/c/Evbwm-9bMX)

**Scene:** `scenes/ui/fight.tscn` · **Theme:** `themes/swipe_theme.tres` · **Tokens:** [style-guide.md](style-guide.md)

## Purpose
Fight resolution. Fixes Cursor note 7: no red wash, the hand stays visible on BLOCKED, and clear SLAIN/BLOCKED banners.

## Layout (1680×1040, px)
| Node | Rect / anchor | Theme |
|---|---|---|
| Wheel | the full wheel stays. Facing alcove: fill edge `#7A4E2B`, gold stroke, gold seat border. The other 7 seats and alcoves drop to 45 % alpha | — |
| Hub | live player HP / BLK | — |
| Column ↳ cue | `cue.fighting` | CueLabel |
| Column ↳ Monster plate | owner_plate.tscn 30 px below the cue, border in the rank colour, showing the monster's flavour line | — |
| Column ↳ Resolve button | at the bottom, full width × 80. **Hit pending:** ButtonDanger `combat.take_hit` ({n} = damage). **Blocked or slain:** ButtonGold `combat.safe` | — |
| Hand | **always visible**. Spent cards stay in place at 38 % alpha until the fight ends | hand_card.tscn |
| BLOCKED banner | blue pixel shield 180×140 above the facing seat, plus a plate with `combat.blocked` (Pixelify 44, `#E9F4FF` on `#0F2233`, 5 px blue border), centred on x 548 at y ≈ 480 | `assets/vfx/vfx_block_shield.png` |
| SLAIN banner | red pixel X (18 px strokes) over the facing seat, plus a plate with `combat.slain` (Pixelify 44, `#FFE4DE` on `#2A0D0A`, 5 px red border), top at y 622 | `assets/vfx/vfx_slain_x.png` |
| Damage numbers | "−{n}" in Pixelify 64 white with a 4 px red offset shadow next to the hub, and "−{n}" in Pixelify 60 red next to the hearts (numbers only, no copy) | — |

## States
Hit: hearts being lost show the cracked frame, then go empty. The hub flashes white with a gold ring for 0.1 s. Blocked: the hub's BLK value pulses blue. Slain: the monster plate's HP drops to 0 and the portrait desaturates.

## Motion
Hit, in order: hit-stop 0.07 s → wheel shake ±8 px for 0.18 s → red edge vignette 0 → 0.55 → 0 (0.08 s in / 0.35 s out) → damage numbers float up 40 px over 0.6 s → hearts crack, then go empty 0.2 s later. A red bolt (8 px polyline) flashes from the facing seat to the hub for 0.1 s. BLOCKED: shield pop-in (0.18 s) plus 12 blue square particles. SLAIN: each X stroke draws in over 0.12 s, the banner pops in, and the seat sprite fades out over 0.4 s.

## Text keys (PLAYER_COPY; Jam owns the wording)
`cue.fighting`, `combat.take_hit`, `combat.safe`, `combat.blocked`, `combat.slain`

## Rules
- Never show the word "Tier". The tier word comes from `tier.N.name` (Weak / Tough / Deadly).
- Every player-facing string comes from `data/player-copy.json` via PLAYER_COPY by the keys below. Never hard-code a string, and don't edit anything under `data/`. If a key doesn't exist yet (Jam is adding `pause.master`, `pause.music`, `pause.sound`, `door.seat_hint`), show `TODO(copy):<key>` and list it in the QA notes.
- The wheel stays visible on every in-run screen. Only Pause dims it.
- Wheel centre (548,350) and the hand centred on x 547 are locked.

## Done when
- [ ] No full-screen red overlay: red only at the screen edges, max 0.55 alpha
- [ ] The hand is visible in all three states
- [ ] The BLOCKED/SLAIN banners sit on the wheel near the facing seat, not over the column
- [ ] Non-facing monsters are dimmed, not hidden
- [ ] Side-by-side QA saved to `design/visual/qa/fight_qa_v1.png`, with differences listed

## Cursor prompt (copy-paste)
```text
Read design/visual/style-guide.md and design/visual/SCREEN-fight.md, and look at the mockup PNG(s) they link.
Build scenes/ui/fight.tscn as its own Control scene using themes/swipe_theme.tres (create or extend the theme per style-guide.md section 4 if it doesn't exist yet). Wire it into main.gd in place of the current code-drawn version. Keep all game logic and signals the same: this is a visual change only.
Rules: no edits under data/. Every string comes from PLAYER_COPY by the keys in the spec. Never hard-code text; for a missing key show TODO(copy):<key> and list it. Never display the word "Tier" (tier names come from tier.N.name). Nearest filtering, snap 2D to pixel, fonts with antialiasing off. No blur, glass or full-screen colour washes. The wheel stays at centre (548,350) and stays visible. Reuse owner_plate.tscn and hand_card.tscn if they exist; otherwise build them per SCREEN-placement.md and SCREEN-hand-card.md.
Then run the game with godot-mcp, get to this state, take a 1680x1040 screenshot, save a side-by-side (mockup left, build right) to design/visual/qa/fight_qa_v1.png, and list every spec item you couldn't match and why. Max 2 tweak rounds.
```
