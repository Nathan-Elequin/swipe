# Flags to Jam (copy owner) and Nathan's decisions

Everything new is in `data/player-copy.additions.json` (DRAFT rows, `draft: true`) and `data/lore.json` (DRAFT). **No existing row was edited.** The merge tool skips any key that already exists.

**Jam's review is applied.** Both data files in this package are Jam's reviewed versions (49 edits, plus Jam's 3 `map.route.*.mode` rows); the review notes are in `_pixel_extras/JAM-REVIEW.md`. After that review, Pixel added **18 copy rows and 1 lore entry** for Nathan's decisions 5 and 6. They are listed below under "New keys after Jam's review" and are marked `ADDED AFTER JAM REVIEW` in their `where` field. Jam has not seen them yet.

The list below covers existing copy that this overhaul stops using, changes the meaning of, or needs a decision on.
## Flags to Jam
1. **`title.leave`** ("Exit"; the audit says the saved text was "Leave") is no longer shown. The cabin has no Exit button, and the rest-phase Leave is now `rope.climb` ("Climb home"). The key stays in the file; Jam can retire it.
2. **`title.adventure_win`** ("Victory") is no longer shown. Death after a Challenge clear is a loss now (SYSTEMS §3.2), so "Victory" never appears after a death.
3. **Classic win parchment** (`title.win`, `title.win_sub`) is replaced by the win homecoming. Not shown any more.
4. **Title parchment** (`title.overlay`, `title.sub`, `title.how_to_play`, `title.dive_in`, `title.begin`, `title.adventure`, `title.home`) is replaced by the cabin objects. The map pins use the new `map.route.*` names: The Gatehouse = Classic, The Long Drop = Challenge, Grandpa's Shortcut = Quick Start. Jam may want the old mode names somewhere (for example as a small subtitle under each pin).
5. **`title.rest`, `title.rest_sub`, `title.continue`** ("Delve Deeper") are replaced by `rope.cleared`, `rope.sub` and `rope.deeper`. Jam carried "Delve deeper" over as the `rope.deeper` text (applied).
6. **`pause.start_over`** and the start-over row are removed from pause. They are replaced by `pause.give_up` ("Give up"), which counts as a loss, and `pause.peek`.
7. **`title.lose`** ("Defeated" in the snapshot; the audit says "Caught") is kept on the small Caught sheet. Its button now uses the new `defeat.home` ("Limp home") instead of `title.again`.
8. **Hardcoded volume labels:** the snapshot already has `pause.master`, `pause.music` and `pause.sound`. The audit lists `pause.ambience` and `pause.ui`, but the snapshot I had doesn't. They are in the additions as add-if-missing (the merge skips them if present).
9. **`cabin.credits.body`** names (Nathan; sound credits Kenney, Mjorlaja, Aureolus_Omicron, iamoneabe, Eldritch Grim, Trex0n, PagDev) need confirming against `assets/audio/CREDITS.txt`.
10. **`tutorial.skip`** ("Skip") is still not shown in the tutorial (unchanged). The intro uses its own `intro.skip`.
11. **Weak/Tough/Deadly:** the journal uses `journal.weak/tough/deadly`, which duplicate `tier.1-3.name`. Jam can point code at `tier.N.name` instead and delete the three journal rows.
12. **Lore voice:** journal entries run 40–80 words, with one footnote each, in Grandpa's voice (Bilbo × Heimerdinger). Bestiary entries run 25–50 words. Several items with `todo` status have entries too (Nathan asked for live and todo).
13. **Letters** (`lore.json` → `letters`, 25/50/75/100 %) are the only long-form prose.

## New keys after Jam's review (DRAFT, need Jam's pass)
All rows are `draft: true` in `data/player-copy.additions.json`, category `Journal` or `Drawer`.

| Key | Draft text | Where |
|---|---|---|
| `journal.will.replay` | Read it again | Journal Will tab, tag under the portrait: replays the intro (decision 5) |
| `cabin.hot.drawer` | The left-hand drawer | Hover, drawer still stuck (before the ending) |
| `cabin.hot.drawer_ajar` | The left-hand drawer. It's open a crack. | Hover after the ending, until first opened |
| `cabin.hot.drawer_open` | Grandpa's rock drawer | Hover once it has been opened |
| `drawer.stuck.1` | It won't budge. He did say not to. | Nib, stuck click (rotating) |
| `drawer.stuck.2` | No keyhole. Just a brass plate and a lot of attitude. | Nib, stuck click (rotating) |
| `drawer.stuck.3` | Something heavy rattles in there. Rocks, by the sound. Very him. | Nib, stuck click (rotating) |
| `drawer.hint` | Did you hear that clunk? It came from the study. His desk. | Nib, once, right after the ending |
| `drawer.title` | The left-hand drawer | Drawer close-up heading |
| `drawer.open.nib` | Rocks. A whole drawer of rocks. Of course it was rocks. | Nib, first time the drawer opens |
| `drawer.note` | A note in his handwriting | Hover, the folded note |
| `drawer.geode` | The one that is not a rock | Hover, the lucky geode in the drawer |
| `drawer.take` | Put it on the mantel | Tag: move the geode to the mantel |
| `drawer.close` | Close the drawer | Tag: close the close-up |
| `drawer.taken.nib` | On the mantel. Where he'd have put it, if he ever finished anything. | Nib, after the geode lands |
| `cabin.hot.geode` | The lucky geode | Hover, the geode on the mantel |
| `cabin.geode.line.1` | Still lucky. I checked. | Nib, click the mantel geode (rotating) |
| `cabin.geode.line.2` | He'd be insufferable about this. Good. | Nib, click the mantel geode (rotating) |

**Lore:** `lore.json` → `drawer_note` (title "The note in the drawer", 71 words, Grandpa's voice, no contractions). It pays off letter 25 (the saved "geodes. Mostly."), letter 100 ("So is the luck. Mind the left-hand drawer.") and the will's drawer line.

Things for Jam to check:
- `drawer_note` (Jam edits applied): "Rightful Heir Latch ... opens for my heir and nobody else" and "I saved you one every week."
- Nib's lines are all under 15 words; Grandpa's note has no contractions, to match the other letters.
- The note opens in the loft LetterCard and closes with the existing `cabin.trunk.close`, so it needs no new close key.
- The existing joke lines are unchanged: `will.p5`, `keyring.door.study`, `letter_100`.

## Nathan's decisions (2026-10-17, final)
1. **Gear rack:** cosmetic only, as built. No run effect. (Docs: SYSTEMS decisions, SCREEN-main-room "Gear", SCREEN-workshop.)
2. **Tutorial decline:** Nib asks once; after "I'll wing it" he never interrupts again. The practice dummy still offers the tutorial. (SYSTEMS §5.)
3. **Death:** the small "Caught" sheet keeps Undo working, then "Limp home". (SYSTEMS §2 table, §8.)
4. **In-run pause volume:** Master only. (SCREEN-pause.)
5. **Intro replay:** "Read it again" on the journal's Will tab; new key `journal.will.replay`. (SYSTEMS §7.2, SCREEN-study, SCREEN-intro.)
6. **The left-hand drawer:** a post-ending secret: stuck with the joke lines before the ending, an unlatch clunk + Nib hint + knob glint after it, an open animation, then ~60 rocks, Grandpa's last note and the lucky geode, which can go on the main-room mantel as a cosmetic. (SYSTEMS §7.1, SCREEN-study, SCREEN-main-room, SCREEN-ending, STORY-BIBLE.)

## Still open (from Jam's review, for Nathan)
1. The Gatehouse subtitle: "Classic" or none? Is "Adventure Mode" right under The Long Drop?
2. Does the 40–80 journal range include the footnote? (Jam advises yes; nothing was padded.)
3. British or American spelling across lore and game text?
4. Arrow Head, Danger Magnet, Vampire, Bodyguard, Cowardly King, Merchant, Juggernaut, Cleric: are they in the game, and what do they do? (Their lore is on hold.)
5. Rename the catalog's "Paci Fist" to "Paci-Fist", and keep the Victory Flask goblet joke or redraw it as a flask?
