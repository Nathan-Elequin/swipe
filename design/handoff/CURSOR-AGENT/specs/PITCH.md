# Spinheritance — Animation Pitch (paper fight edition)

For Pixel → Nathan. Written from the data (`data/catalog.json`, `data/player-copy.json`, `data/runtime.json`) and the combat flow in `scripts/main.gd` (`_on_spin`, `_on_done`, `_apply_resolve_hits`, `_owner_attack`), `boss_wheel.gd`, `item_card.gd`, `draft_gate.gd`, `dungeon_deck.gd`, `combat_stage.gd`. No art files were opened.

**Names.** `player-copy.json` has no item or monster rows. Player-facing names, abilities, explainers and call names (the words on the ability-slash banner, e.g. *Bloodlust*) live in `catalog.json`, so this doc uses them exactly as they appear there: **Bloody Wraps** (`bloody_gauntlets`), **The Boot** (`da_boot`), **Great Axe** (`double_axe`), **Chain** (`iron_chain`), **Paci-Fist** (`last_match`), **Scythe** (`measuring_tape`), **Chaos Stone** (`mute_stone`), **Right Bracer** (`bracers`), **Damsel In Distress** (`two_headed_serpent`), **Twins** (`hollow`). Rarity words are only **Weak / Tough / Deadly** (`tier.1/2/3.name`). Where an idea needs new words, it's marked **⚑Jam**.

**Legend.**
- **Type:** **PL** = PixelLab frames. **TW** = Godot Tween (move/scale/flash/colour). **SH** = shader. **PT** = particles.
- **Sizes:** 16px base at 4x. Items in motion are 24px. The hotbar icon sits in a 48×48 on-screen box on a 118×120 card (`item_card.gd`). Monsters are 32/48/64px; I've assumed Weak/Tough/Deadly map to 32/48/64, see Q7.
- **Priority:** **must** / **nice** / **maybe**.

---

## 0. Paper fight: one real turn

**Setup.** HP 4/6 with 2 Poison (from an earlier **Ale Flagon**). The wheel has **Commander** (Deadly), **Kobold Trapper** (Tough), **Lich**, **Plague Doctor** and **Hornet Swarm**. The hand is **Sai** (2), **Marble** (2), **Net** and **Throwing Knife**.

| Step | What the code does | Where the player loses the thread |
|---|---|---|
| 1. Click **Spin** | `wheel_view.spin_to` lands on **Kobold Trapper**. Its ATK shows 4: base 2 plus 2 from **Commander** next door. | **L1:** Why is it 4 and not 2? The +2 comes from Commander's *War Cry*, and nothing ties it to the slice it came from. → SS2, M02 |
| 2. On-spin cascade | `_on_spin` runs about 25 checks in a fixed order: Basilisk, Grief Jar, Cursed Scroll, Gargoyle/Hydra, Death Bell, Mouse, Hex, monster poison, Plague, **player poison**, Berserker, **Marbles +1**, Rust, Queen eggs, Cultist, Juggernaut, Magicat, Frog, Harpy, Leech, Cleric, Fairy, then the Cube/Merchant/Hired Hand/Worm prompts. | **L2:** The 2 poison hearts punch and vanish in the middle of the slay-in, with no "this is poison" moment. **L3:** **Marble** quietly becomes 3 (`_step_marbles`), with no event. **L4:** When several triggers fire, the ability-slash banners queue one after another with no sense of order or source. → SS3, S01, E07 |
| 3. Read the **Take 4** button | `_incoming_hit()` → "Take {n}" | **L5:** "Take 4" is the only intent signal. It doesn't say *how many swings*, and it doesn't warn that each item you use **adds one more swing** (Trap Card). → SS1, M10 |
| 4. Use **Net** (−2) | Kobold's ATK drops to 2, but swings go to 1+1. **Sai** flips 2→4 (`_flip_alt_sais`, number dissolve only). | **L6:** The player believes they just made the hit smaller, but the button now shows the same total because there's an extra swing. Sai's change is a 0.2s number fade they won't notice. → M10, U07, E01 |
| 5. Use **Marble** | Rolls ATK or BLK at random (now 3). | **L7:** The player can't tell which way it rolled until the number lands on the hub or the slice. → E07 |
| 6. Use **Sai** (4) | Kobold HP 6 → −1 → slay. Sai flips back to 2. | Good beat, but there's no "you dodged 3 swings" payoff. |
| 7. Slay → slice collapses | `collapse_slice`, neighbors close up | **L8:** Commander now borders a *different* monster, which silently gains +2 ATK. **Lich**'s +1 HP moves the same way. → SS2, M02, M03 |

Every item below fixes one of these blind spots, or one like it.

---

## Shared systems (build these first; they cover most of the list)

