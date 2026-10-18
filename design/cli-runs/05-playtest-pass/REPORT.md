# 05-playtest-pass — Oct 17 10:07 PM

Status: **PASS**. Text audit `failures: []` (`updated` 2026-10-18T00:12:44).

Checkpoint: `main` @ `56134d7` (origin/main). No commit. No push.

Folder is `05-playtest-pass` because `03` and `04` already exist on main. `.cursor/rules/swipe-design-loop.mdc` was already on origin/main; not rewritten.

Gold boxes in `data/content-board.json` were empty. No card-behavior queue.

## What landed

Challenge Mode (`adventure` / Long Drop) clicks a live monster slice in `phase == ready` and spins that fight. No confirm click. The old Spin control is reminder text (`challenge.spin_confirm`: “Click a monster on the wheel.”). Undo before the first item click, take-the-hit, or spend un-spins; after that it is the normal fight Undo. Adventure Mode (Gatehouse) still uses a real Spin. Magnet High/Low ATK (`pending_choice`) still needs its extra click. Tutorial uses the same click-slice rule.

Paper Fight for that rule: `design/paper-fight/done/2026-10-17-challenge-click-to-spin.md`. `CURRENT.md` is still Hex (already filled); this pass did not overwrite it.

Named copy overrides (author_lock kept): `tutorial.beat.01.body`, `tutorial.nudge_item`, `challenge.click_target`, `challenge.spin_confirm`. Da Boot → The Boot in that tutorial body. Map Challenge / Adventure blurbs, `map.deepest` = `Deepest: Dungeon {n}`, rope “Dungeon {n} cleared!”, telescope “Dungeon {n}”.

## Shots

All under `design/cli-runs/05-playtest-pass/`.

| File | What to check |
|---|---|
| `13a_intro_panel1.png` `13b_intro_panel2.png` `13c_intro_panel3.png` | Intro 1–3 |
| `text_cabin_main.png` | Empty cabin, one Nib |
| `text_cabin_nib.png` | Nib in the frame, body fills the box, cream Try again / Not yet |
| `text_radio.png` | Nib behind the radio; station name readable |
| `text_pause.png` | Settings readable; Master on the cork; Peek gone |
| `text_map.png` | Challenge / Long Drop; Deepest: Dungeon 1; italic prefer note |
| `text_map_adventure.png` | Adventure / Gatehouse; shrinking wheel copy |
| `text_challenge_ready.png` | Slice ready; Spin is the reminder, not a button |
| `text_tutorial_nib.png` | Nib to the right of the wheel |
| `text_combat_tips.png` | Hover tips; keyword color; Always not pinned over the wheel |
| `text_item_hand.png` | Hand of four |
| `text_journal.png` | Call name + frame + italics lore; no Ability |
| `19_rope_exit_sack_peek.png` | Loot in the air, no Peek control (filename kept for the harness stem) |
| `21a_win_homecoming_dump.png` | Dump pose, items grown, hall glow |
| `21b_win_homecoming_fly.png` | Items in the air toward the hall glow |
| `40_itch_midfight.png` `41_itch_draft_gate.png` `42_itch_boss.png` | Unchanged itch set |

Harness: Godot 4.7.2 `--shots=` those stems `--shots-out=res://design/cli-runs/05-playtest-pass`. Exit 0.

## Text audit

Before this pass: no `05` folder.

After: `text_audit.json` `"failures": []`.

## Catalog counts (live)

Items T1=12 T2=18 T3=10 (40). Monsters T1=11 T2=14 T3=10 (35). This pass did not add cards. Opening Challenge can still offer a Breastplate when Healing Potion is already in hand.

## Files

