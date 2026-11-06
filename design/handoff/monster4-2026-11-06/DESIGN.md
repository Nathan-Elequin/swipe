# Scale four-monsters catalog handoff (2026-11-06) — Nathan paper-fight + Pixel art locks

Tip base: `playtest/latest` (batch-2 #421 already merged @ 4dbf317).
Open PR → `playtest/latest`. Always-merge tip PRs when smoke green (Nathan rule).

Art stills: Pixel A/B/B/C. Facing: all A. Idle: huntsman + quicksand_crab real f0–f3; phantom + collector idle deferred — facing plate duplicated to f0–f3 (Anvil pattern). Nearest filter. Sizes: huntsman facing 48×48; crab/phantom/collector facing 64×64; stills all 64×64.

## Cards

### 1. `huntsman` — NEW monster, Tier 1
- **Name:** Huntsman
- **Stats (locked):** 2 HP / 3 ATK (under vs T1 vanilla 14.5)
- **Ability name:** Straight Shot
- **Ability (locked):** When the monster Across from me Attacks you, I also Attack.
- **Rulings (locked):** Fires on Across Attack-vs-you including King/Damsel command. Waits until multiattacks end (Shambling) but fires only once. Loud telegraph later (Take-X + radiating line) — catalog text only this PR; VFX is later.
- **Pool:** Nathan did not widget-lock. Prefer thin T1 — **pool 4**. Note chosen pool in PR.
- **Art:** still `huntsman/LOCKED.png` (64×64); facing `huntsman/facing_LOCKED.png` (48×48); idle `huntsman/facing_idle/f0–f3.png`

### 2. `quicksand_crab` — NEW monster, Tier 2
- **Name:** Quicksand Crab (display; id `quicksand_crab`)
- **Stats (locked):** 10 HP / 5 ATK (over vs T2 vanilla 18.5)
- **Pool (locked):** **2**
- **Ability (locked):** When you Move, I lose 2 HP. When you Spin me, you Gain 1 Move charge.
- **Rulings (locked):** Each Move step counts (Swift Sneaks Move2 = −4 HP; Grappling Hook can be multiple steps). All Crab HP loss AFTER the movement and current item/effect fully resolves (e.g. Shuriken: move → attack → then Crab loses HP).
- **Art:** still `quicksand_crab/LOCKED.png`; facing `quicksand_crab/facing_LOCKED.png` (64×64); idle `quicksand_crab/facing_idle/f0–f3.png`

### 3. `phantom` — NEW monster, Tier 3
- **Name:** Phantom
- **Stats (locked):** 4 HP / 5 ATK (under vs T3 vanilla 20.5)
- **Pool (locked):** **4**
- **Ability name:** Dark Matter
- **Ability (locked):** When you Use a non-Shrouded item, I Shroud and shuffle 2 of your items until I am Defeated.
- **Rulings (locked):** Trigger is **non-Shrouded** Use only (shrouded reveal-then-use does not re-trigger). Shroud = thick black haze obscures art/bg/effects; shrouded items shoved to end of hotbar and treated as curses. Click reveals then uses immediately if playable; Unplayable → reveal and discard with no effect. On Phantom Defeat, all shrouded items unshroud and resort into their sections.
- **Combat:** Stub `flags.dev` — Shroud VFX + hotbar haze is UI/combat later. Document gap.
- **Art:** still `phantom/LOCKED.png`; facing `phantom/facing_LOCKED.png` (64×64); idle = facing plate duplicated to f0–f3 (deferred gens — note in PR)

### 4. `collector` — NEW monster, Tier 3
- **Name:** Collector
- **Stats (locked):** 12 HP / 6 ATK (over vs T3 vanilla 20.5)
- **Pool (locked):** **5**
- **Ability name:** New Specimen
- **Ability (locked):** When you Defeat any other enemy, I Bag it for you. When you Discard an item without Using it, I lose 2 HP.
- **Rulings (locked):** Bag any **other** defeated enemy at **pre-lethal HP** (Bag of Holding–style into hotbar); Defeat still resolves; **never Bags self**. Discard without Use (Decay, Spider Queen eggs, over-capacity, etc.) → Collector −2 HP each. Using an item is not a harming Discard.
- **Combat:** Stub `flags.dev` if Bag-on-Defeat compose is unsafe; peer Bag of Holding pattern. Document gap.
- **Art:** still `collector/LOCKED.png`; facing `collector/facing_LOCKED.png` (64×64); idle = facing plate duplicated to f0–f3 (deferred gens — note in PR)

## Art wiring
- Monster stills → tip peer path (match `poison_frog` / `goblin` / `glass_asp` / `imp`)
- Facing idle → `assets/dungeon/anim/facing/{id}_facing_idle_f{0-3}.png` (or tip exact naming)
- Wire ids into MONSTER_PNG / dungeon_art.gd per `.cursor/rules/art-handoff.mdc`
- Design notes copy under `design/handoff/monster4-2026-11-06/`
- Attach LOCKED-CONTACT.png + LOCKED-FACING-CONTACT.png to PR
- Nearest-neighbor filter on all plates

## Do NOT
- Change other catalog numbers / silent nerfs
- Edit `data/player-copy.json` (Jam owns copy)
- Implement half-broken combat — stub with `flags.dev` and list exact gaps in PR body
- Wait on F5 / Affine / idle regen for phantom/collector

## Verify
- Tip smoke / Godot headless if the repo has that check
- PR body: card table, art sources (still/facing/idle), combat stubs, huntsman pool choice, phantom/collector idle-dupe note