| ID | System | Covers | Type · size | Pri |
|---|---|---|---|---|
| **SS1** | **Intent plate** above the facing monster on the combat stage: one 16px icon per swing (fist), stacked as pips (×1…×N), plus modifier icons: flame = ignores Block, drop = applies Poison, footprints = will Flee, crossed arrows = redirect, ? = random. Pips are added or removed live as you use items. | Hornet, Kobold, Shambling Mound, Shark, Harpy, Dragon, Martyr, Druid, Damsel, Shuriken flee, Net | TW + 8 PL icons, 16px, 1–2f each | must |
| **SS2** | **Aura threads** on the wheel: a coloured thread from a buff source to each neighbor it affects (red = +ATK, green = +HP, purple = Poison, grey arrow = "takes my hits"). When slices collapse, the threads snap and re-tie, so moved buffs are visible. | Commander, Lich, Plague Doctor, Wraith, Bodyguard, Prism, Cowardly King, Wick, Leech League | SH/Line2D + TW, no frames | must |
| **SS3** | **Spin cascade ticker.** After the wheel lands, small stamp tokens drop in a row under the hub, one for each trigger that will fire, in `_on_spin` order. Each one lights up as its ability slash plays and then fades. It gives the player a running order and a skip point. | Every on-spin effect (about 25) | TW, reuse 16px icons from SS1/S-group | must |
| **SS4** | **Status tick pop:** one style for every status that resolves. The badge swells, the icon bursts (4 frames), and the number flies to its target (a heart or a slice HP stat), then the badge empties with a "glug". | Poison (both sides), Hex, Toll, Rust, Petrify end, Grief Jar, Cursed Scroll | PL 16px burst 4f + TW | must |
| **SS5** | **Countdown ring:** pips around an icon or card corner, one per remaining Spin or Use. A pip cracks off on each tick and the last one flashes before it fires. | Hex (6), Toll (6), Rust (3), Basilisk petrify (3), Recycler (5 discards), Counting Beads (4 steps) | TW/SH, no frames | must |
| **SS6** | **Item flourish vocabulary:** *twirl* = value flip, *split/merge* = count change, *swirl + tint* = random roll, *crack* = consumed, *glint* = Keep, *grey stone* = petrified. Every item in E-group uses only these six. | All hotbar state changes | PL per item 24px 4–8f; generic TW fallbacks | must |
| **SS7** | **Bleed pulse:** every HP-loss event sends one red ring out from the hub hearts. Every listener visibly "catches" it (a small hop and red tick) before its number changes. Teaches what counts as one event (Spiked Flail ruling). | Spiked Flail, Breastplate, Vampire, Ogre, Pacemaker, Blood Chalice, Druid, Dire Wolf | TW + PT ring | must |
| **SS8** | **Courier lane:** anything that moves between the hand and the wheel (Eggs, Blood Pacts, Shields, Toll, Rust, Cube feeding, Cleric taking, Merchant upgrades) uses the existing `_fly_courier`/`_walk_courier`, but every courier carries the item's 24px icon and leaves a dust trail. | M-group gain/steal effects | TW + PT, reuses icons | must |
| **SS9** | **Rarity shimmer** in Weak/Tough/Deadly colours (copper `d4894e` / silver `f4f7fb` / gold `ffe6a8`, already in `_tier_shine`). One diagonal glint shader, with speed and frequency rising by rarity. | Draft gate, hotbar, Dungeon Deck, wheel plates | SH | must |
| **SS10** | **Keep vs Spent sort** at end of fight: kept items do a glint-hop back into place, spent ones crack and drop. Today the toss happens without a "why". | Throwing Knife, Breastplate, Lantern, Lucky Nickel, Chain, Shuriken, Jar O' Grease, Zombie | TW | nice |

---

## 1. Monster intent and abilities

Trigger codes: **Spin** = on landing, **Use** = after an item use, **Done** = on resolve, **Def** = on defeat, **Aura** = always on the wheel.

