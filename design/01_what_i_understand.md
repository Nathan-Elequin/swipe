# What I think Boss Rush is

Read from `source/01_Boss_Rush_Content.xlsx` (sheets dated April–May 2022). This is my reading, not a spec. Nathan should mark what is wrong or missing.

## The loop

This is not Mega Man “pick a boss and steal the weapon.” It is closer to a **roguelike hand of items** plus a **fortune wheel of monsters** that **shrinks as you win**.

1. **Startup** — menu, start.
2. **Place starters** — fill an **8-slot wheel**. First **4 starter monsters** go NESW, blanks between them. You also get starter items. Default starter count is **4** (a “Hard” note says 5 later).
3. **Dungeon draft** — draw **one monster and one item** (tier odds 40% / 35% / 25% for tiers 1 / 2 / 3). You either:
   - **Add the monster** to an empty slot (item goes to your hotbar), or
   - **Bribe** — spend the item to **block/remove a slice** (monster is gone).
   Repeat until every slot is filled (starters + 4 more by default).
4. **Begin dungeon** — button, then combat.
5. **Combat** — **spin** a random remaining monster. Use items (tap). Then **Resolve Combat** (a Done button): enemy ATK minus your BLK hits your HP. Dead monster → **remove that slice**, neighbors close up, repeat until you die or the wheel is empty.
6. **End** — death or victory.

Player **HP starts at 6** and cannot go above 6.

## Combat math (as written)

`New HP = HP - (Enemy ATK - BLK)` after you click Done, unless you already **Defeated** the enemy with an item (Da Boot, Sledgehammer, Fangs, etc.) and skipped that step.

**Kill** (ATK damage to 0 HP) and **Defeat** (item that removes them without that fight) are treated as different words. Goblin cannot take ATK damage but can still be Defeated or lose HP from things that are not ATK (Poison Flask).

Items are usually discarded after combat. Some tap/untap (Breastplate, old Dagger). Healing Potion is unplayable and fires when you would die (text says heal to 3 in one place and set HP to 4 in another).

## The board

Monsters on the wheel have **neighbors**. Lich/Commander buff neighbors. Wraith copies the highest neighbor ATK. Bracers/Pocketwatch/Poison/Crossbow care about neighbors. Last enemy has no neighbors, so some items turn off.

Smoke Bomb: abort combat, spin again, not the same slice, gain a random unseen item.

## Content in the sheet

Monsters (**M**) and items (**I**), each with Starter vs Uncommon, tiers 1–3, copy counts, ATK/HP, ability text, and trigger timing (`On Spin`, `On Remove Slice`, `On Item Use`, …).

`Dev?` / `Art?` looks like “in the build.” `Hide?` True looks retired (Dagger, a second Helmet, Bandana).

Tier count targets (Starter / Uncommon × tiers) are on the **Tier Counts** sheet. **Patch Notes** is a subset of rows with dates.

## Engine / presentation

Not specified. Flow talks about drag-and-drop, a hotbar, a wheel animation, a “Cannot Be Used” message. Could be digital board game, Unity, Godot, etc.

## Places the sheet already disagrees with itself

I will treat these as gaps, not guesses to code:

- Dragon: ability says ATK **ignores block**; special function talks about **doubling** the first BLK or ATK you gain.
- Healing Potion: “heal up to 3 HP” vs “set HP to 4.”
- Commander neighbor bonus: +2 in the ability vs +1 in Function Flow.
- Wraith notes mention **Captain**; the roster has **Commander**.
- Knucklers: ability is ATK from item count; Function Flow also mentions HP delta.
- Spiked Flail: ability is ATK from kills; Defined column talks about highest HP.
- filter_active_content vs All Content: hidden/retired rows differ; some `Dev?` flags differ (Leech League, Mimic, etc.).

## What the sheet does not say

- Win condition besides “wheel empty.”
- What BLK does if it exceeds enemy ATK (floor at 0?).
- Whether you can use several items in one fight (Serpent implies yes).
- Starting item count vs the 4 starter monsters.
- Platform, art style, input, meta (unlocks, daily, multiplayer).
- Why it is named Boss Rush.
