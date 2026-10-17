# Paper Fight — Home Cabin

Locked from Nathan’s answers 2026-10-17 (Home Cabin playtest plan). Implemented.

**Pitch (Nathan’s words):** Home Cabin should feel like its own place. After you Leave (or from the title), the hero walks off screen, the camera pans, and you click the closed cabin door. Inside, the hero rocks by a fireplace. Shelves are organized by bucket. Unopened buckets are dark silhouettes. Items you have seen are grey outlined and named. Items you brought home (swiped) sit on a wooden trophy mount with a gold plaque that glints, more on hover. Visual collection only — no pocketing an item out of the dungeon.

**Restate (what the player does):** After a dungeon, Continue keeps leftover items in your hand and starts the next hall. Leave walks you home. You click the cabin door, then look at shelves. A Home button on the title and pause opens the same cabin without walking off a fight. You do not spend items here. You do not pick a fight target.

**Where it happens in a round:** After rest (Leave) or from title/pause. Not during draft, spin, or a fight. Nothing is used up. No target click on a monster. Collection state is saved: Seen and Swiped keep updating across runs; a mount does not copy a combat number.

---

**Which existing cards this touches:**

- **Every live item** — each has a shelf slot in its bucket. Token / retired / hold stay out.
- **Smoke Bomb** — always-starter; still Seen if it was in a dungeon hand. Swiped only if it is in hand on Leave.
- **Spider Egg** — if it is not a bucketed live item, it has no shelf.
- **Mimic gift** — an item that appears mid-dungeon can become Seen the moment it is offered or held.
- **Cleric steal** — an item taken from the hand was still held, so it is Seen; it is Swiped only if it is still in hand on Leave.
- **Merchant upgrade** — the upgraded id is what gets Seen/Swiped, not the old id.
- **Counting Beads / two copies** — one shelf slot per card id, not per copy. Two Beads in hand on Leave still mount Beads once.
- **Hornet / Queen / Wraith / Commander / Dragon / Goblin / Slime** — combat specials do not run in the cabin. No extra swings, no pierce, no ATK=HP on a plaque.
- **Empty alcove / last owner** — not in the cabin.
- **Tutorial kit** — How to Play does not open Home. Cabin is title / pause / Leave only.
- **Developer Test** — Leave from a real rest is the swipe path. Dev Test skip-to-victory should not swipe unless they used Leave.

**Generous reading:** Any item that flashed on a draft door or sat in the hotbar for a frame is Seen. Leave with a full hand mounts every leftover forever, including tokens, and death still mounts because you “had” them.

**Stingy (chosen) reading:** Locked bucket = not unlocked yet, whole shelf dark, no names. Seen = offered or held in any dungeon, any mode, any outcome, grey outline plus name, not mounted. Swiped = still in hand when you click Leave, full sprite on a wooden mount, gold plaque, saved in `user://home_cabin.json`. Death does not swipe. Continue does not swipe. One slot per card id. Token / retired / hold have no slot.

**Ways it can fail:**
- Leave from rest both swipes and also goes to the old victory overlay with no door click, so the cabin never opens.
- Continue accidentally writes Swiped and empties the next dungeon’s hand.
- Death writes Swiped (the bank-or-push rule we rejected).
- Two copies of Beads create two mounts or double-write the save.
- Unlocked bucket 1 items show as locked silhouettes because cabin reads a different counter than `_bucket_open`.
- Hover inspect on a locked silhouette opens the Edit card sheet.
- Title Home during a fight pauses combat incorrectly and lets you swipe mid-dungeon.

**What the player sees:** Exterior cabin, click the door, interior with rocking and fire. Locked rows are dark. Seen rows are grey named sprites. Swiped rows are mounted with a gold nameplate. Hover glints. No combat numbers.

**If we skip this:** The skull plaque already counts kills. There is no home and no item collection.

**If we take the strongest reading:** Every item you ever saw, including death leftovers and Continue leftovers, is mounted. The cabin becomes a completion log, not “what you walked out with.”

**Questions for Nathan:** None. Leave vs Continue vs death, Seen vs Swiped vs locked, and no pocket-out were answered in the plan.

**Self-audit:** restated as what the player does · named Smoke Bomb / Cleric / Beads / Mimic / tutorial · both readings · questions already answered · implementing this turn per the approved plan
