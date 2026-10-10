# Paper Fight — done 2026-10-06

Adventure Mode: endless dungeons. Keep leftover items. After each clear, two of the four opening owners go up one tier. Die after dungeon 1 and the screen is a victory with how many dungeons you cleared. Optional quit between dungeons.

**Pitch (Nathan’s words):**

Adventure Mode starts identical to core play for starter owners, starter items, and drafting as owners enter. Die = current game over. Survive a dungeon = keep leftover items, victory beat, wipe to a new area, heal to full, four opening owners enter, two of them transform up one tier, then the rest of that dungeon is the same. Next dungeon, upgrade two of those four at random again (a T1 can become T2, a T2 can become T3). No extra loot for clearing — only the leftover hand. Endless until they die or quit. Death after the first dungeon is cleared should feel like a win and show dungeons cleared.

**Restate (what the player does):**

On the title they pick Adventure Mode. Dungeon 1 plays like Begin: four opening owners, mill drafts, spin, fight. If they die here, they see Caught plus 0 dungeons cleared. If they clear the last owner, leftover items stay, they heal to 6, they see Continue / Leave. Continue: wipe, four opening owners sit at their current tiers, two that can still go up swap to a random owner one tier higher, then mill/draft/spin/fight. Leave or later death: Victory and the number of dungeons finished.

**Where it happens in a round:** Title (Adventure Mode). After the last owner of a dungeon is removed. New dungeon setup before mill. Upgrade happens by itself on two of the four opening seats.

**Which existing cards this touches:** Leftover hand (Knucklers, Bandit, Potion, Jar, Breastplate, Knife). Trophy / Flail / Flask / Berserker / bleed reset each dungeon. Smoke returns with each new starter pack. Pools refill. Opening four are T1 only (Lich in, Ogre / Berserker / Dire Wolf / Serpent / Slime Boss out). Tutorial stays one dungeon.

**Locked answers:**
1. New fourth title button; Begin / Dive In / How to Play stay one-dungeon.
2. Dungeon 1 = mill (Begin).
3. Tier 1 = starter / opening four. Lich becomes an opener. Ogre, Berserker, Dire Wolf, Two-Headed Serpent leave NESW.
4. Upgrade = swap that seat to a random different owner of the next tier.
5. If a picked seat is already T3: pick a different one of the four that can still go up; if none can, skip that extra upgrade.
6. Refill owner/item lists from the full roster each dungeon.
7. Keep leftovers plus a fresh opening item pack (Smoke + starters) each new dungeon.
8. Reset trophy, Flail, Flask, Jar stored block, and bleed count each dungeon.
9. Still four mill drafts after the four seats, every dungeon.
10. Die in dungeon 1: Caught plus 0 dungeons cleared.
11. Leave after a clear and die in dungeon 2+: same Victory screen with dungeons cleared.
12. How to Play stays a single dungeon, unchanged.

**Shipped:** `scripts/main.gd` Adventure Mode, hall wipe, two-seat +1 swap. Catalog/board rarity: Lich starter; Ogre, Berserker, Dire Wolf, Two-Headed Serpent, Slime Boss uncommon.