| ID | Monster (`id`) · call name | Trigger | Can't tell today | Animation | Type · size · frames | Pri |
|---|---|---|---|---|---|---|
| M01 | **Hornet Swarm** (`hornet_swarm`) · Double Strike | Done | Two swings; Block is spent on the first (ruling `double_hit_spends_block`). | Intent shows 2 fist pips. On resolve the swarm splits into two clumps that hit one after the other, and the Block badge visibly drains on the first. | PL 32px swarm-split 6f + TW | must |
| M02 | **Commander** (`commander`) · War Cry | Aura / Def | Where neighbors' +2 ATK comes from; that the first defeat makes it Flee instead of die. | SS2 red threads; a horn-blast ring on spin-in. On first defeat it drops its banner and scurries (footprints icon), then stays on the wheel with a torn-flag mark. | PL 64px horn 4f, flee 6f + SH | must |
| M03 | **Lich** (`lich`) · Siphon | Aura | Neighbors' +1 HP. | Green wisps drift from the Lich into neighbor HP stats on a slow loop (SS2). | PT + TW | must |
| M04 | **Plague Doctor** (`plague_doctor`) · Always Plague | Aura / Spin | Neighbors *Always* have 2 Poison, then heal 2 on Spin; net effects cancel invisibly. | Purple drop badges locked on neighbors with a tiny padlock (the "Always" keyword). On Spin, the doctor's censer swings and green +2 floats to each neighbor. | PL 32px censer 6f + SS4 | must |
| M05 | **Wraith** (`wraith`) · Neighbor's Wrath | Aura | Its ATK copies the *higher* neighbor. | A ghost thread to the stronger neighbor's sword stat, whose number "echoes" across. | SH + TW | nice |
| M06 | **Skeleton** (`skeleton`) · HP Echo | Spin | Its HP equals the last enemy you faced. | On landing, a bone-ghost of the previous monster's HP number flies from where it was and clatters into the Skeleton's heart. | TW | nice |
| M07 | **Dire Wolf** (`dire_wolf`) · Kill Shot | Aura | ATK always equals *your* HP. | A thin red tether from the hub hearts to the wolf's sword. When you bleed (SS7), the wolf's number drops at the same moment. | SH + TW | must |
| M08 | **Bandit** (`bandit`) · Hoarder | Spin | ATK = items you hold. | The Bandit's eyes dart along the hotbar; each card gives a tiny coin tick into its ATK. | PL 32px glance 4f + TW | nice |
| M09 | **Slime Boss** (`slime_boss`) · Body Slam | Use | ATK equals its HP, so damage also shrinks the hit. | The slime squashes smaller on each hit, and the ATK and HP numbers shrink together, linked by one bracket. | PL 64px squash 3 sizes × 4f | must |
| M10 | **Kobold Trapper** (`kobold_trapper`) · Trap Card | Use | Every item used adds a swing. | Each use snaps a trap pip onto the intent plate (SS1) with a "clack"; hovering an item previews a ghost pip. | TW + PL 16px trap 3f | must |
| M11 | **Harpy** (`harpy`) · Impatient | Spin / Use | It swings on landing *and* after every item. | A feather-dive swoop after each use; the intent plate shows a "per item" loop icon. | PL 48px dive 6f | must |
| M12 | **Shambling Mound** (`shambling_mound`) · Self Deconstruct | Done | It swings once per HP and loses 1 HP each swing. | Intent pips equal its HP; each swing sloughs a moss clump off and removes one pip. | PL 32px slough 5f | must |
| M13 | **Shark** (`shark`) · Blood Thresh | Done | It attacks *until you lose HP*. | A fin circles the hub and keeps biting at Block; the first red drop ends the loop with a satisfied dive. | PL 48px bite 5f + TW circle | must |
| M14 | **Dragon** (`dragon`) · Firebreather | Done | Its ATK ignores Block. | A flame icon on the plate; on the hit, fire washes *through* the Block badge, which chars and stays intact. | PL 64px breath 8f + PT | must |
| M15 | **Damsel In Distress** (`two_headed_serpent`) · Guarded by Monsters | Done | Neighbors attack you (Left, then Right), then it heals you 3. | Two arrows draw from the neighbors with numbers 1 and 2, they lunge in that order, then a pink heart floats over: +3. | TW + reuse lunges | must |
| M16 | **Martyr** (`martyr`) · Noble Death | Done | When it attacks it dies, and neighbors gain its HP. | Intent: a skull + split arrows. It kneels, crumbles, and its HP number splits in two to the neighbors. | PL 32px kneel/crumble 6f | must |
| M17 | **Druid** (`druid`) · Cultivator | Done | It heals you double what it took, after the death check. | After the hit, vines curl over the hearts and regrow 2×. | PL 48px staff 4f + PT leaves | nice |
| M18 | **Needleback** (`needleback`) · Spiky | Use | It hits you for 2 every time it takes ATK damage. | Quills fire back along the attack line toward the hub on every hit. | PT + TW | must |
| M19 | **Gelatinous Cube** (`gelatinous_cube`) · Devour Item | Spin | You must feed it one of two items. Feeding is *not* an item use. | The two offered cards wobble inside a green jelly frame; the chosen one sinks into the cube with a glop and floats inside it as a silhouette. No "use" flash, so it reads as a different event from using. | PL 48px gulp 6f + SH jelly | must |
| M20 | **Gargoyle** (`gargoyle`) · Petrify | Spin | Which item got petrified and why (your highest-ATK item). | A stone gaze beam to the highest-ATK card, which greys from the beam point (S03). | PL 48px eyes-glow 4f + SH | must |
| M21 | **Hydra** (`hydra`) · Even Killer | Spin | It petrifies every even ATK/BLK item and gains +2 ATK per item. | One head per petrified card snaps out; each petrify pops +2 into its sword. | PL 64px head-snap 4f + TW | must |
| M22 | **Basilisk** (`basilisk`) · Petrifying Gaze | Spin (first) | It flees on first spin and petrifies every other item for 3 Spins. | Glare sweeps the hotbar, petrifying the 2nd/4th/… cards with SS5 3-pip rings, then it slithers off the slice (footprints). | PL 48px glare 4f, slither 6f | must |
| M23 | **Mimic** (`mimic`) · Treasure | Def | You get an item if it goes down before swinging. | On a pre-swing kill, the lid pops open and an item flies into the hand; if it already swung, the lid stays shut. | PL 48px open 6f | nice |
| M24 | **Clockwork Knight** (`clockwork_knight`) · Disassemble | Def (if alive) | If it lives, it leaves **two Tough monsters**. | Gears burst, and two Tough-silver cards deal out of the Dungeon Deck into the slot. ⚑Jam: explainer says "Two **Tier** 2 if I live". | PL 48px gear-burst 6f + reuse deck draw | must |
| M25 | **Twins** (`hollow`) · Doubly Troubled | Use | Even ATK/BLK happens twice against it. | Even numbers split into two ghost copies that land in sequence. | TW | must |
| M26 | **Anvil** (`anvil`) · Tough Blood | Use | It can lose at most 1 HP per source. | Big damage numbers clang off and only "1" falls through; sparks. | PT + TW | must |
| M27 | **Bodyguard** (`bodyguard`) · Protector | Use | It takes neighbors' ATK damage instead. | A shield-dash: the guard sprite leaps between the attack and the neighbor. | PL 32px dash 4f + TW | must |
| M28 | **Prism** (`prism`) · Refract Damage | Use | ATK aimed at it splits to both neighbors. | The attack line hits the crystal and refracts into two rainbow beams. | SH + PT | must |
| M29 | **Cowardly King** (`cowardly_king`) · Guards! | Use / Done | The right neighbor takes his hits; after attacking he Flees instead of being defeated. | He ducks and points; the hit re-routes clockwise. After his swing he hops off with his crown wobbling. | PL 48px duck 4f, flee 6f | must |
| M30 | **Wick** (`wick`) · Death Toll | Def (neighbor) | It loses 2 HP whenever a neighbor is defeated. | The flame gutters and drips 2 wax HP. | PL 32px gutter 4f | nice |
| M31 | **Vampire** (`vampire`) · Bloodlust | Bleed | +1/+1 *for every copy on the wheel* each time you lose HP. | SS7 ring reaches each Vampire; bat wisps feed from the hearts and +1/+1 pops. | PT + TW | must |
| M32 | **Ogre** (`ogre`) · Empath | Bleed | It loses HP equal to what you lose. | A mirrored red drop falls from the hub hearts to the Ogre's HP stat at the same moment. | TW | must |
| M33 | **Berserker** (`berserker`) · Outburst | Spin | A 50% roll for +4 ATK. | Grandpa's coin flips over its head (heads = rage fire `set_rage_fire`, tails = shrug). | PL 16px coin 6f + existing rage fire | must |
| M34 | **Leech League** (`leech_league`) · Blood Rise | Spin | It heals the lowest monster until it ties another. | Leeches inch between slices; the target's heart fills tick by tick until it matches (both numbers glow). | PL 32px inch 4f + SS2 | nice |
| M35 | **Spider Queen** (`spider_queen`) · Egg Layer | Spin | You gain an egg every Spin; landing on her devours them for +2/+2 each. | Egg courier (SS8) to the hand every Spin. On her landing, eggs crawl back and she swells per egg. | PL 64px swell 4f, 16px egg wobble 4f | must |
| M36 | **Cultist** (`cultist`) · Blood Pact | Spin (self or neighbor) | Why you got a pact when you didn't land on it. | A red rune thread from the cultist to the landed neighbor, then the pact card couriers in. | PT + SS8 | must |
| M37 | **Death Bell** (`death_bell`) · Toll Of The Dead | Spawn / Spin / Def | Toll on spawn, loses 2 HP per Spin, discards an item when defeated. | It swings and *dongs* every Spin (2 HP cracks off); on defeat a sound-ring knocks one card out of the hotbar. | PL 64px swing 6f, crack 4f | must |
| M38 | **Phoenix Egg** / **Phoenix** (`phoenix_egg`, `phoenix`) · Hatch / Rebirth | Def | It doesn't die, it changes form. | Shell cracks into a fire-burst Phoenix; the Phoenix re-ashes into an egg if killed before swinging. | PL 48px hatch 8f, ash 6f | must |
| M39 | **Amalgam** (`amalgam`) · Adaptation | Use | HP and ATK double after every item. | It splits and re-merges into a bigger blob; numbers ×2 with a stretch. | PL 64px split-merge 6f | must |
| M40 | **Fairy** (`fairy`) · Fairy Dust | Spin | It heals you *and* its neighbors 2. | One sparkle burst that rains on the hub and both neighbors at once. | PT + PL 32px flutter 4f | nice |
| M41 | **Eel** (`eel`) · Conductive | Use | It takes ATK damage equal to Block you gain. | Gaining Block arcs lightning from the Block badge to the Eel. | PT + SH | must |
| M42 | **Mouse** (`mouse`) · Scurry | Spin | It loses 2 HP and Flees if your HP is higher. | Compare beat: the mouse looks at your hearts, squeaks, drops 2 and runs. | PL 32px scurry 6f | nice |
| M43 | **Magicat** (`magicat`) · Cat's Eye | Spin | Two items become Marbles with the same number. | Wand flick, and the cards morph in place into cat's-eye marbles that keep the number (`play_transform` + new sprite). | PL 32px flick 4f, 24px marble-morph 6f | must |
| M44 | **Poison Frog** (`poison_frog`) · Toxic Skin | Spin / hit | Landing on it *or hitting it* gives you 2 Poison. | Tongue-flick puts a drop on the hub; hitting it squirts back. | PL 32px flick 4f + SS4 | must |
| M45 | **Rust Bucket** (`rust_bucket`) · Rust | Enter dungeon | Rust is gained when it enters, not when it's spun. | On seating, orange flakes blow from the bucket into the hand as a Rust card. | PT + SS8 | nice |
| M46 | **Cleric** (`cleric`) · Health Insurance | Spin | It heals 3 and takes your worst item. | Heal glow, then a gloved hand plucks the weakest card (SS8 in reverse). | PL 48px pluck 4f | must |
| M47 | **Merchant** (`merchant`) · Fair Trade | Spin | Which item was upgraded. | A scale tips; the chosen card flips copper→silver or silver→gold (SS9). | TW + SH | nice |
| M48 | **Juggernaut** (`juggernaut`) · Blockhead | Spin | You gained a Shield. | A Shield card thunks into the hand. | SS8 | nice |
| M49 | **Hired Hand** (`hired_hand`) · Bribe | Discard | It attacks a neighbor and flees. | A coin toss to the merc, who turns, swings at a neighbor, and walks off. | PL 32px swing-turn 6f | nice |
| M50 | **Almighty Worm** (`almighty_worm`) · Hunger Pains | Spin | Each sacrificed item takes −3/−3. | Discarded cards fall into the maw; each bite shrinks it a size step. | PL 64px gulp 6f | must |
| M51 | **Bushido** (`bushido`) · Patient Disarm | Use (2nd) | Your second item does nothing. | The samurai half-draws on your first use; on the second, a slash cuts the card's effect in mid-air. | PL 48px draw 4f, slash 4f | must |
| M52 | **Zombie** (`zombie`) · Decay | Use | No Keep while facing it. | Kept items rot (green tint) and crumble instead of glinting home. | SH + TW | must |
| M53 | **Triclops** (`triclops`) | Def | 3 HP = defeated; anything else = −2 HP and Flee. | A "3" eye-count shows on the intent plate; at exactly 3 the three eyes close. Otherwise it blinks, drops 2 and runs. ⚑Jam: no call name in data. | PL 48px blink 4f | nice |
| M54 | **Goblin** (`goblin`) · Evasive | Use | Immune to ATK damage. | ATK numbers whoosh past as it sidesteps (existing "Immune" text). | PL 32px sidestep 3f | must |
| M55 | **Golem / Wizard** (`golem`, `wizard`) | Done | Plain. | No special; use them as tuning references for SS1 and the Bosses group. | — | maybe |

