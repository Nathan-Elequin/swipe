---
id: REQ-20261118-pixellab-final-b
status: open
priority: high
pr: 0
tip_sha: pending
branch: art/pixellab-final-b
created: 2026-11-18T22:40:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: fresh save → Brand New / Middle Progress → real player path (cabin → map → fight). No Grant / DevChrome / preview hooks.
---

# PixelLab final-B FX + HUD wiring

Wire pass for cue leaf drop-in, combat projectiles, spin land burst, tutorial glove/arrowhead, defeat signatures, heal sparkle, endless HUD plaque/coin/ring, utility moments, torch-iris wipe overlay, Crystal Cavern map stamp, card toss poof (tinted defeat_poof), map hero hop + route-dot pop, trophy candle glint + cabin dust, Nib cheer/shrug frames. Title emblems are placed under `assets/ui/title/emblem/` unwired (do not open the title screen). Cloud agent cannot F5; Cherry fulfills with godot-mcp.

## Rules (verbatim)

- **Drive the game only with godot-mcp injected input** (mouse move/click/keys through the MCP). **Never OS-level / computer-use control of Nathan's screen.**
- **Fresh save.** Real player path only: **no `_dev_*`, no `preview_*` hooks, no Grant, no DevChrome hotkeys, no forced poses or forced milestones.**
- Captures at **1680×1040**.
- No visible "Tier" or "ATK".

## What to verify

- Verdant/biome splash prefers the real cue leaf (not the placeholder) when that splash appears.
- Spin settle shows a short gold land_burst on the landed seat (plus existing pointer land).
- Tutorial / Nib pointer uses glove bob + arrowhead sprites aimed at the target; clears on room change / door / Nib move like today.
- Longbow / Crossbow / Arrow Head fly an arrow; Shuriken spins; Chakram and Double Axe rotate while flying.
- Defeat signatures play for Tesla Coil, Napalm, Last Match, Catapult, Measuring Tape, Love Potion, Orb, Polymorph, Hex (ITEM_STRIKE pattern).
- Any heal path shows heal_sparkle on the hub hearts.
- Endless HUD shows blank plaque behind the floor number, skull coin beside best, and gold ring pulse on clear tally; all numbers/words stay live Labels.
- Net / Smoke Bomb / Bag of Holding / Flying Saucer play their utility moment at use.
- Cabin/hall fades keep the same timings with an optional iris ring overlay.
- Held map pool 2 stamp is Crystal Cavern (idle/hover/press).
- Tossed cards use tan-tinted defeat_poof (crumble frames stay on disk unused).
- Map hero hops on the existing 2 frames; route dots scale-pop when built.
- Trophy hall candles show candle_glint; subtle dust motes in the hall.
- Nib has cheer/shrug in SpriteFrames (play if a success/miss hook is reachable; otherwise note frames present).
- Title emblems exist under `assets/ui/title/emblem/` but the title screen is untouched.

## Screenshots required

| id | room | setup | expect | filename |
|---|---|---|---|---|
| 01 | fight | fresh save → fight → spin the wheel and let it land | land_burst at landed seat; pointer land still plays | 01-spin-land-burst.png |
| 02 | fight | heal after taking damage (potion / heal item) | heal_sparkle over hub hearts | 02-heal-sparkle.png |
| 03 | fight | use Longbow or Crossbow or Arrow Head on a legal target | arrow_flight from card toward target | 03-arrow-flight.png |
| 04 | fight | use Shuriken when available | shuriken_spin flight | 04-shuriken.png |
| 05 | fight | use a defeat signature item that comes up (Boot/Sledge still OK as stand-in if signature item not in hand — prefer Measuring Tape / Last Match / Orb when drafted) | strike/signature frames over the monster before resolve | 05-defeat-signature.png |
| 06 | fight | toss/spend an item so the card flies away | tan-tinted defeat_poof at the card | 06-card-toss-poof.png |
| 07 | fight | use Smoke Bomb or Net when available | utility puff/throw at card or target | 07-utility-moment.png |
| 08 | cabin | enter cabin from exterior (or room fade) | iris ring overlay on fade; timings unchanged | 08-iris-wipe.png |
| 09 | cabin map | open held map; look at pool 2 stamp | Crystal Cavern stamp idle; hero hop; route dots popped | 09-crystal-stamp-map.png |
| 10 | cabin hall | walk into trophy hall | candle_glint on candles; subtle dust motes | 10-hall-candle-dust.png |
| 11 | tutorial | start Brand New tutorial until a pointer appears | glove bob + arrowhead (not vector line) aimed at target | 11-tutorial-pointer.png |
| 12 | endless | if Endless reachable on Middle Progress path: clear a floor and watch HUD | plaque behind N; skull coin by best; gold ring on +1 tally | 12-endless-hud.png |

## Pass criteria

- Every `expect` is readable from the PNG at 1680×1040 (or row marked skip with why if that content cannot appear on a fresh natural path).
- No "Tier"/"ATK" text anywhere in the shots.
- No console errors from missing textures.
- Input was godot-mcp only on a fresh-save real player path.
- Title screen was not opened for emblem checks.

## Outbox path

`playtest/repot/outbox/REQ-20261118-pixellab-final-b/`
