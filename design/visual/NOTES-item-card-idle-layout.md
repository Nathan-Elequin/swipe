# NOTES: Item card Brand New shine + idle layout (2026-11-02)

Nathan F5 after hotbar layout #297. Locked retune — no extra polish.

## Locks

1. **Brand New shine OFF** on hotbar / hand cards. `set_draft_glow(false)` for uncollected / Brand New items. Keep `New!` cabinet badge. Keep aura kit (READY / WARN / CHOICE / LINK) and door-gate THE SHINY (`phase == "draft"` on the offer card only).
2. **Idle title ~+50%** vs post-#297: `IDLE_TITLE_FONT_MAX` 14→21, `IDLE_TITLE_H` 16→24.
3. **Sprite size kept** at 58×58; **`IDLE_SPRITE_NUDGE` 4px** under the title so the art sits slightly lower (closes gap above face icons).
4. **Idle effect icons ~+20%**: `ItemFace.SIZE_HOTBAR` 36→43; fonts 18→22 / 16→19. Still vertically centered in the face host (`EXPAND_FILL` + center anchors).

## Code

- `scripts/item_card.gd` — idle constants + SpriteNudge
- `scripts/item_face.gd` — SIZE_HOTBAR / fonts
- `scripts/main.gd` — stop wiring uncollected → `set_draft_glow`

## Net 1/2/3 chip (2026-11-04)

After the idle glyph retune, Net's on-icon `−1–3` text fought the corner `1 / 2 / 3` choice badge. Face is now a bare blue burst; the range chip parks bottom-right (`item_card.set_choice_badge` when `card_id == "net"`). Knife keeps the short top-right chip.

## Out of scope

Hub Take-arc / Spin button. Player-facing copy. Aura kit art.
