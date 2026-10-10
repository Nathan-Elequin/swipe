# Swipe — Creative UX Pack (Jam)

**Audience:** Cursor coding agent.  
**Owner:** Jam (creative UX + narrative). Nathan owns rules/numbers/ids.  
**Do not** invent new game modes, screens, or math. **Do** replace visuals/audio/motion/copy per this pack.  
**Live copy file:** `data/player-copy.json` (bump `id` + `updated` when Jam rewrites dialogue).  
**Bible:** `design/CREATIVE-BIBLE.md`

Fantasy lock: impish cute thief. Steal bait at the door → owner reveals → fight for the pile. Round nest / wheel. Combat stays combat.

---

## 0. Acceptance (how Nathan knows this landed)

1. Corner stamp still shows `copy: {id} · {updated}` from `player-copy.json`.
2. Title feels like temptation (glow bait), not a bland parchment lecture.
3. Door beat: silhouette bait → Take → slam + owner reveal + outraged taunt.
4. Combat: hit/block/slain readable in under one second (silhouette + flash + SFX).
5. Ten stand-in item icons from `dungeon_art.gd` comment are replaced with correct PNGs *or* listed as blocked with exact missing stem.
6. Music: title bed vs combat bed distinguishable (two loops minimum), or one bed with combat bus ducking + denser SFX if second loop blocked.
7. No mill/Pip language anywhere player-facing.

---

## 1. Player experience map (phases → creative beat)

| Phase (code) | Player feels | Visual | Audio | Motion |
|---|---|---|---|---|
| `title` | Temptation. Sticky fingers. | Dim nest behind parchment. Soft gold rim light on empty alcoves. Title **Swipe**. | Quiet dungeon bed (low). Soft UI hover. | Slow idle bob on empty wheel (subtle). |
| Tutorial (Nib) | A fence bossing you. | Existing talk box; portrait = impish thief (not armored dwarf long-term). Hole spotlight on focus tags. | Soft click on continue; no combat hits. | Existing vignette/hole. |
| `draft` starters | Nest already half-full. | Four starters pop N/E/S/W. | Soft *pop* / cloth per seat. | Sequential short pops (already). |
| Gate mystery | **Greed.** | Door silhouette. Bait card **glows** (gold pulse). Labels THE DOOR / THE BAIT / THE OWNER. | Low suspense loop; metal_latch hover. | 1.2s glow pulse on bait only. |
| Gate Take | **Gotcha.** | Slam open → owner sprite + speech balloon. | `door_slam` + short whoosh. | Hard open (existing); balloon pop. |
| Gate Pass | Relief / FOMO. | Bait fades; next pack. | Soft whoosh out. | — |
| `ready` | Tension before spin. | Full ring of owners. Cue: Spin. | Bed rises slightly. | Hub hearts visible. |
| `spinning` | Roulette dread. | Wheel turn; land at 6 o’clock. | Whoosh → land. | Existing ~1.2s cubic spin. |
| `fighting` | Spend loot or eat hit. | Portrait lunge; item cards; block gold hub. | Hit/block/draw SFX. | Existing combat_stage bursts. |
| BLOCKED | Pillow held. | Blue burst + **BLOCKED**. | `block` / `block_heavy`. | Existing. |
| SLAIN | Owner gone; loot kept. | Red X + **SLAIN**; neighbors close. | `chop` / `hit`. | Slice vanish. |
| `victory` | Smug. | **Ours** / pile stays. Nest empty behind. | Stinger or bed resolve (no fanfare orchestra). | Overlay fade. |
| `defeat` | Caught. | **Caught** / empty hands. Hearts dark. | Bed cuts or low fail tone. | Overlay fade. |

---

## 2. Art direction (one world)

### Locked look
- Pixel, nearest-neighbor, **16×16** creatures.
- Kenney RPG UI parchment (brown/beige/gold) — **keep**.
- Metal rims bronze / silver / gold = tiers — **keep**.
- Colorblind marks for Attack vs Block — **keep**.

### Palette mood
Warm torch browns, gold bait highlights, cool shadow in empty alcoves. Impish green accents on player/Nib only — not neon.

### Avoid
Photoreal, cyberpunk, Animal Crossing candy, Mega Man weapon-get flash, grim chapel oil-painting, mixing second tileset styles that clash with 0x72 proportions.

