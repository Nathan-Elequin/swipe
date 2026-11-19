---
id: REQ-20261118-pixellab-final-a
status: done
priority: high
pr: 557
tip_sha: 3d0eb148
branch: art/pixellab-final-a
created: 2026-11-18T22:30:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: fresh save → Brand New / Middle Progress → real fight path (no Grant / DevChrome / preview hooks)
---

# PixelLab final-A combat FX wiring

Wire pass for hit/defeat/take overlays, brass wheel pointer + tick/land, seat slain/blocked/escaped marks, item strike swings, ice-blue block clang + shield crack, heart break/refill, plus drop-in slash/idle frames (imp, glass_asp, fungal_colony, shambling_mound, anvil/oligarch/fungal facing). Cloud agent cannot F5; Cherry fulfills with godot-mcp.

## Rules (verbatim)

- **Drive the game only with godot-mcp injected input** (mouse move/click/keys through the MCP). **Never OS-level / computer-use control of Nathan's screen.**
- **Fresh save.** Real player path only: **no `_dev_*`, no `preview_*` hooks, no Grant, no DevChrome hotkeys, no forced poses or forced milestones.**
- Captures at **1680×1040**.

## What to verify

- Monster hit uses pixel hit_light / hit_heavy / blood_splat (not Kenney star/spark or vector circles). Heavy on ≥3 damage or killing blow.
- Kill: defeat_poof then rising soul_wisp; body fades inside the smoke before vanish.
- Player Take that removes HP shows claw / bite / thud over the hub hero (variant by attacker).
- Wheel pointer is the brass texture (glow + bob kept); tick plays on segment_passed without restarting mid-play; land plays when spin settles.
- Seat marks use slain / blocked / escaped frame strips; escaped slides left ~20px and fades; SLAIN / BLOCKED / Escaped banner text unchanged.
- Sledgehammer swing plays over the monster; impact frame triggers heavy hit + short shake.
- Starter strikes play: Throwing Knife (arcs from hotbar), Knucklers, Spiked Flail, The Boot, Spinning Top.
- Block shows ice-blue clang; when Block is used up, hub/Take shield crack plays.
- Hearts play break on loss and refill on heal.
- Cut-ins: imp, glass_asp, fungal_colony slash plates; shambling_mound slash refresh; anvil/oligarch/fungal facing idle look correct.
- No visible "Tier" or "ATK".

## Screenshots required

| id | room | setup | expect | filename |
|---|---|---|---|---|
| 01 | fight | fresh save → fight → deal light damage to faced monster | pixel hit_light + blood_splat over combat portrait | 01-hit-light.png |
| 02 | fight | kill a monster (item or last hit) | defeat_poof + soul_wisp rising; body fading in smoke; SLAIN seat mark | 02-kill-poof.png |
| 03 | fight | Take a hit that removes HP | claw/bite/thud overlay on hub hero; heart break on lost pip | 03-take-overlay.png |
| 04 | fight | Take with Block that absorbs then hits 0 Block | ice-blue block clang + hub_shield_crack on the Block pip | 04-block-crack.png |
| 05 | fight | Resolve that Escapes (e.g. Harpy / blocked path that stamps Escaped) | seat_escaped frames + Escaped banner; mark slides left/fades | 05-escape.png |
| 06 | fight | Heal (potion / heal item) after damage | heart_refill frames on new heart slots | 06-heal-refill.png |
| 07 | fight | Spin the wheel and let it land | brass pointer; tick during spin; land burst at settle | 07-wheel-land.png |
| 08 | fight | Use Sledgehammer on a legal ≥6 ATK target | sledgehammer_swing over monster; heavy hit at impact | 08-sledgehammer.png |
| 09 | fight | Use Throwing Knife on a target | knife spin arcs from hotbar card to monster | 09-knife-strike.png |
| 10 | fight | Use Knucklers | knucklers_punch over monster before damage | 10-knucklers.png |
| 11 | fight | Use Spiked Flail | spiked_flail_swing over monster | 11-flail.png |
| 12 | fight | Use The Boot on a legal lower-HP target | da_boot_stomp over monster | 12-boot.png |
| 13 | fight | Use Spinning Top on matching HP | spinning_top_spin over monster | 13-top.png |
| 14 | fight | Face Imp and trigger ability cut-in | imp_slash plates in cut-in | 14-cutin-imp.png |
| 15 | fight | Face Glass Asp cut-in | glass_asp_slash plates | 15-cutin-glass-asp.png |
| 16 | fight | Face Fungal Colony cut-in | fungal_colony_slash plates | 16-cutin-fungal.png |

## Pass criteria

- Every `expect` is readable from the PNG at 1680×1040.
- No "Tier"/"ATK" text anywhere in the shots.
- No console errors from missing textures.
- Input was godot-mcp only on a fresh-save real player path.

## Outbox path

`playtest/repot/outbox/REQ-20261118-pixellab-final-a/`
