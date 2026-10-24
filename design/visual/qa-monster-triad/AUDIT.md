# Monster art triad

Branch: `playtest/weekend-demo`. Read-only. No art or code was changed.

Live monsters: 55 (`data/catalog.json` status `live`). Todo and retired are omitted.

Same silhouette means the wheel-seat crop and the fight-callout crop. Both are frame 0 of `monster_portrait_frames`, so they match for every live id (alpha overlap 1.0 after the shared crop). Slash is a separate file and is not part of that yes/no.

## How each slot loads

### 1. Wheel seat

Caller: `scripts/main.gd` `wheel_view.set_wheel_frames(art.wheel_frames_all())` (around line 1055).

Draw: `scripts/boss_wheel.gd` `_wheel_tex` (around line 1521) uses `tex_wheel_frames[id][0]`. If that array is empty it uses `tex_portraits`, which `art.portraits()` fills with `monster_still`.

Loader: `scripts/dungeon_art.gd` `wheel_frames_all` (lines 387-395).

1. `monster_portrait_frames(id)`.
2. If that array is empty, `monster_wheel_frames(id)`.
3. Store only frame 0. The seat does not play the breathe loop. `_breathe_bob` returns false.

`monster_portrait_frames` (lines 403-443):

1. `monster_facing_idle(id)`.
2. If that is empty, `monster_wheel_frames(id)`.
3. Knock out a flat corner backdrop (`_knock_backdrop`, lines 446-479), then crop every frame to the union of opaque pixels.

`monster_facing_idle` (lines 372-384) reads `res://assets/dungeon/anim/facing/{id}_facing_idle_f{n}.png` for n = 0..5 and stops at the first missing file. If none exist, it returns `monster_idle(id)`.

`monster_wheel_frames` (lines 354-369) reads `res://assets/dungeon/anim/wheel/{id}_wheel_breathe_f0.png` and `f1`. If both are missing, `res://assets/dungeon/anim/wheel/{id}_wheel_base.png`. If that is missing, the array is empty.

`monster_idle` / `monster_still` (lines 335-351): if `MONSTER_PNG[id]` loaded, that one texture. Otherwise atlas frames for `MONSTER_STEM[id]` (`frames`, lines 292-301). `monster_still` is frame 0 of that.

What actually wins for all 55 live ids: facing idle exists (4 frames each), so the seat is the cropped facing frame 0. The wheel breathe files are on disk for every live id and are not selected. The still PNG is not selected for the seat.

### 2. Hover / facing callout

These are two different pictures.

**Fighting portrait (the big monster beside the HP / Attack / Weak-Tough-Deadly plate).** `scripts/main.gd` `_refresh_face` (around line 16687) fills `face_box` with `show_rule(..., portrait=null)`. The plate has no sprite. `scripts/combat_stage.gd` `show_monster` (lines 75-85) loads the big monster:

1. `monster_portrait_frames(id)` — same function as the wheel seat.
2. If empty, `monster_facing_idle(id)`.
3. If empty, `monster_idle(id)` (still PNG, else atlas stem).

The stage then crops again to the opaque box and animates every frame when there are 4 or more (`_place_sprite`, around line 330). The wheel keeps only frame 0 of that same crop. Source files match. Frame 0 matches.

**Mill hover plate (small portrait inside the fly tip).** `scripts/main.gd` `_fill_inspect_from_slice` (around line 15992) sets the portrait with `art.monster_still(id)`. During `fighting` and `slaying` that hover plate is hidden (line 15972), so you see the big portrait instead.

`monster_still` path: `res://assets/dungeon/extra/...` from `MONSTER_PNG`, else the atlas stem in `MONSTER_STEM`. Every live id has a still PNG. Two ids do not use a same-name file: `two_headed_serpent` → `assets/dungeon/extra/damsel.png`, `triclops` → `assets/dungeon/extra/triclops_v2.png`.

The callout column below is the fighting portrait (facing frame 0), not the hover still.

### 3. Ability slash / cut-in

Caller: `scripts/main.gd` `_announce_slice` (around line 9922) and `_challenge_refill_or_collapse` (around line 4051) pass `tex = art.monster_still(id)` into `ability_slash.play`.

Loader: `scripts/ability_slash.gd` `_prepare_portrait` (lines 532-546) calls `monster_slash_frames(card_id)` first. If that array is not empty, the cut-in plays those frames. If it is empty, the portrait is the `tex` that was passed in (`monster_still`).