### Primary sources (CC0 first)
| Role | Pack | URL |
|---|---|---|
| Creatures / dungeon | 0x72 DungeonTileset II v1.7 | https://0x72.itch.io/dungeontileset-ii |
| Optional biome extend | 0x72 Sewers CC0 | https://0x72.itch.io/16x16-dungeontileset-ii-sewers |
| Extra items/tiles | Niji Dungeon Tileset II Extended CC0 | https://nijikokun.itch.io/dungeontileset-ii-extended |
| UI | Kenney RPG UI (already in) | kenney.nl |
| VFX | Kenney particle pack (already in) | kenney.nl |

---

## 3. Character & concept prescriptions

### Player fantasy (no separate player sprite required on wheel)
You are implied by **hearts + loot hotbar + greedy copy**. Do not add a hero avatar on the hub unless easy; if added: 16×16 cute imp/goblin thief with scarf, idle bob.

### Nib (tutorial portrait)
- **Now:** `dwarf_f` stand-in.
- **Target:** 16×16 impish fence — smug, scarf or eyepatch optional, warm browns/greens.
- Search: `16x16 pixel imp thief portrait`, or slice a 0x72 goblin/imp and recolor.
- Wire: `tutorial_guide.gd` frames source.

### Owners (monsters) — silhouette first
Prefer distinct silhouettes (Smol Dungeon readability principle). Current stem mismatches to fix when assets allow:

| id | Display | Prefer stem / art | Notes |
|---|---|---|---|
| wizard | Wizard | wizzard_m | OK |
| golem | Golem | big_zombie or stone-like | OK-ish |
| goblin | Goblin | goblin | OK — fellow thief energy |
| skeleton | Skeleton | skelet | OK |
| hornet_swarm | Hornet Swarm | **not imp** — insect/swarm slice or pack | High priority mismatch |
| lich | Lich | necromancer | OK |
| ogre | Ogre | ogre | OK |
| berserker | Berserker | orc_warrior | OK |
| dire_wolf | Dire Wolf | **not chort** — wolf-like | High priority |
| bandit | Bandit | masked_orc | OK |
| leech_league | Leech League | **not doc** | High priority |
| wraith | Wraith | **not angel** — ghost/wraith | High priority |
| mimic | Mimic | chest_mimic | OK |
| two_headed_serpent | Two-Headed Serpent | slug only if dual-head readable; else custom | Medium |
| slime_boss | Slime Boss | swampy | OK |
| spider_queen | Spider Queen | extra/spider.png — add crown/mark if possible | Medium |
| commander | Commander | orc_shaman | OK |
| dragon | Dragon | big_demon | OK-ish as “big threat” |

### Items — replace stand-ins (from code comment)
Must look like the **named object**, same 16×16 / nearest-neighbor, metal-rim friendly.

| id | Must look like | Priority |
|---|---|---|
| helmet | iron helmet (NOT flask) | P0 — already has items/helmet.png; verify wiring |
| sai | dual sai / prongs | P0 |
| smoke_bomb | pouch/bomb with smoke | P0 |
| fangs | fang tooth icon | P0 |
| poison_flask | green poison vial | P0 |
| healing_potion | red heal vial | P0 |
| crossbow | crossbow (not bow-only if avoidable) | P1 |
| knucklers | brass knuckles | P1 |
| throwing_knife | knife | P1 |
| spiked_flail | spiked flail/mace | P1 |
| sledgehammer | big hammer | P1 |

Already have good `ITEM_PNG`: shield, helmet, breastplate, medallion, boot, gauntlets, bracers, grimoire, watch — **audit these still match names**.

### Lucide SVG badges
Stop using abstract Lucide SVGs as the *primary* item/monster picture where a pixel icon exists. SVGs OK as tiny type marks (ATK/BLK) only.

---

## 4. Environment / background

**Target read:** top-down-ish circular nest — eight alcoves, warm hub, cold empty seats.

| Element | Prescription |
|---|---|
| Floor | Keep 0x72 floor tiles; slight vignette toward edges. |
| Alcoves | Empty = darker; occupied = lit rim matching tier metal. |
| Door (gate) | Silhouette arch until Take; bait card is the brightest object on screen. |
| Unused sheets | `atlas_floor.png` / `atlas_walls.png` — either wire into `dungeon_bg.gd` for richer nest OR leave unused; do not mix a second art style. |

---

## 5. UI / UX polish (no new screens)