---

## 2. Status effects

| ID | Status (source) | Trigger | Can't tell today | Animation | Type · size · frames | Pri |
|---|---|---|---|---|---|---|
| S01 | **Poison on you** (Ale Flagon, Poison Frog) | Next Spin | It's a lump sum that fires on the *next Spin* and then clears. It isn't damage per turn. Doomed hearts are tinted, but the fire moment gets lost in the cascade. | Its own SS3 token; the drop badge on the hub fills, and on the tick it bursts and the doomed hearts drip away one by one. | SS4 + PL 16px drip 4f | must |
| S02 | **Poison on monsters** (Miasma, Poison Flask, Plague Doctor) | When *that monster* is spun | A pending lump that may not fire for many spins. | The badge drips slowly while it waits; when you land on that monster, the drop cracks over the portrait and the HP drains. | SS4 + SH | must |
| S03 | **Petrify** (Gargoyle, Hydra: until next Spin) | Spin → next Spin | Which card and for how long. | The card turns to stone from the top down with cracks; on the next Spin the stone shatters off. | SH + PL 24px shatter 5f | must |
| S04 | **Petrify, 3 Spins** (Basilisk) | Spin ×3 | Countdown. | Same as S03 plus an SS5 3-pip ring. | SH + SS5 | must |
| S05 | **Silenced** (Quiet Bell) | Use | The ability is gone; formulas fall back to plain ATK/HP. | A bell ring makes the call-name plate go grey and strikes it through; any SS2 threads from it fade. ⚑Jam: label (Quiet Bell explainer says "Silence"). | TW + SH | must |
| S06 | **Hex** (Hex) | Every Spin | Which monster is hexed; it fires on Spin 0. | A skull mark sits on the target slice with an SS5 6-pip ring; at 0 the skull bites. | SS5 + PL 16px skull 4f | must |
| S07 | **Toll** (Death Bell token) | Every Use | You die at 0. | Each use rings the bell card and cracks one pip off its 6; the last pips pulse red. | SS5 + PL 24px bell 4f | must |
| S08 | **Rust** (Rust Bucket token) | 3 Spins | Your Block is ignored. | Rust creeps over the hub Block badge; on enemy swings Block visibly does nothing (an orange ✕). | SH + SS5 | must |
| S09 | **Spider Egg** in hand | Spin Queen | Eggs feed the Queen. | Eggs wobble harder the closer the wheel pointer passes the Queen's slice. | TW | nice |
| S10 | **Blood Pact** in hand | Use | It costs both sides 2 HP. | A blood line pulls between the hub and the faced monster, and both drip 2. | TW + PT | nice |
| S11 | **Fled** (Commander, Shuriken, Mouse, Hired Hand, Triclops, Phoenix…) | Flee | That they are still on the wheel. | The existing `set_fled_mark` becomes a footprint icon trail on the slice. | PL 16px footprints 3f | must |
| S12 | **Bleed** (concept shared by many items) | HP loss | What counts as "one time you lose HP". | SS7. | — | must |
| S13 | **Polymorphed** (Polymorph) | Use | That the monster is now a copy of a neighbor. | Sheep-puff, then the neighbor's sprite pops in with a little wool still on it. | PL 32px puff 5f | nice |
| S14 | **Armed: Danger Magnet** | Next Spin | Which way it's armed (HIGH/LOW/Off). | The magnet icon hangs over the wheel pointer and points at the highest or lowest slice; on Spin the pointer is pulled. | TW | must |
| S15 | **Retained Block** (Stone Wall) | End of fight → next Spin | That leftover Block carries over. | The Block badge stays stone-coloured through the slay and settles back on the next fight. | TW + SH | nice |