`monster_slash_frames` (lines 482-496) reads `res://assets/dungeon/anim/slash/{id}_slash_f{n}.png` for n = 0..11 and stops at the first missing file. It also loads `{id}_slash_base.png` into a local that is never appended. A base file with no `_slash_f0.png` does not show.

53 live ids have a slash sequence. Wizard and Golem do not, so their cut-in is `assets/dungeon/extra/wizard.png` and `assets/dungeon/extra/golem.png`. 53 ids also have a `_slash_base.png` on disk that this function does not display.

## Focus table

| id | wheel path used | callout path used | slash path used | same silhouette? |
| --- | --- | --- | --- | --- |
| wizard | assets/dungeon/anim/facing/wizard_facing_idle_f0.png | assets/dungeon/anim/facing/wizard_facing_idle_f0.png | assets/dungeon/extra/wizard.png (no slash frames; monster_still) | yes |
| golem | assets/dungeon/anim/facing/golem_facing_idle_f0.png | assets/dungeon/anim/facing/golem_facing_idle_f0.png | assets/dungeon/extra/golem.png (no slash frames; monster_still) | yes |
| wick | assets/dungeon/anim/facing/wick_facing_idle_f0.png | assets/dungeon/anim/facing/wick_facing_idle_f0.png | assets/dungeon/anim/slash/wick_slash_f0.png (f0-f3) | yes |
| death_bell | assets/dungeon/anim/facing/death_bell_facing_idle_f0.png | assets/dungeon/anim/facing/death_bell_facing_idle_f0.png | assets/dungeon/anim/slash/death_bell_slash_f0.png (f0-f5) | yes |
| prism | assets/dungeon/anim/facing/prism_facing_idle_f0.png | assets/dungeon/anim/facing/prism_facing_idle_f0.png | assets/dungeon/anim/slash/prism_slash_f0.png (f0-f3) | yes |
| rust_bucket | assets/dungeon/anim/facing/rust_bucket_facing_idle_f0.png | assets/dungeon/anim/facing/rust_bucket_facing_idle_f0.png | assets/dungeon/anim/slash/rust_bucket_slash_f0.png (f0-f3) | yes |

Hover plate for those six (not the callout column): `monster_still` → `assets/dungeon/extra/{id}.png`.

Wheel breathe files exist for all six (`assets/dungeon/anim/wheel/{id}_wheel_breathe_f0.png` and `f1`) and are not what the seat shows.

Wizard side-by-side of the two crops the loaders actually display: `design/visual/qa-monster-triad/wizard-mismatch.png`. They are the same facing frame 0. The still at `assets/dungeon/extra/wizard.png` is a different file. Hover and the Wizard slash cut-in use that still. The wheel breathe PNG is a third file and is unused.

## Every live id

