# SCREEN: Combat selector UX — C in-chrome tags (2026-11-03)

Nathan locked **Direction C** on 2026-11-03: mode options become in-chrome tags on the **starter seat** card itself. A (face bands) and B (docked chips) are rejected. Net is the only 3-input case: cram three tags, slight overlap with the item sprite is OK.

Source of truth: Doop canvas https://doop.design/c/8a-B18k4cY
Exports (1680x1040 @2x): `mockups/selector-ux-2026-11-03/`
`C1-knife-in-chrome-tags.png` (locked look), `A2-net-x3.png` (use for Net *layout density only*; render as C tags, not bands), `D1-hand-pick.png`, `E1-hired-hand-decline.png`, `F1-crossbow-wheel.png`. Older live refs: `_refs/`.
Tip at spec time: `playtest/latest` @ `beef7d97`.

## Look lock

1. **Tags live in the starter seat's chrome.** They're stacked label plates inside the card frame (rim/lower band), not separate cards. No tiles over other hotbar seats.
2. **Knife: 2 tags.** Copy from existing options (main.gd:9625-9626): `PLAYER_COPY combat.knife_throw` → "ATK 3, discard"; `combat.knife_nick` → "ATK 1, keep".
3. **Net: 3 tags, crammed.** Existing labels (main.gd:154-156): "-1 Attack" / "-2 Attack" / "-3 Attack". Tags may overlap the item sprite slightly; keep them readable and inside the card's outer rim.
4. **Each tag is its own click target.** Click picks `_choose_option(opt)`. Hover = CHOICE aura colour on that tag's border.
5. **Starter seat keeps cancel X** (`set_cancel_pick`). Other hand cards keep `set_selector_dim` when not legal.
6. **Hand picks (D1):** CHOICE aura on legal cards (`set_toss_pick` → `AURA_CHOICE`) + cancel X on the starter. No tags.
7. **Hired Hand / monster offers (E1):** Take arc word swaps to "Decline" (`_selector_take_word`, `hired_bribe`); Worm hunger → `title.continue` "Continue". No tags.
8. **Crossbow / wheel aims (F1):** glow on wheel targets + dim other hand cards + cancel X on starter. No tags.
9. Never show "Tier", "Swipe" or "boss-rush". Don't add new player copy. Copy changes go to Jam / PLAYER_COPY.

## Code — kill vs keep

| Anchor | What it does now | Verdict |
|---|---|---|
| `scripts/main.gd:25016` `_place_choice_tiles` | Builds one ITEM_CARD clone per option and places them **over other hotbar seats** (`hosts`), fallback right of the starter | **KILL**. Replace it with a tag build on the starter card |
| `scripts/main.gd:25058` `_make_mode_choice_tile` | Full ITEM_CARD clone (icon, fill, ATK number, `set_aura_role("choice")`, `picked → _choose_option`) | **KILL** the clone. Move its label logic (knife_throw/knife_nick PLAYER_COPY lookups, `opt.label`) to the tag builder |
| `scripts/main.gd:25003` `_rebuild_choice` | Clears choice_box/overlay, defers `_place_choice_tiles` | KEEP the shape; point the deferred call at the new tag builder |
| `scripts/main.gd:575/1436` `choice_box` | Hidden HBox (always `visible=false`) | Leave alone; it already stays hidden |
| `scripts/main.gd:24987` `_selector_take_word` | Decline / Continue | KEEP |
| `scripts/main.gd:24506-24513`, `24886-24888` | set_cancel_pick / set_selector_dim / set_toss_pick wiring | KEEP |
| `scripts/item_card.gd:1626` `set_toss_pick` | Turns on playable + `AURA_CHOICE` | KEEP |
| `scripts/item_card.gd:1711` `set_cancel_pick` | Cancel disc + X overlay (z 24) | KEEP; tags must sit below the X (z < 24) and not cover it |
| `scripts/item_card.gd:1721` `set_selector_dim` | modulate 0.50/0.48/0.46 + hatch + sink | KEEP |
| `scripts/main.gd:9625-9626`, `154-156` | Option dicts + labels | KEEP; read-only source of tag text |

## Asset / export notes

- **No new card PNGs.** Build tags from code: `PanelContainer` + `StyleBoxFlat` (parchment/wood fill, 2px ink border, small corner radius consistent with card chrome) + `Label` with the existing UI font and outline.
- Mount them via `item_card._overlay_host()` or a new `set_mode_tags(opts: Array, on_pick: Callable)` / `clear_mode_tags()` on item_card.gd. z between the face and the cancel mark.
- Texture filter Nearest for any glyph textures; `_kind_mark("ATK")` glyph may be reused at the tag's left edge. Nothing new to draw.
- Tag sizing: about `card_w - 12` wide. Knife 2 rows, Net 3 rows sharing the lower ~55% of the card. Minimum label font ~13px at 1680x1040.
- Use the CHOICE aura colour for hover and focus, rim `7CC8F0` (already used in the clone tile).

## Out of scope

Gameplay/option logic, Take arc art, wheel glow art, new strings.
