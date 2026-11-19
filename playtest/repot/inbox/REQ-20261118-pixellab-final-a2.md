---
id: REQ-20261118-pixellab-final-a2
status: done
priority: high
branch: playtest/latest
viewport: 1680x1040
entry: fresh save → Brand New / Middle Progress → real fight path
---

# REQ-20261118-pixellab-final-a2 — PixelLab final-A coverage re-drain

Follow-up to REQ-20261118-pixellab-final-a (3/16 pass; 13 not reached or not readable). Re-check only these rows.

Rules: fresh save, real player path, input only via godot-mcp injected mouse/key events into the game window. Never OS-level mouse/keyboard or computer-use control; don't take over Nathan's screen or cursor. No dev hooks, forced poses, seeds or jump-to-screen shortcuts. 1680x1040. Short FX: capture a burst (every ~50 ms for ~0.6 s) around the moment and keep the clearest frame. Play as many fresh runs as needed (cards/monsters are random); stop after 4 runs and report what was never dealt.

Checks:
- 03 monster attack that removes HP: claw/bite/thud overlay readable over the hub hero, plus heart break.
- 04 block: ice-blue clang ring; shield crack when block is used up.
- 05 escape: escaped dust mark on the seat.
- 06 heal: heart refill frames on the hub hearts (plus sparkle from final-b).
- 07 wheel: pointer tick while spinning, land bounce and landing burst.
- 09-13 starter strikes when dealt: Throwing Knife, Knucklers, Spiked Flail, Da Boot, Spinning Top.
- 14-16 cut-ins when seated and their ability fires: Imp, Glass Asp, Fungal Colony.

Write RESULT.md (pass / fail / not reached per row, with shot names) to playtest/repot/outbox/REQ-20261118-pixellab-final-a2/, commit and push to playtest/latest. If an effect plays but is unreadable (too small/short/hidden), say which and why.
