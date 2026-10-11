> SUPERSEDED 2026-10-11, use CURSOR-PROMPTS-A.md

# Cursor prompt: draft gate, Direction A "Torchlit Burrow", Layout 1 "Side Door"

Paste everything below the line into Cursor (Agent mode) in `C:\Users\Natha\Documents\boss-rush`.

---

You are working in the Godot 4.7 project "Swipe" (gl_compatibility, 1680×1040, UI built in code). Task: rebuild the **draft gate** (draft/mystery-door screen) in the approved visual direction **A · Torchlit Burrow**, using **Layout 1 · Side Door**. Reference mockup: `design/visual/mockups/draft-gate-A-torchlit-burrow.png`. Spec: `design/visual/specs/DRAFT-GATE-SPEC.md`.

HARD RULES
- Do NOT edit `data/` (player-copy.json, player-copy.csv, author-locks.json, content-board.json, catalog.json, runtime.json). Do not trigger the in-game Script editor Save. `git diff --stat` must show no changes under `data/`.
- Every player-facing string comes from `PLAYER_COPY` / `COPY` (`.text()` or `.fill()`). A code fallback must be the CURRENT text in `data/player-copy.json`, copied verbatim. Never invent wording.
- Never show the word "Tier". Internal tier 1/2/3 maps to `tier.1.name` / `tier.2.name` / `tier.3.name` (Weak / Tough / Deadly).
- Do not change rules, numbers, ids, phase order or combat. Scope is the draft gate (ask → reveal → seat) plus one shared palette/fonts file. Do not restyle title, tutorial, combat, inspect or pause.
- Pixel art: nearest filtering, integer scales only (sprites at 4×, loot/reveal at 8×).

STEP 0: Shared look (new files only)
1. Create `scripts/ui_palette.gd` (`class_name UiPalette`) with these constants:
   SOOT #1A120E (ground), OAK #3B2618 (panel), OAK_2 #4A2F1F (inset), EDGE #7A4E2B (frame), RIVET #B8733A, PARCHMENT #E9D3A1 (text), DIM #A88C66 (secondary text), BAIT_GOLD #FFD84A (the ONLY bright accent: loot border, Take button, wheel pointer — token name stays), TORCH #F09A34 (rule line, pass pips), IMP_GREEN #7BC950 (Nib/player only), ATK_RED #D5443B, BLK_BLUE #4FA3D9, TIER_WEAK #B8733A (bronze), TIER_TOUGH #C9CED6 (silver), TIER_DEADLY #FFD84A (gold).
   Also add helpers: `tier_color(t:int) -> Color` and `tier_name(t:int) -> String` (returns `COPY.text("tier.%d.name" % t, <current file text>)`).
