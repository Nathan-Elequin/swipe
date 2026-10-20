# Paper Fight

**What it is:** Before any gameplay change is coded, write the idea down and try to break it using the cards already in the game. Ask Nathan only the questions whose answers would change what I write. Then implement.

**What it is not:** A delay for feel, art, copy, or layout. Not a second content board. Not “build it as soon as I hear it” for new rules.

You can say: *Paper-fight this before you code.*

---

## When this applies

A new or changed **item, monster, special, formula, spend rule, targeting rule, phase rule, or core feature.** Dictation, chat pitch, or a Behavior Save whose Flow/Notes do not already say what happens in the awkward cases.

## When this does not apply

- Player-facing prose only (Jam copy, names, explainers that do not change how the card works).
- Art / audio / motion with no rule change.
- He named an exact existing number (“bleed is +2, not +1”) and nothing else.
- He said **skip the Paper Fight** / **just ship it** / **F5 this**.
- Ability, Flow, and Notes on this Save already agree and say what happens when this card meets the rest of the roster.

If Ability vs Flow vs Notes disagree: Paper Fight, do not guess. Same as the content-board rule.

---

## File

1. Read this rubric.
2. Overwrite `design/paper-fight/CURRENT.md` from `TEMPLATE.md`.
3. Fill every heading. If “Which existing cards this touches” is empty, the write-up is not done.
4. Ask the questions that would change the code (`AskQuestion`, multiple choice). **Do not implement in that turn.** A monster pasted in the chat shorthand is this step, same as any other new card.
5. After he answers: implement, then move CURRENT to `design/paper-fight/done/YYYY-MM-DD-slug.md`.

Worked example: `_example-copy-the-owner.md`.

---

## Rubric (every fight)

### 1. Restate the pitch
What the player clicks, when (title / draft / ready / spin / fight / after), what number they see, whether the card is used up. If you cannot say this in four sentences, you do not understand it yet — ask that, not trivia.

### 2. Place it on the live game
Name the phase and which existing card it is most like (Throwing Knife: click then pick a target; Crossbow: neighbor; Shield: block; Hornet: two swings; Wraith: copy ATK; Commander: last in the formula; …). Whether the number is copied once or keeps updating. Whether they must click a target or it happens by itself.

### 3. Which existing cards this touches
Walk the **current** roster for collisions. At least: Hornet, Queen, Wraith, Commander/Lich, Dragon pierce, Goblin (no ATK damage), Mimic (gift / no swing), Slime (ATK = HP), empty alcove, last owner, tutorial kit, Developer Test. Add whoever else the pitch actually touches. Skip a name only if you can say why it cannot collide.

### 4. Two readings
**Generous** (best for the player) and **stingy** (the smallest version that still matches the sentence). If both are valid English, ask Nathan which one he means. Do not pick one myself.

### 5. Ways it can fail
Crash, the game stuck, infinite loop, the card used up twice, still waiting for a target after the card is gone, card text that does not match the hit, Shift equation that does not match the hit, tutorial with no legal target.

### 6. What the player sees
In under a second: whose turn, can I click this, what number comes out. If the Ability needs a paragraph to be true, the generous reading is probably too much for one card.

### 7. If we skip it vs if we take the strongest reading
Skip it: which existing card already does a weaker version of this. Strongest reading: can one click from the hotbar end the fight by itself. If yes, ask how hard the card should be, not how flashy.

### 8. Questions
Only things that change the code: who you can target, copied once vs keeps updating, number only vs extra swings and pierce, whether a failed use still spends the card. Not flavor. Not “should this be fun.” Ask them together. Stop.

---

## Self-audit (tick before you speak)

- [ ] Restated as what the player does, not engine names.
- [ ] Named at least one **live** card or special that this would collide with.
- [ ] Wrote both readings.
- [ ] Every question would change what I write.
- [ ] CURRENT.md is filled.
- [ ] Not implementing this turn.

If any of those is missing, I do not understand the idea well enough to build it. Fill the file, then ask.

---

## After answers

Implement the whole remaining reading Nathan chose, in this chat. Do not reopen flavor. Do not open a second question round. New collisions found while coding are clustered and written down; they do not stop the build. Do not add screens. Player-facing sentences come from the board Save / dictation — do not synonym-rewrite Jam copy. Put the behavior next to the other item and monster ops. Then say: where it is, what the rule does, what to click in Play.
