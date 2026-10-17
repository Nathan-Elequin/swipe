# STORY BIBLE: Swipe, "The Snatchwick Inheritance"

DRAFT for Jam (copy owner) and Nathan. All player-facing text lives in `data/lore.json` and `data/player-copy.additions.json`. This file is the reference behind that text, not shippable copy.

## One-line pitch
An orphaned goblin inherits a cabin from a legendary grandfather they never knew. The catch: everything he owned is inside a mountain, in the pockets of monsters.

## Premise
- **Bartleby "Lucky" Snatchwick, Esq.** was the luckiest, clumsiest delver who ever lived. He fell into treasure, fell out of danger, and wrote footnotes about both.
- He died in the deepest part of **Mount Grumblegut** (the **Bellyvault**). Nobody is sure how, and Nib won't say.
- His will names the grandchild as heir. Nib calls them **Sprout**, and the will remembers that they bit him.
- The monsters of the Grumble picked up his named possessions after he fell. Every piece is engraved: *PROPERTY OF B. SNATCHWICK. IF FOUND, HOW DARE YOU.*
- **The condition:** bring every piece home to the **Snatchwick Cabinet of Considerable Curiosities**. Fill it, and the cabin and the deed to **Kettle Hill** are yours.

## The rules, in story terms (each one maps to a mechanic)
| Fiction | Mechanic |
|---|---|
| Only what you're holding when you get out comes home (will §3). | An item is swiped only if it is in the hand at the rope exit (Challenge) or on a Classic win. |
| "What the mountain keeps, it keeps." | Death loses the whole sack. A loss homecoming is an empty bag. |
| Grandpa tied rope ladders in every belly "for emergencies". | The Challenge rest phase is a rope ladder: Climb home, or Delve deeper. |
| Grandpa's map is wrong ("drawn from memory; his memory was mostly confidence"). | The map picks the route/mode and marks your deepest belly. |
| New-to-the-cabinet items glint in your hand. | The never-swiped glint. |
| Nib is the executor and keeps the keys. | Rooms unlock after your first successful haul (the key-ring cutscene). |
| The deed is stamped when the cabinet is full. | Ending cutscene at 100 %, then play continues. |

## Cast
| Who | Role | Voice / look |
|---|---|---|
| **Sprout** (the hero) | Player character, 32x32 goblin. Lime skin, teal cloak #4f8a7c, red scarf #d0644a, amber eye. **Never speaks**; reacts with yips and sighs. | Small, scrappy, hopeful. Wears the gear from the rack (cosmetic only). |
| **Nib** | Imp. Grandpa's sidekick, fence and valet; now his executor. Monocle, mustard coat. **The main voice.** | Dry, fond, pedantic. Loves stamping. Paid in biscuits. Pretends not to be sentimental ("Executors don't cry. They file."). |
| **Grandpa** (Bartleby Snatchwick) | Seen only in portraits, the will, journal entries, letters and footnotes. **Never alive on screen and never speaks aloud.** | Bilbo Baggins writing his memoirs, crossed with Heimerdinger explaining an invention. Grandiose, self-crediting, accidentally wise, footnote-addicted. |
| **Gloria** | The firefly that powers the radio. | Never speaks. Bites if you tap the glass. |
| **The cat** | Loft cat. | Ignores you magnificently. |
| **The monsters** | Grandpa met them all. They now hold his things. | Bestiary entries give each one a name and a grudge. |

Named monsters (from `lore.json` → `glossary.cast`):
- Gorm the Golem (waves at everything)
- Old Fenwick the Wizard
- King Pettifog the Cowardly
- Count Varnish
- Old Smoulder the Dragon
- Queen Arachnelda
- Brunhilda the Berserker
- Brother Oswin Plunk the Cleric ("heals, then invoices")
- Hob the Merchant, cousin of Muddlecombe's pawnbroker Mrs. Hobnail

Rival: **Dame Prudence Vexley**, an explorer who is always right. She is Grandpa's favourite footnote target.

## Places
- **Muddlecombe:** the village. Sprout grew up alone over the tannery (intro panel 1).
- **Kettle Hill:** the cabin on the hill, facing the mountain. Five rooms:
  1. **The Front Room:** fire, Grandpa's chair, the run door, the map, the radio, the gear rack, the small portrait.
  2. **Trophy Hall:** the Cabinet.
  3. **The Study:** big portrait, desk with the will, Grandpa's journal (bestiary and curiosities), and the bell-jar model of the Grumble.
  4. **The Workshop:** training dummy (tutorial replay), Brag-o-Meter (stats), Patents Pending (credits), and the ladder up.
  5. **The Loft:** bed (quit), telescope, trunk of letters, and the cat.
- **Mount Grumblegut, "the Grumble":** it rumbles like an empty stomach.
  - Levels are **bellies** (Belly 1, Belly 2 …). Use "belly" in player text, never "dungeon number" in fiction lines; the existing combat UI keeps its own copy.
  - The deepest belly is the **Bellyvault**.
- The three routes on the map:

| Route | Mode | Grandpa's note |
|---|---|---|
| **The Gatehouse** | Classic | One dungeon. Win it and the hand comes home. |
| **The Long Drop** | Challenge | Belly after belly, a rope ladder after each one. |
| **Grandpa's Shortcut** | Quick Start | "Grandpa swore it was faster." |