---

## 3. Utility items (effect isn't plain ATK/BLK)

| ID | Item (`id`) | Trigger | Can't tell today | Animation | Type · size · frames | Pri |
|---|---|---|---|---|---|---|
| U01 | **Grappling Hook** (`grappling_hook`) | Use | A neighbor is swapped into the fight, then you draw 1. | The hook flies on a rope from the hub to the neighbor slice and yanks; the two portraits swap over each other; a random item drops in. | PL 24px hook-throw 6f + TW rope | must |
| U02 | **Smoke Bomb** (`smoke_bomb`, status todo) | Use | It spins again and gives a random item. | A puff covers the stage, the wheel re-spins under the smoke, and an item pops out of the cloud. | PT + PL 24px puff 5f | must |
| U03 | **Quiet Bell** (`quiet_bell`) | Use | → S05 | The bell rings with visible sound rings that hit the slice. | PL 24px ring 4f | must |
| U04 | **Danger Magnet** (`danger_magnet`) | Choose | → S14 | The card flips its poles as you choose HIGH or LOW; Off goes dull. | TW | must |
| U05 | **Miasma** (`miasma`) | Use | Poison all = lowest HP; *which* number was used. | A fog rolls from the lowest-HP slice (that number glows) around the wheel, leaving drops. | PT + SS4 | must |
| U06 | **Bag Of Marbles** (`bag_of_marbles`) | Use | It fills the hand with 10 Marbles. | The bag tips and marbles roll into every empty slot with a staggered clink. | PL 24px tip 4f + TW roll | must |
| U07 | **Net** (`net`) | Choose | −1/−2/−3, and the intent change. | The net drapes over the portrait; the ATK number is squeezed down by the chosen amount. | PL 48px drape 5f + TW | must |
| U08 | **Pocketwatch** (`pocketwatch`) | Use | The selected enemy attacks the one you face. | Hypnotize swirl (`play_hypnotize` exists); the selected portrait lunges across the wheel. | TW reuse lunge | must |
| U09 | **Echo Bell** (`echo_bell`) | Use (any item) | It becomes the last item used. | A ghost of the last-used card rings into the bell and takes its shape (the echo mark exists). | SH ghost + TW | must |
| U10 | **Chaos Stone** (`mute_stone`) | Use | Which 2 items swapped. | The two cards orbit each other and trade places. | TW | nice |
| U11 | **Jar O' Grease** (`jar_o_grease`) | Use | A random swap plus Keep. | One card slides out greased and a new one slides in; the jar glints (Keep). | TW + SS10 | nice |
| U12 | **Catapult** (`catapult`) | Use | Eject = bottom of the **Dungeon Deck**. | The monster is flung off the slice in an arc onto the deck and tucks under the stack. | PL 24px arm 4f + TW arc + deck | must |
| U13 | **Bag of Holding** (`bag_of_holding`) | Use | The enemy goes in the bag. | The bag opens, the portrait shrinks and gets sucked in, and the bag ties. | PL 24px gulp 5f | must |
| U14 | **Polymorph** (`polymorph`) | Use | → S13 | Sheep scroll unrolls. | PL 24px unroll 4f | nice |
| U15 | **Sling** (`sling`) | Use → next attack | Your next attack can target any monster. | The sling spins over the hotbar, and the next ATK card gets a loaded stone mark until used. ⚑Jam: tooltip wording for the loaded state if needed. | PL 24px whirl 4f + TW | must |
| U16 | **Signpost** (`signpost`) | Use | Block 7, then the chosen neighbor attacks you. | The sign spins and points at the chosen neighbor, who lunges at the hub. | PL 24px spin 4f | must |
| U17 | **Recycler** (`recycler`) | Discard | Every 5th discard copies. | An SS5 5-pip ring; on the 5th, the discarded card loops through the recycle arrows back into the hand. | SS5 + TW | must |
| U18 | **Double-Buckler** (`double_buckler`) | Next even hit | It's armed and waiting. | Two bucklers idle-circle; on an even hit they clap together and halve the number. | PL 24px clap 4f | must |
| U19 | **Healing Potion** (`healing_potion`, todo) | Lethal | It saves you. | On a lethal hit, time slows, the cork pops, and hearts refill 3. | PL 24px pop 5f + TW slowmo | must |
| U20 | **Pacemaker** (`pacemaker`) | Exact-2 loss | Exactly 2 triggers it. | Steady ECG blink; on an exact-2 loss it spikes and +1. | SH ECG + TW | nice |
| U21 | **Napalm** (`napalm`) | Use | You, the enemy and its neighbors are all set to 1. | A fire wave from the hub across three slices; every heart number burns down to 1. | PT + PL 24px flask 4f | must |
| U22 | **The Boot / Sledgehammer / Scythe / Paci-Fist** (`da_boot`, `sledgehammer`, `measuring_tape`, `last_match`) | Hover / Use | *Why* it can or can't defeat: HP < yours, ATK ≥ 6, HP = 2× yours, no ATK items. | On hover, the two compared numbers light up with a < / ≥ / = glyph between them (green or red). On Use, a signature kill: boot-punt, hammer-slam, scythe-sweep, a pacifist bow. | TW glyph + PL 24px 4–6f each | must |
| U23 | **Fangs** (`fangs`) | Done | It lets them hit, then defeats them and heals their HP. | Fangs wait open through the hit, then bite, and the monster's HP flows into your hearts. | PL 24px bite 4f + TW | must |
| U24 | **Poison Flask** (`poison_flask`, todo) | Use | Mark a neighbor: −5 on its spin. | The flask lobs to the neighbor and leaves a green "5" drop (S02). | TW + SS4 | must |
| U25 | **Hex** (`hex`) | Draft/Hold | → S06 | — | — | must |

