# Cursor implement prompt: Trophy Hall (dumbwaiter) — DRAFT (Pixel, 2026-10-30)

> **Launcher note for Pixel (not part of the prompt):** CloudAgent default is model `grok-4.5`, effort `low`, fast `false`. This file is only a draft. Nobody has launched it.
>
> **Attach these with the prompt:**
> - `SCREEN-trophy-hall.md` and `ASSET-LIST.md` (from `/workspace/trophy-hall/`)
> - the PNGs from the PixelLab commission once they exist
>
> **If the art isn't ready, ship placeholders.** The spec's Godot-drawn fallbacks cover it.
>
> **Local alternative:** run in Cursor on Cherry in `C:\Users\Natha\Documents\boss-rush`. That working tree has about 127 uncommitted changes, so branch from `origin/playtest/latest` in a fresh worktree:
> `git -C "C:/Users/Natha/Documents/boss-rush" worktree add ../boss-rush-th origin/playtest/latest -b cursor/trophy-hall-dumbwaiter`

---

```
Repo Nathan-Elequin/swipe, branch playtest/latest (Godot 4.7, viewport 1680x1040, all art Nearest). Tip read for the spec: 3519eae2. Implement the TROPHY HALL per SCREEN-trophy-hall.md + ASSET-LIST.md (supplied with this prompt; commit both under design/trophy-hall/ first). The spec is the source of truth; where it says "Pixel's call", follow it.

Goal: the cabin Trophy Hall (scripts/cabin/room_hall.gd + home_cabin.gd case code + scripts/biome_cabinets.gd) shows five biome cases L->R Verdant Hollow, Crystal Cavern (white/glacial, replaces Sunken Mire), Ashen Crypt, Cinder Forge, Shadow Abyss. Each case has 4 states: Locked = dusty sheet with biome-colour hem + crest + padlock; In progress = glass shut, lamp dark, crest grey; Opened = any 5 unique claimed, glass open, lamp lit, crest in colour; Complete = all claimed, gilded. Each case shows a FIXED 2x5 peg face per page with unseen/seen/claimed peg states and placards, plus a brass depth plaque. NATHAN LOCK: pools are NEVER trimmed and the grid never grows (no 2x7). Any pool over 10 items gets more 2x5 pages, flipped with a diegetic brass PageBar on the case base (chevron studs + page ticks) and the mouse wheel. Complete = every live pool item claimed across ALL pages. A DUMBWAITER on the left wall gates pools: 5 stops with lamps (lit = pool available), a lever, and a car that parks at the chosen stop; clicking a lit stop lights that case and pulses its node on the held map. Click a case to zoom 2x with lore panels. Coming home with the 5th unique plays the unlock beat. THE STRATA SOIL COLUMN IS CUT: build nothing of it.

Investigate first (don't assume; file:line in spec §2 are from 3519eae2):
- home_cabin.gd _rebuild_shelves/_fill_biome_cases/_build_biome_case/_mount_slot/_on_case_hover/_play_bank_sequence/_bank_fx_arc_to_mount/_bank_mount_global_center/focus_biome_case/open_hall_after_push_block, _rooms_host panning; campaign_shell.gd pool_unlocked/cabinet_count; map_piece_beat.gd play(); held_map.gd present(opts); data/cabin-layout.json extra.anchors.hall + hall placements (Flame0); scripts/dev/biome_cabinets_selftest.gd.

Do, in order:
1. Data: data/campaign.json biomes[1].name -> "Crystal Cavern". BiomeCabinets.CASES[1] -> Crystal Cavern (CASE_GLASS[1]=[138,68,48,121]; frame window (6,44); spires sheet/gild origin (126,22)) (tint 2a4a60, accent b4d6ea, frame cabinets/case_crystal_cavern, trophy cabinets/trophy_crystal_cavern); STUB_NAMES Warren/Slime Pits -> Crystal Cavern. Keep the old sunken_mire PNGs on disk. CASES_BOUNDS + anchors.hall.hole/cases_bounds -> [0,0,420,260]; _hole.clip_contents=false in the hall. Remove the hall Flame0 placement and set anchors.hall.flame=[] (the dumbwaiter covers that sconce).
2. Assets: add the files in ASSET-LIST §1–2 (PixelLab output if attached, else Godot-drawn placeholders per §4 that never crash or show the olive case). Write + run design/trophy-hall/art-source/bake.py (PIL) for the bake rows (hem masks, grey crests, hatch, tab) per PIXELLAB-COMMISSION "Not PixelLab". Import Nearest, no mipmaps, lossless; commit .import files.
3. BiomeCabinets: add CaseState enum + case_state(), peg_state(), fixed_slots() (the SAME item set _group_cards_by_pool/_case_collected use, sorted tier asc/name/id, NO cap), page_count(), slot_page(), page_state(), crown_text(claimed,total over all pages), pips_lit(). Stop using order_mounts / peg_column_layout / trophy_local_rect in the hall (leave the functions if other callers exist).
4. New scripts/cabin/trophy_case.gd (TrophyCase Control) per SCREEN §5.4–5.6 and §8: Body (b2), Glass clip -> PageStrip -> Page_n (2x5) -> Peg_<id> (recess, item, hatch, ledge, 9-slice placard, fit label, twinkle; unused cells on the last page = empty recess), PageBar per SCREEN §5.3 (only if >1 page: brass chevron studs case_page_chevron(_hover) + Godot-drawn ticks; current amber, fully-claimed page gold; overview = left/right half-click + wheel flips, 0.2s debounce; zoom = chevrons/ticks clickable + left/right arrow keys; stepped 0.18s slide snapped to 4px; lazily build current +/-1 pages; _case_page session-only, defaults to the first page with an unclaimed item), Door AnimatedSprite2D, Gild, Crown (crest = existing trophy_<biome>.png drawn at 48px / _grey / _hover; name; 5 Godot-drawn pips; n/total over all pages), Lamp + lantern_glow, Sheet (clip, hem modulated by accent, crest, padlock), Plaque (NinePatch + depth bars + cabin.hall.plaque). home_cabin._fill_biome_cases builds these instead of the scroll column; delete the hall scroll/wheel code and _place_biome_trophy in the glass top. Case hover keeps the existing _on_case_hover keys (Locked -> cabin.hall.locked). Pegs only take hover/click in zoom.
5. New scripts/cabin/dumbwaiter.gd at native (45,38) 28x161 per SCREEN §3: lit[k] = CampaignShell.pool_unlocked(...,"b%d"%k); stop hit rects 112x100; hover/click/dark-stop shake; stepped car ride (tween_method snapping to 4px, ropes resized each step); lever f0-f2 + tour 1..deepest with 0.5s pauses, skippable; arrival -> case lamp flare + focus_biome_case + tray silhouette (first unclaimed in fixed order) + _map_focus_pool. Session-only state, no new save keys.
6. Held map: home_cabin passes opts {"focus_pool": _map_focus_pool} when opening the held map; held_map.gd pulses that stamp once (scale 1->1.12->1 x2, 0.18s halves) then the cabin clears it.
7. Zoom (SCREEN §6): tween RoomHall scale 2x + clamped position (no Camera2D: the cabin is all Controls), 0.35s in / 0.25s out; ZoomDim ColorRect #0B0706 a0.25 below the focused case; Esc / right-click / click outside zooms out; disable room nav + dumbwaiter while zoomed. Peg hover = amber StyleBox frame + screen-space LorePanel (parchment StyleBoxFlat, 4 brass corner TextureRects, Polygon2D tail, journal from lore.json items.<id>.journal, chip PlayerCopy.tier_name(tier).to_upper() on UxStyle.metal). Seen = no journal + cabin.tip.seen; unseen = cabin.tip.locked only. Peg click -> existing inspect_wanted.
8. Unlock beat (SCREEN §7): in _play_bank_sequence, after _bank_fx_loud_count and BEFORE cabinet_gate_crossed.emit/_map_piece_beat.play, await _case_opened_beat(pool) for each crossed pool: door f0-f3 at 100ms, lamp flicker on, crest grey 0.15s -> colour + glint, next case sheet slides down 0.35s + padlock drops, that dumbwaiter stop lamp lights. Before each arc, flip that case to the item's page so the arc lands on the visible fixed Peg_<id>. Same extract-only guard as today. After the map-piece beat, if the newly unlocked biome index is 2..4 emit new signal shortcut_scene_wanted(pool_id) (nothing connects yet).
9. Copy: add STUB keys cabin.hall.plaque ("Wares of the {ordinal} Depth and below"), cabin.hall.ordinal_1..5 (1st..5th), cabin.hall.lift_sign ("LIFT"), cabin.hall.lift_lever ("Pull"), cabin.hall.lore_claimed ("Claimed") to data/player-copy.additions.json (and wherever tip's copy pipeline needs them) with status STUB, note "Trophy Hall - Pixel owns for now". Do NOT edit any other player-facing copy (nib.homecoming, map-piece ceremony, extract.* are Spin's). Never show "Tier", "Swipe" or "boss rush". No text baked into PNGs.
10. Tests: extend scripts/dev/biome_cabinets_selftest.gd: case_state truth table (4 -> in progress, any 5 -> opened, all -> complete, locked when the previous case is under quota); fixed_slots stable under shuffled input/banked order and keeps every item (23 items -> page_count 3, slot 22 -> page 2 cell 2; page_count(10)=1, (11)=2); page_state FULL only when every id on that page is claimed; Complete needs every page; b2 name Crystal Cavern; pips_lit clamps. Keep all existing selftests green.
11. Build report: list item count + page count per pool (tip counts: b1 12 incl. 2 todo, b2 11, b3 13, b4 14, b5 10, so b1-b4 have 2 pages and b5 has 1) and any rect you nudged by eye.
12. Repot: write playtest/repot/inbox/REQ-20261030-trophy-hall-dumbwaiter.md (skeleton below) and capture the shots into playtest/repot/outbox/REQ-20261030-trophy-hall-dumbwaiter/shots/ (godot-mcp preferred, 1680x1040).
Open a PR into playtest/latest. Doop refs (canvas K5t2l_veMo): LQYDndcx0L overview (ignore the strata column), BFx-Nk9guT zoom, 8f1j8BSEe- right half = dumbwaiter, nAq0ZecRXO unlock beat, sSXqYUHvO2 = the unchanged plate. Magenta callouts are notes only; mock copy is STUB.
Do not: touch the frozen public itch page, regenerate the Doop plate, add new mechanics/save keys/sounds, build the strata column, or ask Nathan questions; ship the first cut.
```