## Tone rules for writers
1. **Warm, funny, a little sad.** Grief is in the background, never the punchline. Nib deflects; Grandpa's writing gives the game away.
2. **Grandpa's journal voice:** first person, past tense, a boast that turns into a confession.
   - 40–80 words per item entry, plus one footnote (¹) that undercuts or deepens it.
   - Mentions what the item *does* in story terms only. The mechanical text is the live `_item_rule` line above the entry.
3. **Bestiary voice:** Grandpa again, 25–50 words. Names the monster, says how it fights in plain story terms, and ends on a joke at his own expense.
4. **Nib voice:** short lines (under 25 words), dry, calls the hero "Sprout", and references biscuits, stamps and filing no more than once per scene.
5. **Banned in player text:**
   - The word **"Tier"**: use Weak / Tough / Deadly (`tier.1-3.name`, `journal.weak/tough/deadly`).
   - Modern slang; fourth-wall talk about "the game" or "menus".
   - "Victory" after a death.
6. **Items keep their catalog names.** Journals never rename an item; they call it "my …".

## Story beats in play order
| # | Beat | When | Copy |
|---|---|---|---|
| 1 | Intro (≈30 s, 5 panels, skippable) | First boot (`intro_seen == false`) | `intro.*` |
| 2 | First visit: Nib's welcome | First time the main room shows after the intro | `nib.first.1-3` |
| 3 | Tutorial gate | First run-door click while the tutorial is neither done nor declined | `nib.interrupt.*` |
| 4 | Runs | Map → door | `map.*` |
| 5 | Rope exit after each Challenge clear | `rest` phase | `rope.*`, `sack.*` |
| 6 | Homecoming: loss (empty sack) or win (dump, NEW items fly to the hall) | After every run | `nib.home.*`, `cabin.new_count` |
| 7 | Key ring: Nib finds the keys and four doors open | After the first win homecoming | `keyring.*` |
| 8 | Milestones at 25/50/75 %: a Nib line plus a letter in the loft trunk | Win homecomings | `nib.milestone.*`, `lore.json` `letters` |
| 9 | Ending: deed stamped, last letter; play continues | Cabinet full | `ending.*`, `letter_100` |
| 10 | The left-hand drawer unlatches: rocks, a last note, the lucky geode | Right after the ending | `drawer.*`, `lore.json` `drawer_note` |

## The will (shown in the study; copy keys `will.*`)
- Five short paragraphs. They state the rules in story terms: everything left to the grandchild; the items are in the mountain; only what you hold when you get out counts; full cabinet = deed; Nib paid in biscuits.
- Signed `will.sign`, witnessed `will.witness`.
- Running joke: "Do not open the left-hand drawer of my desk." It pays off in the key ring ("Mind the left-hand drawer") and the last letter, and then the drawer itself opens (below).

## The left-hand drawer (post-ending secret)
- **Before the ending** it is stuck. There is no keyhole, only a brass plate. Clicking it rattles; something heavy shifts inside. Nib's three lines keep the joke going.
- **Why it opens:** it is Grandpa's Patent No. 7, the Rightful Heir Latch. It opens for his heir and nobody else. The ending stamps the deed, so the latch lets go with a clunk Nib hears from the main room.
- **What's inside:** about sixty rocks. They are the "geodes. Mostly." from the first letter: he meant to post Sprout one every week and never posted any (Nib counted ninety-one). Most are only rocks. One, cracked open and lined with teal crystal (Sprout's cloak colour), is the real thing: the luck the last letter mentions.
- **The last note** (`lore.json` `drawer_note`, Grandpa's voice, no contractions) explains the latch and the rocks and hands over the luck.
- **The memento:** "Put it on the mantel" moves the lucky geode to the main-room mantel, between the candles, for good. It is cosmetic. Nib has two lines for it.
- Continuity: the drawer is the only post-ending content. It adds no mechanic, item, or stat, and it does not count toward the cabinet.

## Sample entries (see `lore.json` for all of them)
**Grappling Hook (item, journal):**
> My dearest gadget. It pulls a neighbouring monster into my fight and usually shakes loose a trinket on the way. I have also used it to retrieve hats, cats, and once my own trousers from a chandelier.
> ¹ I installed knotted rope ladders in every belly of the Grumble with this. For emergencies. You are welcome.

**Lantern (item, journal):**
> My old brass lantern. It mends you a little, and if you are still hurting, it refuses to go out. I carried it into every belly of the Grumble and it never blinked once, unlike me.
> ¹ Put it in the window if you ever want me to know you are home. Old habit.

**Golem (bestiary):**
> Gorm. Seven feet of pure opinion carved out of the mountain's knee. As hard to knock down as a hillside, and with the conversational range of one. I taught him to wave. He waves at everything now, including me, very hard.

(Samples match the Jam-reviewed `lore.json`.)

## Continuity checklist
- Grandpa never appears alive. No voice, no sprite outside portraits and cutscene silhouettes.
- Nib is blue-skinned with a monocle and a mustard coat. The hero is lime green, so the two stay distinct.
- The rope ladders exist because Grandpa tied them. Mention this at most once per screen.
- The loft opens with the key ring. The last letter is about the full cabinet, not the loft.
- The map is "mostly accurate", so the deepest flag can sit oddly on the drawing without contradicting anything.
