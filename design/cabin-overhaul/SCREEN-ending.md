# SCREEN: Ending (cabinet full; play continues)

Mocks: `_pixel_extras/review/mocks/13_cut_ending_p2.png`, `13_cut_ending_p3.png`, `21_main_drawer_hint.png` (the hint right after).

Trigger: after the last shelf flight of a win homecoming that makes `cabinet_progress()` = total/total and `ending_seen == false` (SYSTEMS §7). It uses the same `cutscene_player.gd` as the intro.

| # | Panel | Hold | Caption | Nib | FX / motion | Audio |
|---|---|---|---|---|---|---|
| 1 | `cutscenes/ending_p1.png` (the full cabinet, every shelf lit) | 6 s | `ending.p1` | — | Slow pan x −6 native; random `plaque_glint` sprites on 6 spots | `cabin.ending_start` (music ending bed, music box 4) |
| 2 | `cutscenes/ending_p2.png` (Nib with the deed and the rubber stamp) | 6 s | `ending.p2` | — | At 2.5 s, PanelA shakes ±2 native (3 steps, 0.15 s) | `cabin.seal_stamp` at 2.5 s |
| 3 | `cutscenes/ending_p3.png` (the stamped deed + portrait) | 7 s | `ending.p3`, then `ending.p4` | `ending.nib` | Deed headline Label `ending.deed` over the panel top (34 px, ink #3a2414) | `sting.ending` at start |

On finish:
- Fade to the main room, where the hero plays `hero/hero_cheer_f0..f1` twice.
- A single choice tag `ending.continue` in the dialog box closes the scene, after which play continues as normal.
- `ending_seen = true`. `letter_100` unlocks in the loft trunk.
- The Escape skip is allowed (the same as the intro).
- Then, back in the main room, the left-hand drawer unlatches: 0.6 s later cue `cabin.drawer_unlatch` (offscreen), and Nib says `drawer.hint` once (`drawer_hint_said`). The study drawer shows ajar with `fx/drawer_glint` until opened (SYSTEMS §7.1, SCREEN-study).

**Copy:** `drawer.hint`, `ending.p1`, `ending.p2`, `ending.p3`, `ending.p4`, `ending.nib`, `ending.deed`, `ending.continue`, `intro.skip`, `intro.next`

**Cues:** `cabin.drawer_unlatch`, `cabin.ending_start`, `cabin.seal_stamp`, `sting.ending`, `cabin.panel`, `speech.nib`