- `scripts/main.gd` — click-to-spin, unspin Undo, Challenge reminder, rope loot rows, faster mill, skip-to-chair, plaque stays put while the attack plays
- `scripts/tutorial_guide.gd` — Nib right of the wheel, keyword paint, outlined arrows, per-step nudge
- `scripts/hover_panel.gd` — Always tip only on hover
- `scripts/home_cabin.gd` — hat unequip, telescope, cat stub, front door always map, locked-door Nib, fade hide hero, win dump/fly, hall glow
- `scripts/cabin/rope_exit.gd` — Peek not built; loot glint loops 4 times (Godot forbids unbounded `set_loops()`)
- `scripts/cabin/cabin_dialog.gd` — shorter box, cream choices
- `scripts/cabin/radio_overlay.gd` — Nib behind, SFX swallows UI clicks, hover tips
- `scripts/cabin/map_overlay.gd` — prefer note
- `scripts/cabin/journal_overlay.gd` — memories tab, scribble/cover/wells stubs, 6 items/page, no Ability
- `scripts/cabin/room_loft.gd` — optional cat rub when Pixel PNGs land
- `scripts/settings_menu.gd` — Peek hidden; Settings ink on cream
- `scripts/boss_wheel.gd` — corridor highlight follows the slice
- `scripts/shot_cli.gd` / `scripts/dev/shot_harness.gd` — 05 out dir; 21a/21b real; rope 19 is loot; cabin Nib + both map modes
- `data/player-copy.json` — named overrides + map/door/rope/journal/radio
- `data/author-locks.json` — flags kept
- `design/paper-fight/done/2026-10-17-challenge-click-to-spin.md`
- `design/visual/HANDOFF-2026-10-17-playtest.md` — Pixel packet
- `design/handoff/05-playtest-pass/TASK.md`
- `tools/_playtest_copy.py` — one-shot JSON patcher already run

## Insights (not shipped)

- **Draft glow vs tier.** A gold gleam on a tier-1 helmet still reads as rare. Match hotbar tier chrome; do not use a gold aura for T1. Cheap-ish; left for a follow-up so this pass did not restyle draft chrome.
- **First-dungeon starvation.** Live T1 pool is 12 items. More cards later; this pass did not invent extras.
- **Trunk of letters.** Loft hover only. Not a second journal.
- **Journal lore.** Encounter = visible. Swipe is not required. Unchanged.

## Leftover Pixel waits

Packet: `design/visual/HANDOFF-2026-10-17-playtest.md`

1. `assets/dungeon/home/props/cat_rub_f0.png` … `f3.png` (16×16)
2. `assets/dungeon/home/overlays/journal_cover.png` (380×240, words “Grandpa’s Journal” in the drawing)
3. `assets/dungeon/home/overlays/journal_scribble.png` (166×80, no words)
4. `assets/dungeon/home/overlays/journal_photo_tape_a.png` / `_b.png` (120×72)

Code already loads those paths when the files exist.

## Deviations

- Hex call sites had been added to `main.gd` without the functions, which broke parse. Poison-on-spin from origin/main is restored. Hex stays the open Paper Fight in `CURRENT.md`.
- Journal grandpa entries in `data/lore.json` still say “First Belly” and the like. UI level names use Dungeon. Lore is Jam’s file; not patched here.
- Shot stem `19_rope_exit_sack_peek` is still the name; the pixels are loot in the air with Peek gone.

## Questions

- [Jam] Replace “Nth Belly” in journal lore with “Nth Dungeon”, or keep Belly as flavor in Grandpa’s handwriting?
- [Pixel] Packet above. Cabin Nib box is still a wide banner; a shorter drawn frame would help “Sprout” fit if the next pass re-lays it.
- [Nathan] Map italic note is live: “Which mode did you like more, and why? (test note)”

## What to look at in F5

1. Fresh Save: intro, then cabin bed music.
2. Challenge: click a wheel slice, fight starts; Undo before an item/hit/spend goes back to the wheel.
3. Tutorial: Nib on the right; click the slice, not Spin.
4. Rope: loot hanging, Climb / Delve only.
5. Win walk: items dump, grow, fly toward the hall glow.
6. Hall door before a win: Nib + Try again.