---

## 4. Expression for direct items (hotbar state changes)

| ID | Item (`id`) | State change | Can't tell today | Animation | Type · size · frames | Pri |
|---|---|---|---|---|---|---|
| E01 | **Sai** (`sai`) | 2 → 4 → 2 after *any* item use | Only a 0.2s number dissolve. | **Nathan's idea:** at 2 it's one sai; when it flips to 4 the sai **twirls and splits into a crossed pair**; when it flips back, the pair **twirls and merges** into one, ready for the 2-hit. (Data is 2↔4, not 1↔2; see Q2.) | PL 24px twirl-split 8f + reverse | must |
| E02 | **Marble** (`marble`) | Random ATK or BLK at use; +1 per Spin | The roll and the growth are invisible. | **Nathan's idea:** on use it **swirls** and settles **red = Attack** or **blue = Block**. On each Spin it pulses one size larger with a +1 tick. | PL 24px swirl 6f + 2 tint ends; SH tint | must |
| E03 | **Throwing Knife** (`throwing_knife`) | Throw (3, discard) vs Nick (1, keep) | Which you picked. | Throw: the knife spins off the card for good. Nick: it grazes and boomerangs back with a glint. | PL 24px spin 6f; TW return | must |
| E04 | **Counting Beads** (`counting_beads`) | 1→2→3→4 cycle | Where you are in the cycle. | Four beads on the card, one sliding across each step (SS5 style). | PL 24px bead slide 4f | must |
| E05 | **Knucklers** (`knucklers`) | Live: 8 − items in hand | It goes up as you spend. | Each spent item cracks a knuckle; spikes extend one notch. | PL 24px 5 notches | nice |
| E06 | **Spiked Flail** (`spiked_flail`) | +2 per Bleed | Growth source. | SS7 catch; one more spike grows on the ball. | PL 24px 5 growth states | must |
| E07 | **Marble** (Magicat-made) (`marble`) | Morph | → M43; cat's-eye variant of E02. | — | — | nice |
| E08 | **Ball & Chain** (`ball_and_chain`) | Cancels a Flee, +2 ATK | Silent today apart from a `_play_chain_cancel` banner. | The chain whips out and snags the fleeing slice; the ball thuds and grows. | PL 24px whip 6f | must |
| E09 | **Grief Jar** (`grief_jar`) | Each Spin: −1 HP, +2 BLK | Why you bled on spin. | A tear runs from the hub into the jar; the fill line rises. | PL 24px 4 fill states + TW | must |
| E10 | **Cursed Scroll** (`cursed_scroll`) | Heal 6, then −1 per Spin | Same as above. | The scroll curls darker each Spin as it sips 1 HP. | SH + TW | nice |
| E11 | **Medallion / Bloody Wraps / Helmet** (`medallion`, `bloody_gauntlets`, `helmet`) | Live on HP change | Which HP drives them. | The medallion's gem dims with your hearts; the wraps redden; the helmet visor glances at the lower bar. | SH tint + TW | nice |
| E12 | **Right Bracer / Left Bracer** (`bracers`, `left_bracer`) | Neighbor ATK | Which side. | An arrow on the bracer points at the right or left slice, and that sword number ghosts onto the card. | TW | must |
| E13 | **Spiked Shield / Mirror Shard / Chain** (`spiked_shield`, `mirror_shard`, `iron_chain`) | Copies another number | The source. | A ghost number flies from the source: the highest ATK card, the last Block gained, or the Block badge. | TW | nice |
| E14 | **Grimoire** (`grimoire`) | Last enemy's ATK | The source. | Pages flip to a sketch of the last monster's sword number. | PL 24px flip 4f | nice |
| E15 | **Chakram** (`chakram`) | ATK 3 if no ATK items / BLK 3 if no BLK items | Which mode is live. | The blade spins red edge-out (attack) or blue flat-face (block), matching the Marble colour code. | PL 24px spin 6f ×2 tints | must |
| E16 | **Breastplate / Lantern / Lucky Nickel** (`breastplate`, `lantern`, `lucky_nickel`) | Keep conditions (bled / still hurt / Block even) | Whether it will come back. | A small Keep glint shows while the condition is true; the nickel flips heads/tails on even/odd. | SS10 + PL 16px coin 6f | must |
| E17 | **Shuriken** (`shuriken`) | 2 ATK; if alive, Flee + Keep | The flee. | The star sticks, and the hero vanishes in leaves; the star returns. | PL 24px 6f | nice |
| E18 | **Arrow Head** (`arrow_head`) | 6 ATK, lose 2 HP | The self-cost. | The barb nicks the hub hearts on the release. | TW | nice |
| E19 | **Crossbow / Longbow / Great Axe** (`crossbow`, `longbow`, `double_axe`) | Neighbor / opposite / cleave | The target geometry. | Hover draws the shot line: to a neighbor, straight across the wheel (dashed if the count is odd = unusable), or a cleave arc over three slices. | TW lines | must |
| E20 | **Victory Flask** (`victory_flask`) | 1 + Defeats | Its growth. | One bubble per defeat floats in. | PL 24px 4 fill states | maybe |
| E21 | **Blood Chalice** (`blood_chalice`) | Heal = last loss | The source. | It catches the SS7 drop and fills to that line. | TW | nice |
| E22 | **Stone Wall** (`stone_wall`) | Block 10, leftover kept | → S15 | Bricks stack up as the Block badge. | PL 24px stack 5f | nice |

