# Itch combat shots

Wheel badges, monster plaques, the draft-gate rank, the journal danger stamp, and the challenge loot line now say Weak, Tough, or Deadly. The fight button that used to read Safe with no picture now keeps that word and shows a shield. Three new harness shots sit with the text audit.

`data/player-copy.json` was not edited.

## Files changed

- `scripts/boss_wheel.gd`
- `scripts/main.gd`
- `scripts/cabin/journal_overlay.gd`
- `scripts/dev/shot_harness.gd`

## Audit

Before this pass, `design/cli-runs/02-fx-tooltips/text_audit.json` (2026-10-17 18:34) had `failures: []`. That run still painted "Tier 1" on the wheel and the fight button read "Safe" with no icon (`text_combat_tips.png` in that folder).

After, `design/cli-runs/03-itch-combat/text_audit.json` (2026-10-17 18:51) on intro panels 1–3, combat with the card tooltip and the monster plaque open, the item hand, the mid-fight wheel, the draft gate, and the Deadly fight:

`failures: []` (zero hits).

## Screenshots

- `design/cli-runs/03-itch-combat/13a_intro_panel1.png`
- `design/cli-runs/03-itch-combat/13b_intro_panel2.png`
- `design/cli-runs/03-itch-combat/13c_intro_panel3.png`
- `design/cli-runs/03-itch-combat/text_combat_tips.png`
- `design/cli-runs/03-itch-combat/text_item_hand.png`
- `design/cli-runs/03-itch-combat/40_itch_midfight.png`
- `design/cli-runs/03-itch-combat/41_itch_draft_gate.png`
- `design/cli-runs/03-itch-combat/42_itch_boss.png`

## For Jam

No new words. The mapping is already in `data/player-copy.json` and every player-facing tier badge now calls `PlayerCopy.tier_name`:

- `tier.1.name` — Weak
- `tier.2.name` — Tough
- `tier.3.name` — Deadly

The journal still has `journal.weak`, `journal.tough`, and `journal.deadly` with the same three words. The bestiary stamp uses `tier_name`, so those journal keys are not what the page prints.

## Owner strings

Left as written. Nothing here was rewritten.

Shown in play:

- `data/catalog.json` item `grappling_hook` ability, line 1288: `Swap a Neighboring Owner into this fight. Draw a Random Item.`
- `data/content-board.json` same ability, line 1130: `Swap a Neighboring Owner into this fight. Draw a Random Item.`
- `data/catalog.json` item `caltrops` ability, line 1749: `The facing owner's Attack becomes 0 this fight.`
- `data/content-board.json` same ability, line 1958: `The facing owner's Attack becomes 0 this fight.`
- `data/catalog.json` item `net` ability, line 1900: `Choose to reduce the facing owner's Attack by 1, 2, or 3.`
- `data/content-board.json` same ability, line 1544: `Choose to reduce the facing owner's Attack by 1, 2, or 3.`
- `scripts/tutorial_guide.gd` tutorial beat text, line 649: `Those hearts are you. Empty means the owners win. One heart left is still a win. Nobody grades on leftovers.`
- `scripts/tutorial_guide.gd` tutorial beat text, line 698: `Block's gone. Hearts aren't. That little plaque is your body count — the Flail is counting too. Two owners left.`
- `scripts/tutorial_guide.gd` tutorial beat text, line 726: `Last alcove. Hover it. Owners have hobbies too — they tell you if you ask. This one gets stronger when you win. Rude.`

Written into the item tooltip in `scripts/main.gd` `_item_rule`, then replaced by the card ability when that ability is not empty. The live cards above have abilities, so the player currently reads the catalog sentence, not these lines:

- line 10251, Net's drop branch: `Click 1, 2, or 3. The facing owner's Attack drops by that much after their own ability and Commander, then stays there this fight. Owners whose Attack always equals a number ignore this.`
- line 10363, Longbow (`atk_opposite`): `Deal 4 attack to the owner across from you. Needs an even number of owners.`
- line 10365, Longbow warn: `Can't — odd number of owners on the wheel.`
- line 10369, Victory Flask (`heal_kills`): `Heal 1, plus 1 for each owner you have already defeated.`
- line 10385, Grappling Hook (`hook_swap`): `Swap a neighboring owner into this fight, then draw a random item.`
- line 10396, unused kind `atk_wheel` equation: `Owners left`
- line 10397, unused kind `atk_wheel` body: `Attack equal to how many owners are still on the wheel.`
- line 10401, unused kind `blk_from_atk`: `Block equal to the facing owner's attack.`
- line 10404, Caltrops (`atk_zero`): `The facing owner's attack becomes 0 this fight.`
- line 10407, unused kind `atk_drop`: `Click 1, 2, or 3. The facing owner's Attack drops by that much after their own ability and Commander, then stays there this fight. Owners whose Attack always equals a number ignore this.`
- line 10422, Quiet Bell (`quiet`): `Remove the facing owner's unique ability for the rest of this dungeon. They use their printed Attack and HP.`

Not drawn for the player. Listed so the words are not mistaken for missing UI:

- `data/catalog.json` Golem explainer, line 2397, and `data/content-board.json` line 2226: `plain ATK/HP Owner`. The wheel uses call name and ability. This explainer is not that line.
- Card `flow` / `defined` notes in `data/catalog.json` (lines 1193, 1294, 1854, 3406, 3676) and the matching `flow` lines in `data/content-board.json` (1041, 1140, 1503, 3114, 3358). Those are editor notes.
- `scripts/main.gd` lines 197–198 and 220 are unused reminder fallbacks (`plain ATK/HP owner`, `if I live, two Tier 2 owners`).
- Fallbacks that lose to saved copy, so the player does not read the word: `scripts/draft_gate.gd` line 293 `door.help` fallback `The finer the loot, the fiercer its owner.` (saved text says monster); `scripts/hover_panel.gd` lines 72 and 74 inspect fallbacks (saved text says monster); `scripts/main.gd` line 11331 `cue.devtest` fallback `at least one owner` (saved text says monster).
- `scripts/content_editor.gd` line 316 is the card editor, not the play screen: `This owner’s live Attack uses the formula`

## Safe-state explanation

The button under the wheel during a fight is `btn_done`, not `btn_spin`. `_sync_buttons` hides Spin unless `phase` is `ready`, and shows the done button while you are facing a living monster.

In the combat tooltip shot the phase is `fighting`, block is 3, and the Goblin's attack is 3, so `_incoming_hit()` is 0. The done button then uses `combat.safe`, whose saved text is `Safe`. That button was built with no icon. Spin keeps the word Spin and `assets/icons/rotate.svg`, and it is not on screen in that shot.

The done button now sets a shield icon when the hit is 0, and a sword icon when the label is `Take {n}`. Each time the buttons sync, Spin is set back to `combat.spin` and the rotate icon. `text_item_hand.png` is the ready phase: the visible button reads Spin and shows the rotate icon. `text_combat_tips.png` is the zero-damage fight: the visible button reads Safe and shows the shield.

## Could not fix

- Author-locked card abilities that say Owner were left alone, on purpose.
- The roster and card editor still label the number field "Tier". That is the authoring field, not a badge the player reads.
- Unused reminder and speech tables in `scripts/main.gd` (`MONSTER_REMINDER`, `MONSTER_SPEECH`) still contain `Tier 2` for Clockwork Knight. Nothing reads those tables.
- The mid-fight and boss shots include the normal facing-monster plaque. That plaque is what a fight already shows. Hover tooltips were not opened on those shots.