| id | wheel path used | callout path used | slash path used | same silhouette? |
| --- | --- | --- | --- | --- |
| wizard | assets/dungeon/anim/facing/wizard_facing_idle_f0.png | assets/dungeon/anim/facing/wizard_facing_idle_f0.png | assets/dungeon/extra/wizard.png (no slash frames; monster_still) | yes |
| golem | assets/dungeon/anim/facing/golem_facing_idle_f0.png | assets/dungeon/anim/facing/golem_facing_idle_f0.png | assets/dungeon/extra/golem.png (no slash frames; monster_still) | yes |
| goblin | assets/dungeon/anim/facing/goblin_facing_idle_f0.png | assets/dungeon/anim/facing/goblin_facing_idle_f0.png | assets/dungeon/anim/slash/goblin_slash_f0.png (f0-f3) | yes |
| skeleton | assets/dungeon/anim/facing/skeleton_facing_idle_f0.png | assets/dungeon/anim/facing/skeleton_facing_idle_f0.png | assets/dungeon/anim/slash/skeleton_slash_f0.png (f0-f4) | yes |
| lich | assets/dungeon/anim/facing/lich_facing_idle_f0.png | assets/dungeon/anim/facing/lich_facing_idle_f0.png | assets/dungeon/anim/slash/lich_slash_f0.png (f0-f3) | yes |
| ogre | assets/dungeon/anim/facing/ogre_facing_idle_f0.png | assets/dungeon/anim/facing/ogre_facing_idle_f0.png | assets/dungeon/anim/slash/ogre_slash_f0.png (f0-f4) | yes |
| vampire | assets/dungeon/anim/facing/vampire_facing_idle_f0.png | assets/dungeon/anim/facing/vampire_facing_idle_f0.png | assets/dungeon/anim/slash/vampire_slash_f0.png (f0-f4) | yes |
| berserker | assets/dungeon/anim/facing/berserker_facing_idle_f0.png | assets/dungeon/anim/facing/berserker_facing_idle_f0.png | assets/dungeon/anim/slash/berserker_slash_f0.png (f0-f4) | yes |
| dire_wolf | assets/dungeon/anim/facing/dire_wolf_facing_idle_f0.png | assets/dungeon/anim/facing/dire_wolf_facing_idle_f0.png | assets/dungeon/anim/slash/dire_wolf_slash_f0.png (f0-f3) | yes |
| bandit | assets/dungeon/anim/facing/bandit_facing_idle_f0.png | assets/dungeon/anim/facing/bandit_facing_idle_f0.png | assets/dungeon/anim/slash/bandit_slash_f0.png (f0-f3) | yes |
| leech_league | assets/dungeon/anim/facing/leech_league_facing_idle_f0.png | assets/dungeon/anim/facing/leech_league_facing_idle_f0.png | assets/dungeon/anim/slash/leech_league_slash_f0.png (f0-f4) | yes |
| two_headed_serpent | assets/dungeon/anim/facing/two_headed_serpent_facing_idle_f0.png | assets/dungeon/anim/facing/two_headed_serpent_facing_idle_f0.png | assets/dungeon/anim/slash/two_headed_serpent_slash_f0.png (f0-f4) | yes |
| slime_boss | assets/dungeon/anim/facing/slime_boss_facing_idle_f0.png | assets/dungeon/anim/facing/slime_boss_facing_idle_f0.png | assets/dungeon/anim/slash/slime_boss_slash_f0.png (f0-f3) | yes |
| spider_queen | assets/dungeon/anim/facing/spider_queen_facing_idle_f0.png | assets/dungeon/anim/facing/spider_queen_facing_idle_f0.png | assets/dungeon/anim/slash/spider_queen_slash_f0.png (f0-f4) | yes |
| commander | assets/dungeon/anim/facing/commander_facing_idle_f0.png | assets/dungeon/anim/facing/commander_facing_idle_f0.png | assets/dungeon/anim/slash/commander_slash_f0.png (f0-f4) | yes |
| dragon | assets/dungeon/anim/facing/dragon_facing_idle_f0.png | assets/dungeon/anim/facing/dragon_facing_idle_f0.png | assets/dungeon/anim/slash/dragon_slash_f0.png (f0-f5) | yes |
| needleback | assets/dungeon/anim/facing/needleback_facing_idle_f0.png | assets/dungeon/anim/facing/needleback_facing_idle_f0.png | assets/dungeon/anim/slash/needleback_slash_f0.png (f0-f3) | yes |
| gelatinous_cube | assets/dungeon/anim/facing/gelatinous_cube_facing_idle_f0.png | assets/dungeon/anim/facing/gelatinous_cube_facing_idle_f0.png | assets/dungeon/anim/slash/gelatinous_cube_slash_f0.png (f0-f4) | yes |
| gargoyle | assets/dungeon/anim/facing/gargoyle_facing_idle_f0.png | assets/dungeon/anim/facing/gargoyle_facing_idle_f0.png | assets/dungeon/anim/slash/gargoyle_slash_f0.png (f0-f3) | yes |
| harpy | assets/dungeon/anim/facing/harpy_facing_idle_f0.png | assets/dungeon/anim/facing/harpy_facing_idle_f0.png | assets/dungeon/anim/slash/harpy_slash_f0.png (f0-f4) | yes |
| kobold_trapper | assets/dungeon/anim/facing/kobold_trapper_facing_idle_f0.png | assets/dungeon/anim/facing/kobold_trapper_facing_idle_f0.png | assets/dungeon/anim/slash/kobold_trapper_slash_f0.png (f0-f3) | yes |
| clockwork_knight | assets/dungeon/anim/facing/clockwork_knight_facing_idle_f0.png | assets/dungeon/anim/facing/clockwork_knight_facing_idle_f0.png | assets/dungeon/anim/slash/clockwork_knight_slash_f0.png (f0-f5) | yes |
| basilisk | assets/dungeon/anim/facing/basilisk_facing_idle_f0.png | assets/dungeon/anim/facing/basilisk_facing_idle_f0.png | assets/dungeon/anim/slash/basilisk_slash_f0.png (f0-f4) | yes |
| hollow | assets/dungeon/anim/facing/hollow_facing_idle_f0.png | assets/dungeon/anim/facing/hollow_facing_idle_f0.png | assets/dungeon/anim/slash/hollow_slash_f0.png (f0-f3) | yes |
| beggar | assets/dungeon/anim/facing/beggar_facing_idle_f0.png | assets/dungeon/anim/facing/beggar_facing_idle_f0.png | assets/dungeon/anim/slash/beggar_slash_f0.png (f0-f3) | yes |
| wick | assets/dungeon/anim/facing/wick_facing_idle_f0.png | assets/dungeon/anim/facing/wick_facing_idle_f0.png | assets/dungeon/anim/slash/wick_slash_f0.png (f0-f3) | yes |
| anvil | assets/dungeon/anim/facing/anvil_facing_idle_f0.png | assets/dungeon/anim/facing/anvil_facing_idle_f0.png | assets/dungeon/anim/slash/anvil_slash_f0.png (f0-f3) | yes |
| bodyguard | assets/dungeon/anim/facing/bodyguard_facing_idle_f0.png | assets/dungeon/anim/facing/bodyguard_facing_idle_f0.png | assets/dungeon/anim/slash/bodyguard_slash_f0.png (f0-f3) | yes |
| cowardly_king | assets/dungeon/anim/facing/cowardly_king_facing_idle_f0.png | assets/dungeon/anim/facing/cowardly_king_facing_idle_f0.png | assets/dungeon/anim/slash/cowardly_king_slash_f0.png (f0-f4) | yes |
| merchant | assets/dungeon/anim/facing/merchant_facing_idle_f0.png | assets/dungeon/anim/facing/merchant_facing_idle_f0.png | assets/dungeon/anim/slash/merchant_slash_f0.png (f0-f3) | yes |
| juggernaut | assets/dungeon/anim/facing/juggernaut_facing_idle_f0.png | assets/dungeon/anim/facing/juggernaut_facing_idle_f0.png | assets/dungeon/anim/slash/juggernaut_slash_f0.png (f0-f3) | yes |
| cleric | assets/dungeon/anim/facing/cleric_facing_idle_f0.png | assets/dungeon/anim/facing/cleric_facing_idle_f0.png | assets/dungeon/anim/slash/cleric_slash_f0.png (f0-f4) | yes |
| martyr | assets/dungeon/anim/facing/martyr_facing_idle_f0.png | assets/dungeon/anim/facing/martyr_facing_idle_f0.png | assets/dungeon/anim/slash/martyr_slash_f0.png (f0-f4) | yes |
| prism | assets/dungeon/anim/facing/prism_facing_idle_f0.png | assets/dungeon/anim/facing/prism_facing_idle_f0.png | assets/dungeon/anim/slash/prism_slash_f0.png (f0-f3) | yes |
| plague_doctor | assets/dungeon/anim/facing/plague_doctor_facing_idle_f0.png | assets/dungeon/anim/facing/plague_doctor_facing_idle_f0.png | assets/dungeon/anim/slash/plague_doctor_slash_f0.png (f0-f4) | yes |
| hired_hand | assets/dungeon/anim/facing/hired_hand_facing_idle_f0.png | assets/dungeon/anim/facing/hired_hand_facing_idle_f0.png | assets/dungeon/anim/slash/hired_hand_slash_f0.png (f0-f3) | yes |
| hydra | assets/dungeon/anim/facing/hydra_facing_idle_f0.png | assets/dungeon/anim/facing/hydra_facing_idle_f0.png | assets/dungeon/anim/slash/hydra_slash_f0.png (f0-f5) | yes |
| zombie | assets/dungeon/anim/facing/zombie_facing_idle_f0.png | assets/dungeon/anim/facing/zombie_facing_idle_f0.png | assets/dungeon/anim/slash/zombie_slash_f0.png (f0-f3) | yes |
| triclops | assets/dungeon/anim/facing/triclops_facing_idle_f0.png | assets/dungeon/anim/facing/triclops_facing_idle_f0.png | assets/dungeon/anim/slash/triclops_slash_f0.png (f0-f4) | yes |
| shambling_mound | assets/dungeon/anim/facing/shambling_mound_facing_idle_f0.png | assets/dungeon/anim/facing/shambling_mound_facing_idle_f0.png | assets/dungeon/anim/slash/shambling_mound_slash_f0.png (f0-f4) | yes |
| almighty_worm | assets/dungeon/anim/facing/almighty_worm_facing_idle_f0.png | assets/dungeon/anim/facing/almighty_worm_facing_idle_f0.png | assets/dungeon/anim/slash/almighty_worm_slash_f0.png (f0-f5) | yes |
| cultist | assets/dungeon/anim/facing/cultist_facing_idle_f0.png | assets/dungeon/anim/facing/cultist_facing_idle_f0.png | assets/dungeon/anim/slash/cultist_slash_f0.png (f0-f3) | yes |
| bushido | assets/dungeon/anim/facing/bushido_facing_idle_f0.png | assets/dungeon/anim/facing/bushido_facing_idle_f0.png | assets/dungeon/anim/slash/bushido_slash_f0.png (f0-f4) | yes |
| shark | assets/dungeon/anim/facing/shark_facing_idle_f0.png | assets/dungeon/anim/facing/shark_facing_idle_f0.png | assets/dungeon/anim/slash/shark_slash_f0.png (f0-f4) | yes |
| death_bell | assets/dungeon/anim/facing/death_bell_facing_idle_f0.png | assets/dungeon/anim/facing/death_bell_facing_idle_f0.png | assets/dungeon/anim/slash/death_bell_slash_f0.png (f0-f5) | yes |
| phoenix_egg | assets/dungeon/anim/facing/phoenix_egg_facing_idle_f0.png | assets/dungeon/anim/facing/phoenix_egg_facing_idle_f0.png | assets/dungeon/anim/slash/phoenix_egg_slash_f0.png (f0-f4) | yes |
| phoenix | assets/dungeon/anim/facing/phoenix_facing_idle_f0.png | assets/dungeon/anim/facing/phoenix_facing_idle_f0.png | assets/dungeon/anim/slash/phoenix_slash_f0.png (f0-f4) | yes |
| amalgam | assets/dungeon/anim/facing/amalgam_facing_idle_f0.png | assets/dungeon/anim/facing/amalgam_facing_idle_f0.png | assets/dungeon/anim/slash/amalgam_slash_f0.png (f0-f4) | yes |
| fairy | assets/dungeon/anim/facing/fairy_facing_idle_f0.png | assets/dungeon/anim/facing/fairy_facing_idle_f0.png | assets/dungeon/anim/slash/fairy_slash_f0.png (f0-f3) | yes |
| eel | assets/dungeon/anim/facing/eel_facing_idle_f0.png | assets/dungeon/anim/facing/eel_facing_idle_f0.png | assets/dungeon/anim/slash/eel_slash_f0.png (f0-f3) | yes |
| druid | assets/dungeon/anim/facing/druid_facing_idle_f0.png | assets/dungeon/anim/facing/druid_facing_idle_f0.png | assets/dungeon/anim/slash/druid_slash_f0.png (f0-f4) | yes |
| mouse | assets/dungeon/anim/facing/mouse_facing_idle_f0.png | assets/dungeon/anim/facing/mouse_facing_idle_f0.png | assets/dungeon/anim/slash/mouse_slash_f0.png (f0-f3) | yes |
| magicat | assets/dungeon/anim/facing/magicat_facing_idle_f0.png | assets/dungeon/anim/facing/magicat_facing_idle_f0.png | assets/dungeon/anim/slash/magicat_slash_f0.png (f0-f4) | yes |
| rust_bucket | assets/dungeon/anim/facing/rust_bucket_facing_idle_f0.png | assets/dungeon/anim/facing/rust_bucket_facing_idle_f0.png | assets/dungeon/anim/slash/rust_bucket_slash_f0.png (f0-f3) | yes |
| poison_frog | assets/dungeon/anim/facing/poison_frog_facing_idle_f0.png | assets/dungeon/anim/facing/poison_frog_facing_idle_f0.png | assets/dungeon/anim/slash/poison_frog_slash_f0.png (f0-f3) | yes |

## Counts

- 55 / 55 wheel seats use facing idle frame 0 (portrait crop). 0 use wheel breathe. 0 use the still.
- 55 / 55 fight callouts use that same facing frame 0. Same silhouette: 55 yes, 0 no.
- 55 / 55 hover plates use the still PNG.
- 53 / 55 slash cut-ins use `_slash_f*`. Wizard and Golem fall back to the still.
- Slash opaque shape vs the wheel crop is under 0.80 (32x48 nearest mask) for goblin (0.67), harpy (0.52), and rust_bucket (0.72). Those three slash poses do not match the idle silhouette. The yes/no column does not include slash.