---

## 5. Draft gate and hotbar

| ID | Element | Trigger | Can't tell today | Animation | Type · size · frames | Pri |
|---|---|---|---|---|---|---|
| D01 | **Gate idle** (`draft_gate.gd` mystery door) | Present | How dangerous the hidden monster is. | The door frame breathes in its rarity colour (SS9), and the silhouette behind it sways in proportion to Weak/Tough/Deadly. Copy uses "Guarded by a {tier} monster", which resolves to Weak/Tough/Deadly. | SH + TW | must |
| D02 | **Take → slam** | Take it | — | Polish the existing `play_slam` with dust and a camera kick scaled by rarity (Deadly = big). | PT + TW | must |
| D03 | **Leave it** | Pass | Passes left. | Existing `play_pass`, plus a pass-token clinks off the counter. | TW | nice |
| D04 | **Seat** | Click an alcove | Where it will land. | Empty alcoves pulse; on click the monster walks in (reuse `_walk_courier`) and the slot locks. | TW | must |
| D05 | **Relic flight** | After take | — | The loot card flies to the hotbar with a shimmer trail in rarity colour. | TW + PT | must |
| D06 | **Hotbar rarity shimmer** | Idle | Rarity at a glance. | SS9 at a slow rate; Deadly gets an occasional sparkle. **Never show the word "Tier".** | SH | must |
| D07 | **Ready / usable** | Fighting | Which cards can be used right now. | Usable cards lift 2px with a soft breathe; unusable ones sink and desaturate (replaces the static lock shade). | TW | must |
| D08 | **Charged / armed** | Passive items | That passives are working. | A slow orbiting glint on armed passives (Double-Buckler, Healing Potion, Pacemaker, Danger Magnet, Sling). | SH | must |
| D09 | **Hover preview** | Hover a card | What it will do to the intent. | Ghost changes on the SS1 plate and the Take button number (e.g. Net −2, Kobold +1 pip). | TW | must |
| D10 | **Use → toss** | Use | — | The existing `toss`, plus a short icon-specific flourish first (SS6). | TW | nice |
| D11 | **Item gained** | Any gain | Where it came from. | SS8 origin trail. | — | must |
| D12 | **Dungeon Deck: draw / peek** (`dungeon_deck.gd`) | Challenge | What the next monster is. | The top card flips up on draw (exists); add a rarity-coloured edge flash and a "riffle" when Catapult tucks a card under (U12). | TW | nice |
| D13 | **Wheel spin landing** | Spin | Tension. | The pointer ticks per slice and slows; the landed slice swells and its intent plate drops in (SS1). | TW | must |
| D14 | **Ability-slash queue** | Any trigger | Order. | Hook into SS3: each slash flies from the ticker token. | TW | must |

