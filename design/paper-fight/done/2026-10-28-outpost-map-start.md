# Paper Fight — Outpost map + campaign opening six

**Pitch (Nathan’s words):**
Delete the six hanging loadout items and the outpost reroll jar. Make the map the only run control, large and labeled. Starting a run (and every later dungeon in that run) grants six items 3 T1 / 2 T2 / 1 T3 from all unlocked pools, shuffled. Monsters on the wheel use that biome’s Weak/Tough/Deadly mix but may be drawn from every unlocked pool. Shortcut starts empty then gets the same six. Push keeps the hand and grants another six. No Smoke Bomb. Pair extras may appear. Duplicates only if catalog `count` > 1. Deadlies unique within one five-biome run. Drop the 3-unique map gate. Remove the Deadly name overlay (new map will show them later). Challenge and Adventure as separate modes are dead; campaign is the path. Art: reuse cabin wood/doors; PixelLab a large wall map.

**Restate (what the player does):**
They walk into the Outpost, see a large labeled wall map, click it (or press Space), then click a biome node on the held map. The wheel of six plus four reserve seats itself. Six items appear in the hand. They look at the hand, then they Spin. After a clear, if they Push, they keep those items and receive six more. A shortcut node starts with an empty hand, then the same six.

**Where it happens in a round:** campaign start / each dungeon setup / not a card / no target click / mix is rolled once per dungeon.

**Which existing cards this touches:**
- Smoke Bomb (must never be forced or rolled into campaign opening)
- Right Bracer / pair extras (allowed)
- Token-bucket cards (still out)
- Goblin and other pool-1 mill (eligible in biome 1)
- Deadlies (Dragon and the rest: unique per run, not per save)
- Challenge pick-two / mudroom pegs (removed for campaign)
- Hand cap of 10 (would eat the extra six on Push)

**Generous reading:**
Keep the hand on Push and add a full extra 3/2/1 six. Hand cap rises so cards are not silently dropped. Map works on the first visit. Inspect pause: no auto-Spin after the grant.

**Stingy reading:**
Only grant six when the hand is empty; keep the 10-card cap and refuse extras.

**Ways it can fail (crash, stuck game, card text that does not match the hit):**
- Granting 6 per dungeon with a 10 cap silently discards on dungeon 2
- Thin T3 in pool 1: empty slot or pulling a locked pool
- seen_deadly on the save blocking a later run
- Peg loadout still seating the hand after UI deletion
- Auto-Spin skipping the inspect pause

**What the player sees:**
Outpost with a big map and a hall door. Held map with biome names. Wheel seats. Six item cards. They choose when to Spin.

**If we skip this:**
Peg loadout and pick-two stay; the room still looks like AutoSprite clutter.

**If we take the strongest reading:**
Five biomes of +6 items (~30 cards). Cap 50. They can drown in loot. Accepted.

**Questions for Nathan:**
Answered 2026-10-28. Implemented same turn. Table: Deadly telegraph on the new map (not this pass). Challenge/Adventure mill left in code but title buttons hidden. Pool-1 T3: downrank if a slot cannot fill. PixelLab token missing on Cherry; wall map is parchment + existing stamps, not generated art.

**Self-audit:** restated · collisions named · both readings · answers in · implemented
