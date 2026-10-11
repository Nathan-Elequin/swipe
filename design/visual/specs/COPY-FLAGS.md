# Copy flags for Jam (2026-10-11)

Wording flagged only. Nothing was rewritten. Jam owns `data/player-copy.json`.

| # | Where | Current | Why flagged |
|---|---|---|---|
| 1 | clockwork_knight (card) | "If I live, I leave two Tier 2 owners in my place." / explainer "Two Tier 2 if I live" | Shows the word Tier to players. Should use Tough (tier.2.name). |
| 2 | mute_stone / Chaos Stone (card) | "…a random item of that item's tier." | Lowercase 'tier' is visible to players. |
| 3 | door.pass | Repo text is "Leave it"; the brief locks "Leave it (N passes left)" | Jam to update after the {n} fill is wired. door.pass_one doesn't exist yet, so N=1 would read "1 passes left". |
| 4 | door.pass_none · cue.force · cue.steal | "Out of time" ×3 | Nothing is timed, so it reads like a countdown. Flag only (locked). |
| 5 | door.seat · cue.seat | "A monster approaches. Select their location." | Two keys with the same text. The bible calls them owners, and 'Select their location' sounds like system UI, not impish. Flag only (locked). |
| 6 | door.guard | "Guarded by a {tier} monster" | monster vs owner, same note as above. door.guard and tier.N.name are UNLOCKED and NOT WIRED. |
| 7 | title.dive_in vs tutorial.beat.18 | Button says "Quick Start"; Nib says "Dive In is the real room" | Button label and line don't match. |
| 8 | tutorial.beat.01 (shot 02) | In-game: "Hey there, greedy goblin. I'm Nib…"; repo: "I'm Nib. You're the reason eight angry owners…" | The repo copy file looks stale (stamp in the shots says 2026-10-10, repo file says 2026-10-07). 'Greedy goblin' also makes the player a goblin, which clashes with the Goblin owner. |
| 9 | CREATIVE-UX-PACK vs player-copy | Pack: win "Ours" / lose "Caught"; file: "Successfully Swiped" / "Defeated" | The file wins. The pack is out of date. |
| 10 | title.dungeons_cleared | " {n} Dungeons Cleared!" | Leading space. |
| 11 | title.rest_sub | "…loot - you'll need it…" | Hyphen where the rest of the copy uses an em dash. |
| 12 | Ability tags on the wheel (shots 04–07) | Evasive, HP Echo, Kill Shot, Siphon, Double Strike, Neighbor's Wrath, Tough Blood, Guarded by Monsters, Skip | Not in player-copy.json. Source and owner unknown. |
| 13 | Hand label (shot 04) | "Right Bracer" | The board name is "Bracers". |
| 14 | CREATIVE-UX-PACK §2/§10 | "Kenney RPG UI parchment — keep"; replacing it is "out of scope" | Conflicts with Nathan's full-refresh call. Jam should update the pack. |

---

## Jam pass 2026-10-11 ~4:21 CT (Direction A complete)

Applied (unlocked only):
- `door.guard`: `Guarded by a {tier} monster` → `Guarded by a {tier} owner` in `data/player-copy.json`. Still needs wiring (row notes NOT WIRED YET).

Author-locked — need Nathan yes before any change:
1. `door.owner` / `door.shiny` ALL CAPS → title case (The Owner / The Bait)
2. `door.pass` keep `Leave it` vs brief `Leave it ({n} passes left)` (pips already show count)
3. `door.pass_none` / `cue.force` / `cue.steal` = `Out of time` (no timer)
4. `door.seat` / `cue.seat` monster wording vs owners
5. `title.dive_in` Quick Start vs tutorial Dive In / go `I'm in`
6. `tutorial.beat.01` greedy goblin + stale long body vs short in-game beat
7. `title.dungeons_cleared` leading space; `title.rest_sub` hyphen → em dash
8. Card ability Tier strings (clockwork_knight / mute_stone) if they live outside player-copy — still flagged, not found as player-copy keys

Flag-only / pack: CREATIVE-UX-PACK win/lose out of date; ability tags not in player-copy; Bracers board name vs Right Bracer.