---

## 6. Bosses (wheel monsters: idle, wind-up, hurt, death)

| ID | What | Trigger | Animation | Type · size · frames | Pri |
|---|---|---|---|---|---|
| B01 | **Idle, every monster** | Facing | Replace the sine bob (`combat_stage._place_sprite`) with a 4f idle loop per monster. | PL 32/48/64 × 4f | nice |
| B02 | **Wind-up** | Done pressed | A 2–3f anticipation before `lunge`, which gives the intent plate a beat to "fire". | PL 3f per monster | must |
| B03 | **Hurt** | Any damage | A 2f recoil plus the existing flash; heavy hits add a 1f squash. | PL 2f + TW | nice |
| B04 | **Death by rarity** | Slay | Weak = poof; Tough = topple + dust; Deadly = shatter + gold sparks + short slowmo. | PL 32/48/64 × 6f, PT | must |
| B05 | **Flee (shared)** | Any Flee | A turn-and-run cycle that leaves the S11 footprints. | PL 4f run per size class (3 sets) | must |
| B06 | **Signature deaths** | Def | Death Bell cracks and falls silent; Slime Boss splats; Phoenix ignites (M38); Clockwork Knight disassembles (M24); Martyr kneels (M16). | PL 6–8f each | nice |
| B07 | **Deadly entrance** | Landing on a Deadly | A screen dim and gold rim on the stage frame for 0.4s (the SFX already pitch-shifts for Deadly). | TW + SH | nice |

---

## Counts

| Group | Pitches |
|---|---|
| Shared systems | 10 |
| Monster intent and abilities | 55 |
| Status effects | 15 |
| Utility items | 25 |
| Expression for direct items | 22 |
| Draft gate and hotbar | 14 |
| Bosses | 7 |
| **Total** | **148** |

## Top 10 to build first
1. **SS1** Intent plate (swing pips + modifiers): fixes L5/L6 for about 15 monsters.
2. **SS3** Spin cascade ticker: fixes L2–L4 (about 25 on-spin effects in a row).
3. **SS2** Aura threads: Commander, Lich and Plague buffs that move silently when slices collapse.
4. **SS4 + S01/S02** Poison tick pop: a delayed lump, not damage over time.
5. **E01** Sai twirl-split / merge.
6. **E02** Marble swirl red/blue.
7. **SS7** Bleed pulse: one rule that teaches eight items and monsters.
8. **U01** Grappling Hook rope-yank swap.
9. **S03/S04/M20–M22** Petrify stone-over with countdown ring.
10. **SS9 + D06/D07** Rarity shimmer plus ready/unusable lift on the hotbar.
