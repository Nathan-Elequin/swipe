# Open questions for Nathan

1. **Intent numbers:** Should the intent plate show the exact number per swing (e.g. "2 ×3"), or only icons and pips, leaving the total to the "Take {n}" button?
2. **Sai:** The data says 2 ↔ 4, not 1 ↔ 2. Is "one sai = 2, pair = 4" the read you want? The ruling `sai_alt_24` says it **starts at 2 each combat**, but the catalog `exceptions` says it should **carry over** between fights. The code keeps `alt_n` on the item, so it currently carries over. Which is right?
3. **Marble:** ATK or BLK is rolled at use time, so the hotbar can't preview it. Is the swirl on use enough, or should the card idle-swirl both colours until it's used?
4. **Poison** is a lump that fires on the next Spin (you) or when that monster is spun, then clears. Should it look like a countdown/pending drop rather than damage over time? Does Jam want a visible word for it on the hub?
5. **Hover previews:** Should hovering an item ghost-preview its effect on the intent (Kobold +1 swing, Net −2, Amalgam ×2, Bushido "no effect")?
6. **Cascade pacing:** Should the on-spin cascade (about 25 possible triggers) be skippable or fast-forwardable once the player has seen each trigger a few times?
7. **Sizes:** Do monster sizes map to rarity (Weak 32 / Tough 48 / Deadly 64), or are they per monster?
8. **Numbers to settle before animating them:** max HP is 6, but Medallion and Bloody Wraps say "7 − HP". Knucklers ability says 8, while the ruling and ops say 7. Spiked Flail ability says +2 per bleed, the ruling says +1.
9. **Berserker coin flip:** Is Grandpa's coin (Nib's idle line) OK as the visual for the 50% roll?
10. **⚑Jam, "Tier" leaks:** `keyword.swap_body` ("same **Tier**") and the Clockwork Knight explainer ("Two **Tier** 2 if I live") would show the word to players. Also: new labels for Silenced, the loaded Sling, and a Triclops call name?
11. **Name source:** `player-copy.json` has no item or monster names. Is `catalog.json` `name`/`call_name` the Jam-owned source for those?
