# Cursor prompt — Draft gate wiring + layout (2026-10-07)

Paste everything below the line into Cursor.

---

You are working in the Godot 4.7 project "Swipe" at C:\Users\Natha\Documents\boss-rush. Task: wire the draft-gate (draft/mystery-door screen) to existing player-copy keys and fix its layout.

HARD RULES
- Do NOT rewrite, add, or delete any player-copy text. data/player-copy.json is the live copy source (loaded by scripts/player_copy.gd) and its draft-gate lines were just locked and approved on 2026-10-07. Only wire keys and change layout.
- Do not edit data/player-copy.json, data/player-copy.csv, or data/author-locks.json, and do not trigger the in-game Script editor Save.
- Read all player-facing strings through PLAYER_COPY / COPY (.text or .fill). If you need a code fallback string, copy the CURRENT text from data/player-copy.json verbatim — do not invent wording.
- Never show the word "Tier" to the player. Internal tier 1/2/3 = player Weak/Tough/Deadly (keys tier.1.name / tier.2.name / tier.3.name).
- Do not touch other screens (title, tutorial, combat, inspect, pause).

CHANGES

1. Pass counter fill (scripts/draft_gate.gd, _kenney call in setup() ~line 133 and set_passes() ~line 287)
   - door.pass is read with COPY.text(), so placeholders are never filled. Switch to COPY.fill("door.pass", {"n": n}, <current door.pass text>).
   - When n <= 0, use COPY.text("door.pass_none", ...) for the disabled button.
   - If n == 1, prefer key "door.pass_one" when it exists (fall back to door.pass). Do not add that row yourself; the copy owner will add it and will update door.pass to "Leave it ({n} passes left)" once this fill is live.

2. Tier names + item-card subtitle (scripts/draft_gate.gd TierStamp._draw ~line 540, scripts/item_card.gd set_rank ~line 253, scripts/main.gd _refresh_offer_card ~line 2389, scripts/boss_wheel.gd _draw_tier_num ~line 791)
   - Add one helper (e.g. in player_copy.gd or main.gd) that maps tier int 1/2/3 -> COPY.text("tier.%d.name" % t).
   - Show the offer-card subtitle using COPY.fill("door.guard", {"tier": <tier name>}) -> e.g. "Guarded by a Weak monster". set_rank() currently hides _rank; make it display the passed text.
   - The TierStamp currently draws roman numerals I/II/III, and the wheel draws tier numbers. Either keep them as pure iconography (metal + shape, no text) or replace the text with the tier name — but never "Tier N". Keep the metal colors and plate shapes.

3. _rank_label (scripts/main.gd ~line 1367)
   - It returns "Tier %s". Make it return the tier name via the helper from step 2. (Its only caller, _titled, is currently unused; fix it anyway so it can never leak "Tier" if surfaced.) Developer-only dev-panel tiles and _log lines may keep internal tier numbers.

4. Wire door.help and door.take (scripts/draft_gate.gd)
   - _rules/_rules_box, _hint, _hook, _door_title, _tier_sub, _send are created in setup() but hidden and never added to the scene tree, so door.help ("The finer the loot, the fiercer its owner.") and door.take ("Take it") never appear.
   - Show door.help as the risk-rule line under the header (_cue, which uses cue.ask) during "ask" mode.
   - Add a visible Take button (door.take) next to the Leave button that triggers the same path as clicking the item card (send_pressed -> main._on_gate_send). Keep the card click working too.
   - Leave door.title / door.shiny / door.owner / door.hook unwired unless needed; do not change their text.

5. Keep the dungeon visible the whole time during drafting (layout, not copy) (scripts/draft_gate.gd setup(), present_mystery(), set_seat(), dock())
   - The full-screen _dim ColorRect is alpha 0.62 with MOUSE_FILTER_STOP during "ask" mode, and the 560x620 panel is docked centered over the wheel, hiding the dungeon.
   - Remove the dim or lighten it a lot (or limit it to the panel area), and move the panel off the wheel (to the side, like seat mode already does via wr.end.x + 8) so the whole wheel/dungeon stays visible while choosing, through the reveal, and during placement.
   - Keep the gate modal in behavior (only Take/Leave/card clicks act during "ask") without covering the dungeon visually.

ACCEPTANCE
- Draft screen shows: "Take it or leave it?", the risk rule, the item card with "Guarded by a Weak/Tough/Deadly monster", "Take it", and the Leave button with a correct pass count once the copy owner updates door.pass.
- No player-visible "Tier" anywhere; no literal "{n}" or "{tier}" on screen.
- Dungeon/wheel fully visible throughout drafting.
- git diff shows no changes under data/.