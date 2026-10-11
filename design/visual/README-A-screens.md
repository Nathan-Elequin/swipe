# Direction A screen pack (2026-10-11)

Chosen: **Direction A "Torchlit Burrow" + Layout 1 "Side Door"** (Annie, 2026-10-11). Wheel locked at (548,350). This pack extends A from the draft gate to every screen.

- Tokens and theme: [style-guide.md](style-guide.md)
- Screens: [title](SCREEN-title.md), [how-to-play](SCREEN-how-to-play.md), [wheel](SCREEN-wheel.md), [placement](SCREEN-placement.md), [fight](SCREEN-fight.md), [victory](SCREEN-victory.md), [defeat](SCREEN-defeat.md), [pause](SCREEN-pause.md), [inspect](SCREEN-inspect.md), [hand-card](SCREEN-hand-card.md), [draft-gate](SCREEN-draft-gate.md)
- All prompts in one file: [CURSOR-PROMPTS-A.md](CURSOR-PROMPTS-A.md)
- Sprite bases and recolours: [SPRITE-SOURCING.md](SPRITE-SOURCING.md)
- Mockups: `mockups/*_v1.png` (draft gate `_v2`). Live on Doop: [Swipe Art Refresh — Prep](https://doop.design/c/Evbwm-9bMX), row "A · 00–12"
- Jam's answers applied:
  - Pause labels Master/Music/Sound and the placement hint "Pick an empty spot." are read from keys (`pause.master`, `pause.music`, `pause.sound`, `door.seat_hint`); monster/loot labels come from `door.owner`/`door.shiny` (locked: "THE MONSTER" / "THE LOOT"). Never hard-code owner or bait on player screens.
  - DOOR OPEN dropped.
  - {tier} is filled from `tier.N.name`.
  - KO plum kept.
  - 8-card hands use 124 px cards; the hand cap is a game rule and isn't changed.
- Damsel in Distress art: on hold. The full refresh overrides CREATIVE-UX-PACK.md wherever they conflict.