---

## Repot REQ skeleton (`playtest/repot/inbox/REQ-20261030-trophy-hall-dumbwaiter.md`)

```markdown
---
id: REQ-20261030-trophy-hall-dumbwaiter
status: open
priority: high
pr: <PR#>
tip_sha: <branch HEAD at shoot time>
branch: cursor/trophy-hall-dumbwaiter-<suffix>
created: 2026-10-30T00:00:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → fresh save → cabin main → hall (right path); DEV fill_b1 / grant-all as listed
---

# Trophy Hall: cases, fixed pegs, dumbwaiter, zoom, unlock beat

Spec: design/trophy-hall/SCREEN-trophy-hall.md + ASSET-LIST.md. Strata column is cut and must not appear.

## Screenshots required
| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | hall | fresh save | Verdant in progress; b2–b5 sheeted (hem+crest+padlock, b2 spires bumps); dumbwaiter left wall, stop 1 lit, 2–5 dark+padlock, car at 1; plaques 1st..5th; no strata, no olive case | 01-hall-fresh.png |
| 02 | hall | DEV fill_b1 | Verdant opened (door open, lamp lit, colour crest, 5 gold pips, n/12, PageBar 2 ticks); Crystal Cavern glacial, in progress; stops 1–2 lit, car at 2 | 02-hall-b1-opened.png |
| 03 | hall | click stop 2 | stepped ride; Crystal Cavern lamp flare + pulse; tray silhouette | 03-stop-click.png |
| 04 | hall | click lever, mid-tour | lever pulled frame; car between stops; ropes correct | 04-lever-tour.png |
| 05 | hall→map | after 03 press Space | Crystal Cavern stamp pulses | 05-map-node-pulse.png |
| 06 | hall zoom | click Verdant, hover claimed peg | 2x zoom, dim ~25%, amber frame, lore panel (brass corners, tail, journal, chip, no "Tier") | 06-zoom-claimed.png |
| 07a | hall zoom | hover seen peg | grey hatch, dashed placard + name, no journal | 07a-zoom-seen.png |
| 07b | hall zoom | hover unseen peg | black silhouette, blank placard, locked tip only | 07b-zoom-unseen.png |
| 08 | hall | Esc | overview identical to 02 | 08-zoom-out.png |
| 09a | hall | real extract bringing 5th Crystal Cavern unique | item mid-arc to its fixed peg | 09a-unlock-arc.png |
| 09b | hall | same, ~0.3 s later | door mid-swing, lamp on, crest grey | 09b-unlock-glass.png |
| 09c | hall | same, ~0.8 s later | crest colour; Ashen sheet sliding, padlock dropping; stop 3 lamp lit | 09c-unlock-sheet.png |
| 10 | hall | DEV grant all Verdant items | Complete: gilded crown + trim, placards gold on both pages, both ticks gold, twinkle | 10-complete.png |
| 11a | hall | wheel over a 2-page case | page 2 slid in (stepped), tick 2 amber, empty recesses on the last page | 11a-page-wheel.png |
| 11b | hall zoom | zoom a 2-page case, click the right chevron | chevrons/ticks clickable at 2x; arrow keys flip | 11b-page-zoom.png |
| 12 | hall | real extract whose item is on page 2 | case flips to page 2 before the arc lands | 12-bank-flip.png |

## Pass criteria
- All PNGs under playtest/repot/outbox/REQ-20261030-trophy-hall-dumbwaiter/shots/ at 1680x1040.
- biome_cabinets_selftest green; no "Tier"/"Sunken Mire" on screen; pegs do not move between 01, 02 and 10.
- RESULT.md records tip SHA and the per-pool item/page counts from the build report.
- No pool is trimmed: every live item is reachable on some page.

## Outbox path
playtest/repot/outbox/REQ-20261030-trophy-hall-dumbwaiter/
```
