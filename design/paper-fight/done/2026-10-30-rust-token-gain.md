# Paper Fight — Rust Bucket / token Rust (shipped)

**Pitch:** Rust Bucket 4 HP 3 ATK. Same monster ability. Token: Gain 2 Block. Whenever you Gain Block, Gain 2 Rust.

**Answers:**
1. Used up after the 2 Block.
2. 2 Rusts + one Gain Block → 6 total (each copy adds 2).
3. One wave per Gain Block, not per point.
4. Force into hand like Spider Egg, then toss overlay. Intended to be bad. Cannot toss Rust in that overlay; if only Rust is left, the hand stays over cap.
5. Cube / Worm / Bell / Hired Hand / a full-hand replace can dump Rust.
6. Stone Wall leftover is not Gain Block.

**Clustered while coding (did not stop the build):**
- Twins that Gain Block twice in one click are two Gain Block events (two waves, same Rust count if we have not flushed yet).
- Grief Jar On Spin stores Block on the card; the wave fires when you click the Jar and actually Gain Block.
- Sandbag Flow still names old Rust as pierce. That field is locked; live Take no longer pierces from Rust.
- Magicat can still turn a Rust (it Grants Block) into a Marble.

**Where it lives:** `scripts/main.gd` `_gain_blk` / `_flush_rust_from_block` / `_force_gain_rust`. Catalog + board on `rust` and `rust_bucket`.
