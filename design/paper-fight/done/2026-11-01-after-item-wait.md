# Paper Fight — After-item / after-spin wait until the action is done

**Pitch (Nathan’s words):** Facing Amalgam, Pocketwatch a Direwolf opposite Amalgam so Direwolf’s attack should kill Amalgam. Today Adaptation doubles Amalgam after Pocketwatch is spent from the hotbar, before Direwolf’s killing blow. Expected: the whole item finishes first (including that attack and the death), then anything that says “after an item is used.” Same wait for “after spin” / “when you spin me,” and for other follow-ons that currently fire in the middle of an item or a monster ability.

**Restate (what the player does):** You are fighting Amalgam. You click Pocketwatch, then click Direwolf (opposite Amalgam). Pocketwatch’s job is: Direwolf uses its current attack on Amalgam. That attack uses Amalgam’s HP from before Adaptation. If that attack drops Amalgam to 0, Amalgam dies. Adaptation only runs after Pocketwatch is completely finished, and only if you are still facing a living unsilenced Amalgam. The card is used up.

**Where it happens in a round:** Fight only. Pocketwatch is click-then-pick. The opposite monster’s full attack is part of the item. Adaptation is a follow-on.

**Rulings (2026-11-01):**
1. After the item is done, look at who you face now. If it is not a living unsilenced Amalgam, no double (Smoke / Hook leave them).
2. Quiet Bell silences first; Adaptation does not fire.
3. Nested Spin from Smoke Bomb / Spinning Top: ignore for this pass (not treated as a live sequencing job).
4. Every “after each item” effect waits until the item is fully done: Dual Sais, Shield flip, Toll, Amalgam, Harpy, Bushido.
5. On-hit / on-this-attack text stays inside the item (Poison Frog, Needleback, Hornet extra swing, Vampire, Eel).

**Shipped:** `_count_item_use()` only arms the follow-on. `_commit_after_item_use()` runs from `_after_item_resolved` after the item body.