| Surface | Prescription |
|---|---|
| Title | Subtitle already temptation-led; keep buttons 1–3 words. Optional: faint bait sparkle behind parchment. |
| Gate | Glow on THE BAIT card; THE OWNER stays dark until reveal. |
| Inspect | Short; Shift math scannable. Idle line = owners/loot. |
| Cue line | One sentence; situational from player-copy. |
| Hotbar | Job colors stay (atk red / block blue / defeat purple); metal rim = tier. |
| Hearts | Keep; pulse on damage (hub_hp_flash exists — ensure readable). |
| Trophy plaque | Number only — no English. |
| Copy stamp | Keep corner `copy: id · updated`. |
| Win/Lose | Same parchment language; win smug not epic; lose quiet. |

**Readability rule:** player should know in &lt;1s: whose turn (spin land), whether pillow covers (Safe vs Take N), which card is usable.

---

## 6. Audio direction

### Current
- Bed: `assets/audio/music.ogg` — yd Dungeon Ambience (CC0).
- SFX: Kenney Interface + RPG Audio (CC0) — keep bindings.

### Target bed map
| State | Music |
|---|---|
| Title / tutorial | Soft dungeon bed (current or quieter bus) |
| Gate | Same bed + slight filter or volume up on latch SFX |
| Combat / spin | **Second loop** preferred — denser pulse |

**CC0 candidates to download into `assets/audio/`:**
- Ironchest Dungeon Loops (CC0): https://ironchestgames.itch.io/ironchests-dungeon-music-loops — pick one “tension” loop as `music_combat.ogg`
- Keep yd ambience as `music.ogg` title/draft

If second file blocked: duck Music bus 2–3 dB on spin/fight and lean on hit/block SFX density — document in CREDITS.

### SFX cue map (bind existing ids; add only if missing)
| Beat | Prefer id |
|---|---|
| UI hover/click | hover, click |
| Take bait | confirm / metal_latch |
| Door slam | door_slam |
| Seat monster | drop / cloth |
| Spin | whoosh → land |
| Hit | hit / chop |
| Block | block / block_heavy |
| Win | confirm_big |
| Lose | error_big |

---

## 7. Motion / VFX storyboard (existing systems only)

| Beat | Use |
|---|---|
| Bait glow | Tween modulate on gate relic card (gold) |
| Door slam | Existing + screen flash gold short |
| Spin | Existing wheel tween |
| Hit | combat_stage star/spark |
| Block | twirl/magic + blue flash |
| BLOCKED / SLAIN | Existing labels — do not rename |
| Win | Soft gold flash once |
| Lose | Soft red flash once |

Unused VFX on disk (`magic_01`, `smoke_06`, `star_01`, `star_02`, `trace_01`): optional bind for bait glow / smoke bomb only — do not spam.

---

## 8. Implementation order for Cursor (strict)

1. **Audit** `dungeon_art.gd` ITEM_PNG vs display names; fix any wired wrong.
2. **Replace P0 item stand-ins** (sai, smoke_bomb, fangs, poison_flask, healing_potion, and verify helmet). Source from 0x72 / Niji extended / existing `assets/dungeon/items/`. Add PNGs under `assets/dungeon/items/`, register in `ITEM_PNG`.
3. **Monster stem fixes** for worst mismatches (hornet, wolf, wraith, leech) if a CC0 slice exists; else leave TODO list in `design/ART-TODO.md`.
4. **Gate bait glow** + ensure slam SFX on Take.
5. **Music:** add `music_combat.ogg` OR document ducking fallback.
6. **Nib portrait** path or TODO.
7. **Strip Lucide** as primary card art where pixel icon exists.
8. **Do not** touch rules, ids, wait/focus, or rewrite Jam copy.

After each visual milestone: leave `player-copy.json` `id`/`updated` untouched unless Jam says otherwise.

---

## 9. Files Cursor may create/edit

| Path | Action |
|---|---|
| `assets/dungeon/items/*.png` | Add corrected icons |
| `scripts/dungeon_art.gd` | ITEM_PNG / MONSTER_STEM / MONSTER_PNG |
| `scripts/draft_gate.gd` | Bait glow modulate |
| `scripts/audio_fx.gd` | Optional second music bed |
| `assets/audio/music_combat.ogg` | Optional |
| `assets/audio/CREDITS.txt` | Append new CC0 sources |
| `design/ART-TODO.md` | List anything blocked |
| `data/player-copy.json` | **Jam only** unless syncing card text from board after art-only pass |

---

## 10. Out of scope

New menus, new tutorial steps, renaming frozen ids, changing HP/ATK math, right-click editor chrome, replacing Kenney parchment with a different UI kit, generative AI art packs.

---

*End pack. Jam owns creative intent; Cursor executes this checklist.*