2. Download the OFL fonts into `assets/fonts/`: Pixelify Sans (variable or Bold), Silkscreen Regular + Bold, VT323 Regular (all from fonts.google.com; add each font's OFL.txt next to it). In each `.ttf` import set Antialiasing = None, Hinting = None, Subpixel positioning = Disabled. Expose them in `UiPalette` as `FONT_DISPLAY` (Pixelify Sans), `FONT_LABEL` (Silkscreen), `FONT_BODY` (VT323).
3. Make StyleBoxFlat factories in `UiPalette`: `panel()` (bg OAK, 8 px EDGE border, 4 px inner OAK_2 via expand margin or nested panel, no corner radius, no shadow), `bait_card()` (bg OAK_2, 8 px BAIT_GOLD border — function name stays; this is the loot card), `button_primary()` (bg BAIT_GOLD, 5 px SOOT border, 6 px bottom TORCH "lip" via shadow offset (0,6) size 0), `button_secondary()` (transparent bg, 3 px EDGE border). Square corners everywhere.

STEP 1: Stop covering the dungeon (`scripts/draft_gate.gd` setup(), present_mystery(), set_seat(), dock())
- Remove the full-screen `_dim` ColorRect (or set color alpha 0 and `mouse_filter = MOUSE_FILTER_IGNORE`). Keep the gate modal in behavior: during "ask" the wheel ignores clicks; only Take, Leave and the loot card act.
- Dock the gate as a fixed right column: position (1086, 28), size (560, 952), in every draft mode (ask, reveal, seat). Do not move it between modes; delete the centred 560×620 docking.
- The wheel stays where it is today and must be 100% visible through ask, reveal and seat. Nothing may overlap the ring.
- If the editor Log panel is visible during draft, collapse/hide it while `phase == "draft"` (editor chrome only; do not delete it).
- Remove the empty square that draws above the item card (the unused slot/stamp placeholder created in setup()).

STEP 2: Gate column contents, top to bottom (ask mode)
1. Cue: `COPY.text("cue.ask")` → "Take it or leave it?" in FONT_DISPLAY 46 px, PARCHMENT, centered.
2. Rule: `COPY.text("door.help")` → "The finer the loot, the fiercer its monster." in FONT_BODY 30 px, TORCH, 10 px below the cue.
3. Door: a 300×230 arch (round top, 8 px EDGE frame, no bottom border, fill #0B0706) with a soft radial TORCH glow at the bottom (a TextureRect with a GradientTexture2D radial, alpha ~0.5). Inside it: the **pending monster** sprite at 7× (or 8×) with `modulate = Color.BLACK` (pure silhouette), two 12×8 ATK_RED "eye" ColorRects with a small glow, a rank plate (Silkscreen Bold 15 px, `tier_name(tier).to_upper()`, bg `tier_color(tier)`, 3 px SOOT border) at the top, and the small label `COPY.text("door.owner")` (Silkscreen 14 px, DIM) under the plate.
4. Loot card: 400 px wide, `bait_card()` style, overlapping the door bottom by 10 px. Inside: label `COPY.text("door.shiny")` (Silkscreen 14 px DIM), a 150×150 pedestal (rgba(0,0,0,.35), 4 px EDGE border) holding the item sprite at 8× (128 px, nearest), the item name (FONT_DISPLAY 38 px PARCHMENT), and the guard line `COPY.fill("door.guard", {"tier": tier_name(tier)})` (FONT_BODY 28 px DIM, no wrap) with the rank word on a `tier_color` chip.
   - Loot glow: tween the card's glow (a gold outer glow panel or shader) alpha 0.45↔0.85 on a 1.2 s sine loop. This is the only glowing object on screen.
   - Hover: card scales 1.00→1.03 and tilts ±2° toward the mouse (Balatro-style), 120 ms.
5. Buttons, docked to the bottom of the column (24 px side margin):
   - **Take** button, 470×84, `button_primary()`, text `COPY.text("door.take")` ("Take it") in FONT_DISPLAY 44 px SOOT. Pressing it runs the same path as clicking the card (`send_pressed` → `main._on_gate_send`). Keep the card click too.
   - **Leave** button, 470×60, `button_secondary()`, text `COPY.fill("door.pass", {"n": n})` when n ≥ 2; `COPY.text("door.pass_one")` at 1; `COPY.text("door.pass_none")` at 0. Never show a literal `{n}`. FONT_BODY 32 px PARCHMENT. Disable Leave at 0.
   - Pass pips: 3 × (34×12) rects, 10 px gap, centered under Leave; remaining = TORCH fill, spent = hollow DIM outline at 50% alpha.
6. Fix `_rank_label` in `scripts/main.gd` and `TierStamp._draw` / `scripts/boss_wheel.gd _draw_tier_num` so no "Tier N" or roman numeral text can reach players. Metal colour + plate shape, or `tier_name()`.

STEP 3: Take → reveal (same column, no layout jump)
- On Take: play `door_slam` (already bound); 80 ms hit-stop (pause gate tweens and hold the frame); 6 px shake on the gate column only (3 shakes, 120 ms); silhouette modulate BLACK → WHITE over 150 ms; the loot card shrinks and flies to its new hand slot (tween position + scale, 250 ms, ease-in), and the new hand card does a 1-frame squash pop.
- The monster plate (existing name / HP / ATK plate; scene `owner_plate.tscn`) appears inside the column under the door, in Direction A styling (OAK_2 panel, EDGE border, ATK_RED/BLK_BLUE badges). Show the monster's taunt balloon (existing taunt rows) next to the door, not over the wheel.
- Cue changes to `COPY.text("door.seat")` ("A monster approaches. Select their location.").

STEP 4: Seat
- Empty alcoves pulse (slice fill alpha 0.55 ↔ 1.0, 0.8 s) and show the existing "+". Occupied slices keep refusing clicks.
- While hovering an empty alcove, draw a dotted Line2D (TORCH, 4 px, 12/8 dash) from the door centre to that alcove.
- After seating: a "seat pop" (scale 1.15 → 1.0, 120 ms) plus the existing cloth/drop SFX. The gate returns to ask mode for the next pack without moving.

STEP 5: Hand numbers (draft screen only)
- Every hand card shows exactly one big number and a type tag (ATK / BLK / HEAL). Replace "—", "X", or an icon-only state with "?" when the value depends on the fight. Do not change the number values themselves.

ACCEPTANCE (check in F5 Play at 1680×1040)
1. Draft ask matches `design/visual/mockups/draft-gate-A-torchlit-burrow.png`: right column, no dim, wheel fully visible, real **Take it** button, Leave button with a correct pass count (once Jam updates door.pass), pips, no empty square above the card.
2. Card shows "Guarded by a Weak/Tough/Deadly monster". No "Tier", "{n}" or "{tier}" anywhere on screen.
3. Take → slam, silhouette flips, monster plate, placement cue; seat → pulsing alcoves, dotted line, pop.
4. No overlap with the Log or the wheel at any point in the draft.
5. `git diff --stat` shows nothing under `data/`. Headless smoke passes: `Godot_v4.7.2-stable_win64.exe --path . --headless --quit-after 2`.
6. Report back: files changed, what to look at in Play, and any copy key that turned out to be missing (do not add it yourself).
