# Paper Fight — Rust Lose 1 HP, +1 per copy, full-hand dump

**Pitch (Nathan’s words):** Gain 2 Block, Lose 1 HP. Whenever you Gain Block, Gain 1 Rust (per Rust in hand). If a gain happens and the ten slots have nothing tossable, auto-discard remaining items trying to enter. Hover/click a Gain Block item: all Rusts glow cursed aura.

**Restate:** Click Rust in a fight: +2 Block, then −1 HP (potion/die as usual), then used up. Any Gain Block (including this click) queues +1 Rust per Rust already in hand. One wave. New copies from that wave do not fire. Hover a usable Block-granting item: every Rust shows its curse aura.

**Where it happens:** fighting / used up / no extra target / snapshot per Gain Block event.

**Which existing cards this touches:**
- Shield, Signpost, Marble, Shield Alt (block face), any `blk*` item
- Spider Egg / Toll / other curses (cannot toss)
- Cube, Worm, Bell, Hired Hand, Oligarch, Mimic gift, draw

**Generous reading:** Glow on hover of anything that *can* grant Block.

**Stingy reading:** Glow only after the click commits.

**Ways it can fail:**
- Hand of 10 curses + wave of Rust stays at 11+
- Hover rebuilds the hotbar and flicker-clears the aura

**What the player sees:** Black curse Rust, −1 heart pip, aura on siblings when pointing at a Block card.

**If we skip this:** Old +2 spawn, no HP cost, overflow stays over 10.

**If we take the strongest reading:** Implemented: +1 per copy, HP after Block, dump leftover incoming, glow on hover of a usable Block grant.

**Questions for Nathan:** none — numbers and overflow were named.

**Self-audit:** implemented this turn (exact numbers + overflow named)
