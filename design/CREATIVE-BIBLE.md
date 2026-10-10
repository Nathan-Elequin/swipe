# Swipe — Creative bible (Jam owns this)

**Role:** Jam is sole creative director / narrative / player-facing copy / art keywords. Nathan owns rules, numbers, ids, Godot. Cursor implements strings from Jam’s files; Cursor does not “improve” flavor.

**Version:** v2 — 2026-10-06. Replaces the synonym-swap handback.

---

## The game in one breath

You are a greedy little thief. A door keeps flashing bait. **Take** = you steal it; then the owner appears, furious, and sits in an alcove to take it back. **Pass** = leave it. Fill eight seats. **Spin** = fight for the pile. Block, attack, defeat, hearts — all real combat. Alive is the only score.

## Through-line

Steal the shiny. Survive who owned it.

## Tone

**In:** impish, cute, greedy, cheeky, short, smug, bossy (Nib), outraged (owners).  
**Out:** mill poetry, chapel gloom, epic prophecy, meme spam, gift-shop Pip, Darkest Dungeon sermons.

## Cast

| Who | Job |
|---|---|
| **You** | Sticky-fingered pest. Never called a hero. |
| **Nib** | Fence / older cousin. Proud you stole. Annoyed you brought owners home. Tutorial voice. |
| **Owners** | Monsters. First person (`I`/`My`). One rule each. Angry about *their* loot. |
| **The door** | Bait first, owner second. Labels: THE DOOR / THE BAIT / THE OWNER. |

## Adventure beat (what the player should feel)

1. Title: temptation, not a tour.  
2. Door: shiny → Take → slam → “that’s MINE” → seat them.  
3. Spin: someone wants their stuff *now*.  
4. Combat: spend stolen tools or eat the hit.  
5. Win: pile stays. Lose: empty hands.

## Source files

| File | What |
|---|---|
| `data/player-copy.json` | **Playable strings** (title, tutorial, door, cues, combat chrome, taunts, card text). **Apply this.** |
| `design/CREATIVE-BIBLE.md` | This doc — intent / tone / ownership. |
| `design/CURSOR-IMPLEMENT.md` | How Cursor applies without rewriting. |
| `design/creative-director-handback.md` | Superseded by v2; keep for history or delete. |

## Art (keywords only — no new systems)

Priority: replace helmet-as-flask. Cohesive 16×16 pixel dungeon, cute-imp thief portrait, glowing bait loot, bronze/silver/gold rims. CC0 first. Avoid grim chapel photoreal, cyberpunk, Animal Crossing candy.

Searches: `16x16 pixel cute imp thief`, `16x16 circular dungeon top down`, `16x16 glowing relic loot`, `16x16 iron helmet item`, Kenney parchment UI (already in).

## Revision rule

Nathan playtests → three bullets (confusing / funny / dead) → Jam revises `player-copy.json` → Cursor reapplies. Nobody else rewrites voice.
