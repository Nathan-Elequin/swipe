# Paper Fight — Rust Bucket defeat discards all Rust

**Pitch (Nathan’s words):** Rework: add the line afterwards, 'When I am Defeated, lose all Rust.' When Rust Bucket is defeated, immediately and forcibly discard all Rust in the player's hand.

**Restate (what the player does):** Rust Bucket still grants 1 Rust when it enters the dungeon. After that, if this monster is Defeated, every Rust token in the hotbar is discarded right then, without a click. Combat continues with those seats empty.

**Where it happens in a round:** on Defeat of this slice (HP to 0, a Defeat item, or Block that kills it). The enter-grant is unchanged. The player does not pick which Rust. The number is not copied; the tokens leave the hand.

**Which existing cards this touches:**
- Rust token (the thing discarded)
- Two Rust Buckets on one wheel
- Quiet Bell (enter grant skipped; Defeat still?)
- Echo Bell copying a use of Rust
- Bag of Holding / spent / Keep seats
- Death Bell / other Gain overlays if a Rust was sitting in a full-hand overlay
- Phoenix / Commander / Triclops / Ball and Chain Flee (is Flee a Defeat?)
- Eject / Polymorph (not Defeat on Clockwork's notes; same here?)
- Mimic gift after Attack
- Hornet extra swing that kills the Bucket
- Goblin (irrelevant to Rust discard)
- Tutorial kit (Rust is later-pool)

**Generous reading:** Defeating this one Bucket discards only Rust that this Bucket granted, and only if that copy is still in hand. Flee / Eject / Polymorph do not count. Quiet Bell on enter: no grant, so Defeat has nothing of yours to take. A second Bucket's Rust stays.

**Stingy reading:** Any Defeat of this slice immediately discards every Rust in the hand, from any source, including a second Bucket. Overlay Rust that never seated still vanishes. Flee / Eject / Polymorph also count if they remove the slice. Quiet Bell does not stop the Defeat discard.

**Ways it can fail (crash, stuck game, card text that does not match the hit):**
- Hand compaction after a mid-fight force-discard leaves a stuck feed overlay
- Two Buckets: defeating one empties Rust, then the second Bucket's enter-grant already happened so the player is Rust-less with a live Bucket
- Discard during an in-flight item use of Rust
- Ability still says only the enter line while the discard already happens

**What the player sees:** Bucket dies. Every Rust card leaves the hotbar at once. No extra click.

**If we skip this:** Rust stays after the Bucket dies; the token is a lasting gift.

**If we take the strongest reading:** One click that kills the Bucket (Boot, Sledgehammer, Take) can empty every Rust in hand, including ones from a second Bucket.

**Questions for Nathan:**
1. All Rust in hand, or only Rust this Bucket granted?
2. Does Flee / Eject / Polymorph of this Bucket discard Rust, or only a real Defeat?

**Answers (2026-11-02):**
1. Every Rust in the hotbar, from any source (including a second Bucket).
2. Only a real Defeat. Flee, Eject, and Polymorph do not discard Rust.

**Shipped:** Quiet Bell still turns the Defeat discard off, matching other on-Defeat specials on this hook.
