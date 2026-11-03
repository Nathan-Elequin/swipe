# SCREEN: Combat selector UX ? Look H overlay panel (2026-11-03)

Nathan locked **Look H** on 2026-11-03: mode options leave the starter seat chrome and open as a **cream overlay panel** floating above that seat. Look C in-chrome tags are superseded. Clone tiles over other hotbar seats stay dead.

Source of truth: Doop canvas https://doop.design/c/8a-B18k4cY
- **H1** frame `Kb2qpofDn2` ? Throwing Knife overlay (LOCKED)
- **H2** frame `0KhSoe1IXV` ? Net overlay ×3 (LOCKED)

Exports / chat refs (1680×1040): `design/visual/mockups/look-h-2026-11-03/`
`H1-knife-overlay-icons.png`, `H1-screenshot-ref.png`, `H2-net-overlay-icons.png`.
Older Look C / A?F exports: `mockups/selector-ux-2026-11-03/`.

## Look lock

1. **Overlay panel above the starter seat.** Cream panel ~340?360px wide, caret pointing at the starter. Soft scrim dims the board. Not seat clones. Not in-chrome tags.
2. **Knife (2 options):** two large side-by-side targets (~158×190). Item icon tile + mode badge (red throw/speed = discard; green return = keep) + Spin labels exactly `ATK 3, discard` / `ATK 1, keep` (split as primary + secondary). Keys 1 / 2 optional.
3. **Net (3 options):** three stacked rows (~322×62). Net icon tile + strength pips + labels `-1 Attack` / `-2 Attack` / `-3 Attack` (ASCII hyphen OK). Keys 1 / 2 / 3.
4. **Magnet (same choose path):** three stacked rows using existing option strings (`Highest Attack` / `Lowest Attack` / `Off`). Magnet-consistent icon. Do not invent new player-facing copy.
5. **Starter keeps CHOICE aura** (`#7CC8F0`) + cancel X (top-right). Other seats stay dimmed.
6. **Cancel:** starter X, Esc, or click scrim ? dismiss overlay and exit mode choose.
7. **Hand picks:** CHOICE aura on legal cards + cancel X on the starter. No mode panel.
8. **Hired Hand / monster offers:** Take arc Decline / Continue. No mode panel.
9. **Crossbow / wheel aims:** glow on wheel + dim hand + cancel X. No mode panel.
10. Never show "Tier", "Swipe" or "boss-rush". Don't add new player copy beyond locked mock prompts / existing option labels. Copy changes go to Jam / PLAYER_COPY.

## Code ? kill vs keep

| Anchor | What it does | Verdict |
|---|---|---|
| `scripts/mode_choice_overlay.gd` | Look H panel + scrim + caret + knife/rows targets | **OWN** the mode UI |
| `scripts/main.gd` `_place_mode_choice_overlay` / `_rebuild_choice` | Builds rows from `pending_choice` options; shows overlay above starter | KEEP / wire here |
| `scripts/main.gd` `_place_choice_tiles` / `_make_mode_choice_tile` | Old ItemCard clones over seats | **DEAD** ? do not restore |
| `scripts/item_card.gd` `set_mode_tags` | Look C in-chrome tags | **CLEAR-ONLY** stub; never rebuild tags |
| `scripts/item_card.gd` `set_cancel_corner` | Top-right X while Look H is open | KEEP |
| `scripts/main.gd` `choice_overlay` | Legacy host under hotbar | Keep empty (no clones) |
| `scripts/main.gd` `_selector_take_word` | Decline / Continue | KEEP |
| Cancel / dim / toss / aura wiring | set_cancel_pick / set_selector_dim / set_toss_pick / CHOICE | KEEP |
| Option dicts (`combat.knife_throw` / `knife_nick`, Net ?1/?2/?3, Magnet labels) | Read-only source of target text | KEEP |

## Asset / export notes

- **No new card PNGs.** Panel from StyleBoxFlat + Labels + TextureRect. Badges / caret / pips are tiny procedural ImageTextures in TextureRects.
- Mount under the main UI root (`ModeChoiceOverlay`, z 90), full 1680×1040.
- Texture filter Nearest for item glyphs.
- Hover rim uses CHOICE `#7CC8F0`.

## Out of scope

Gameplay/option logic, Take arc art, wheel glow art, Feedback mode pills, new Jam strings beyond locked mock prompt fallbacks.
