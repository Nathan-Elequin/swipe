---
id: REQ-20261114-flow-overhaul
status: open
priority: high
branch: cursor/flow-art-wire-de91
created: 2026-11-14T04:40:00Z
updated: 2026-11-14T05:20:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress / Continue → clear a dungeon to the between-dungeons rest stage; and separately a first-return homecoming after the first dungeon clear
---

# Flow overhaul — final art wire (lever, dead portal, satchel, strip)

Nathan-locked flow from #507, now with Pixel's approved final art. Cloud cannot F5 — local Godot MCP shots required. Headless composites landed under `design/audit-shots/cursor/flow-art/` for a first look.

## What to verify

- Between-dungeons rest: no "New unique" text, no wall grid of carried items. Floor satchel (`satchel_floor.png`, 256×192) by the portal with ≤3 real item icons composited into mouth rect (32,56)–(224,112); mouth-shadow covers painted placeholders when fewer than 3. Bottom strip uses `carried_strip_9.png` 9-slice (margins L24 T20 R24 B20) with every carried item; `unique_star.png` (40×40) on new uniques; hover shows item tip; no Tier/ATK.
- Dead portal (lever not pulled): `portal_dead.png` + 6-frame `portal_dead_mist` loop at 6–8 fps in GATE_APERTURE behind `rope_exit_gate_frame`. NO particle swirl. Click → `portal.fizzle` + 0.2s arch shake; no dialogue blocking Climb. Five `arch_light_off/on` along the lintel match placed uniques (0..5). After lever pulled: existing particle vortex + all five lit.
- Floor lever: brass floor prop 192×224 (48×56 native), pivot (15.5,49) native, glow 288×320 at lever origin − (32,56) shipped. Right of the board on the hall floor, bottom-aligned with Nib's feet, away from sconces. Faint glow after first light; bright pulse when READY. Pull anim f0..f4 @ 12 fps.
- First return / first light behaviour from #507 unchanged.
- Fog clear frames (`fog_clear_f0..f5`, 192×128) replace the silhouette-jump set.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | rope_exit | mid-run rest, portal shut, 2+ carried (1 new) | satchel_floor with real peeks + mouth shadow; strip 9-slice; unique_star on new; arch lights partially lit; dead portal + mist, no swirl | 01-dead-portal-haul.png |
| 02 | rope_exit | click dead portal | arch mid-shake or post-fizzle; Climb still available; no blocking Nib choice | 02-dead-portal-fizzle.png |
| 03 | rope_exit | after that biome's lever pulled, return to rest | particle vortex; all five arch lights lit; mist plate hidden | 03-alive-portal.png |
| 04 | exterior→hall | first dungeon clear return, after Nib relocate, before unpack | Nib in hall; no satchel yet (or just after first_look line) | 04-first-return-gate.png |
| 05 | hall | first return unpack, 0 banked | empty-handed Nib line; no satchel ceremony | 05-first-return-empty.png |
| 06 | hall | first return unpack mid-fly / first item landed | homecoming satchel_* (unchanged) + item | 06-first-return-unpack.png |
| 07 | hall | first-ever light just lit, unpack paused | Nib line; glowing ring/aura on **192×224** floor lever | 07-first-light-pause.png |
| 08 | hall | board with 1–4 lights after first light | floor lever right of board, faint glow, bottom-aligned with Nib feet; not on sconces | 08-floor-lever-faint.png |
| 09 | hall | lever READY (5 lights) | bright glow pulse; ready art; still floor-planted | 09-floor-lever-ready.png |

## Pass criteria

- All rows shot at 1680×1040 via Godot MCP (in-game, not editor FS).
- No player-facing "Tier" or "ATK".
- Lever art is 192×224; dead portal plate is 256×448; satchel is satchel_floor (not homecoming satchel_*).
- Reduce motion: no shake / pulse / ring orbit (static highlight instead) — optional extra shot if easy.

## Outbox path

`playtest/repot/outbox/REQ-20261114-flow-overhaul/`
