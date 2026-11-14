---
id: REQ-20261114-flow-overhaul
status: open
priority: high
branch: cursor/flow-overhaul-e2f8
created: 2026-11-14T04:40:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress / Continue → clear a dungeon to the between-dungeons rest stage; and separately a first-return homecoming after the first dungeon clear
---

# Flow overhaul — transition stage, first return, first light, floor lever

Nathan-locked flow: dead portal + satchel/strip haul, first-return homecoming gating, first-light pause, floor lever. Cloud cannot F5 — local Godot MCP shots required.

## What to verify

- Between-dungeons rest: no "New unique" text, no wall grid of carried items. Floor satchel by the portal (≤3 peeks) + bottom strip of every carried item at native size with even spacing; gold star on new uniques; hover shows item tip; no Tier/ATK.
- Dead portal (lever not pulled): dark stone arch, cold mist, NO swirl. Click → `portal.fizzle` + 0.2s arch shake; no dialogue blocking Climb. Five arch lights match placed uniques (0..5). After lever pulled: swirl + all five lit.
- First return only: exterior → door → key tour → Nib relocates → then "Okay, let's see…" → empty or unpack branch. Unpack ~1.2s/item; first item comment; hover-hint; first placed item pulses until hovered.
- First-ever light: unpack pauses; Nib lines + lever aura; faint lever glow until 5. After pull, portal splash starts with "So THAT's what it does!"
- Floor lever: big brass floor prop on the right of the board (not on the light strip).

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | rope_exit | mid-run rest, portal shut, 2+ carried (1 new) | satchel by arch with peeks; bottom strip; gold star on new; no wall grid / no "New unique" text; arch lights partially lit; no swirl | 01-dead-portal-haul.png |
| 02 | rope_exit | click dead portal | arch mid-shake or post-fizzle; Climb still available; no blocking Nib choice | 02-dead-portal-fizzle.png |
| 03 | rope_exit | after that biome's lever pulled, return to rest | swirling vortex; all five arch lights lit | 03-alive-portal.png |
| 04 | exterior→hall | first dungeon clear return, after Nib relocate, before unpack | Nib in hall; no satchel yet (or just after first_look line) | 04-first-return-gate.png |
| 05 | hall | first return unpack, 0 banked | empty-handed Nib line; no satchel ceremony | 05-first-return-empty.png |
| 06 | hall | first return unpack mid-fly / first item landed | satchel + item; optional "Right where it belongs" | 06-first-return-unpack.png |
| 07 | hall | first-ever light just lit, unpack paused | Nib line; glowing ring/aura on floor lever | 07-first-light-pause.png |
| 08 | hall | board with 1–4 lights after first light | floor lever on right with faint glow; lights on face; lever not on wall sconces | 08-floor-lever-faint.png |

## Pass criteria

- All rows shot at 1680×1040 via Godot MCP (in-game, not editor FS).
- No player-facing "Tier" or "ATK".
- Reduce motion: no shake / pulse / ring orbit (static highlight instead) — optional extra shot if easy.

## Outbox path

`playtest/repot/outbox/REQ-20261114-flow-overhaul/`
