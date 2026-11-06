# Batch-2 catalog handoff (2026-11-06) — Nathan paper-fight + Pixel art locks

Tip base: `playtest/latest` (scale-four #420 already merged).
Open PR → `playtest/latest`. Always-merge tip PRs when smoke green (Nathan rule).

## Cards

### 1. `shardplate` — NEW item, Tier 1
- **Name:** Shardplate
- **Art:** Pixel lock **B** → `shardplate/LOCKED.png` (china saucer made of broken shards — pun)
- **Ability (locked):** Gain 0 Block. When you deal Attack Damage, this Gains +2 Block. On Spin, this Loses 2 Block (cannot go below 0).
- **Cash rule (locked):** Play spends the card for its current Block (used up).
- **Grow rulings (locked):** Self-damage (Eggs etc.) counts. AOE grows +2 per target that takes damage (Great Axe +6, Prism more). Does **not** grow when attacking a Goblin that takes no damage.
- **Combat:** Stub `flags.dev` / unrecognized ops if tip has no safe compose for “counter on item + spend on play.” Prefer a clear ops shape if peers exist for Keep/counter items; otherwise stub and document gap in PR body.
- **Pool:** Nathan did not lock. Prefer a non-fat item pool (avoid overcrowding); `mode_pool: "all"`, rarity uncommon, count 1, priority 3. Note chosen pool in PR.

### 2. `love_potion` — NEW item, Tier 2
- **Name:** Love Potion
- **Art:** Pixel lock **B** → `love_potion/LOCKED.png`
- **Ability (locked):** Select any 2 living monsters with **equal HP**. Find the lowest number among their Attack and HP; set **all four** values (both HP and both ATK) to that number.
- **Example:** A 4 HP / 8 ATK and B 4 HP / 1 ATK → both become 1 HP / 1 ATK.
- **Combat:** Stub `flags.dev` until select-two + equalize is wired. Document gap.
- **Pool:** unlocked — pick peer default; note in PR.

### 3. `tesla_coil` — NEW item, Tier 1 Defeat
- **Name:** Tesla Coil
- **Art:** Pixel lock **A** → `tesla_coil/LOCKED.png`
- **Ability (locked):** Flee and Gain 1 Charge. When you Spin an enemy with less HP than this number (Charge), Defeat them.
- **Charge (locked):** Persists across uses **and** dungeons (does not reset on Spin-Defeat fire, does not clear on dungeon end).
- **Combat:** Stub `flags.dev` for Charge bank + Spin-Defeat threshold unless tip already has Charge peers. Document gap.
- **Pool:** unlocked — pick peer default; note in PR. Type/Defeat item peer if catalog has a Defeat category.

### 4. `anvil` — REWORK live monster (keep id `anvil`)
- **Replace** live min-3 HP tax entirely.
- **Stats (locked):** HP 3, ATK 3 (was 9/4).
- **Ability name:** Headstrong
- **Ability (locked):** I Always have +4 HP and +4 ATK when I am Facing you.
- **Rulings (locked):** Fairy-style — no carry when Move away (HP/ATK snap back to base; damage taken while facing does not leave a residual after Move). Can be killed by ranged. Can die to poison before facing ability fires (poison first).
- **Pool:** keep live pool **5**.
- **Art:** Reuse live still (do **not** replace still PNG from tip). Wire facing from `anvil/facing_LOCKED.png` (Pixel facing **B**). Only one facing plate was locked — if tip facing idle needs f0–f3, duplicate the locked plate into idle frames the same way prior cards did when idle gens were pending, and note in PR. `still_LIVE_reused.png` is reference only (prove reuse); do not overwrite tip still with a new plate.

### 5. `swift_sneaks` — RENAME `jar_o_grease` → `swift_sneaks`
- **Ability:** unchanged — Move 2 in a random direction, and Keep this. (`move2_keep`)
- **Id change:** rename catalog id `jar_o_grease` → `swift_sneaks` (Nathan lock — not display-only). Update all references: catalog, ITEM_PNG / dungeon_art.gd, any string refs, save-compat notes if tip has migration helpers.
- **Art:** Pixel lock **C** → `swift_sneaks/LOCKED.png` (Hermes tennis shoes). Retire grease-jar art path.
- **Pool/tier/rarity:** keep jar_o_grease’s (pool 4, T2, uncommon).

## Art wiring
- Items → `assets/dungeon/items/` (or tip peer path) + `ITEM_PNG` in `scripts/dungeon_art.gd`
- Anvil facing → `assets/dungeon/anim/facing/` as `anvil_facing_idle_f{0-3}.png` (or tip’s exact naming); keep existing anvil still path
- Design notes copy under `design/handoff/batch2-2026-11-06/`
- Repot inbox note optional (scale-four pattern)

## Do NOT
- Change other catalog numbers / silent nerfs
- Edit `data/player-copy.json` (Jam owns copy)
- Implement half-broken combat — stub with `flags.dev` and list exact gaps in PR body
- Wait on F5 / Affine

## Verify
- Tip smoke / Godot headless if the repo has that check
- PR body: card table, art sources, combat stubs, rename migration notes for jar→sneaks
