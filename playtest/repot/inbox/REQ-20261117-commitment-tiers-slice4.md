---
id: REQ-20261117-commitment-tiers-slice4
status: open
priority: high
branch: cursor/playtest-commitment-tiers-slice4-64ec
pr: 541
tip_sha: 57d09324
created: 2026-11-17T00:20:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → pick any tier → DevChrome Ctrl+Shift+3 (BIG tier) then Ctrl+Shift+9 (force big milestone) at cabin. Or finish a run that entered Shadow Abyss (b5) and come home.
---

# Commitment tiers slice 4 — BIG victory screen

Celebratory Shadow Abyss victory screen with deterministic victory code, Discord/copy actions, and the same rating + prompts Send as the offramp. Compact re-view via goal icon / pause menu.

## What to verify

- Big milestone opens the victory screen for **any** chosen tier (silent auto-upgrade to BIG if lower).
- Shown once (`offramp_shown_big`); pending survives reload until open.
- Title / Nathan line / framed VICTORY CODE / screenshot instructions.
- Copy code + Discord button (disabled "coming soon" while `data/playtest-links.json` discord_url is empty).
- Rating 1–5, four BIG prompts, Anything else, Send / Keep playing / I'm done for now. **No Go deeper.**
- Done → thank-you card (no carrot / deeper).
- After close: goal icon done-BIG click or pause **My victory code** reopens compact code card.
- Code format `ABYSS-XXXX-XXXX` stable across reopen; telemetry `victory_shown` + feedback payload include code.
- Editor force-big still opens this screen.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | cabin | big victory full | title + code frame + Discord/Copy + rating/prompts | 01-victory-full.png |
| 02 | cabin | I'm done for now | thank-you card | 02-victory-thanks.png |
| 03 | cabin | re-view code card | compact code + Copy + Discord + Close | 03-victory-code-card.png |

## Pass criteria

- All rows at 1680×1040 (or note viewport).
- Cloud outbox has headless plates; replace with headed F5 shots if they differ.
- `RESULT.md` marks each id pass/fail.

## Outbox path

`playtest/repot/outbox/REQ-20261117-commitment-tiers-slice4/`
