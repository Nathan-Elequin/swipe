---
id: REQ-20261101-hotbar-aura-kit
status: done
priority: high
branch: cursor/hotbar-aura-kit-9c33
tip_sha: e0a360b3
base: playtest/latest
created: 2026-11-01T20:30:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress → delve → fight with hotbar visible
---

# Hotbar aura kit Direction A + Basilisk Stone Gaze visuals

Cloud ship of Direction A aura roles (READY/WARN/CHOICE/LINK), Unplayable 8px hatch on petrify, Gargoyle/Basilisk BR stamps, Hex@1 mint vs Toll@1 crimson, Decay link/warn, Basilisk Gaze phases. Logic for Stone Gaze largely existed; visuals + Spin-locked tip strings wired.

## What to verify

- Recycler@1 / Magnet armed / Pacemaker-Potion armed: solid pulsing READY #F2A93B (not old ember).
- Rust hover + Beggar mark + Gaze will-petrify + Decay partner hover: dashed static WARN #E8553E.
- Merchant upgrade candidates + toss-pick: double thin CHOICE #7CC8F0.
- Decay pair idle: violet LINK + TL diamond pip.
- Spent / Gargoyle petrify / Basilisk stone: grey desat + 8px diagonal hatch; G stamp+band vs B stamp+scale rim.
- Hex@1 mint face (never red); Toll@1 crimson lethal only.
- Basilisk enter: eye + green rim on up to 3; hover one → others WARN chip "Will be Petrified."; Use → others hatch+B stamp; tip "Petrified while the Basilisk remains"; free on Defeat/Polymorph shatter + brief READY flash (not on Catapult).
- Never show the word Tier.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | fight hub | Recycler at 1 or Magnet armed | READY solid pulsing gold ring | 01-ready-aura.png |
| 02 | fight hub | Rust in hand, hover a Block item | Rust shows WARN dashed | 02-rust-warn.png |
| 03 | fight hub | Merchant upgrade offer | CHOICE double blue on candidates | 03-choice-merchant.png |
| 04 | fight hub | Zombie Decay pair | violet LINK + TL pip; hover one → partner WARN "Will be discarded." | 04-decay-link.png |
| 05 | fight hub | Gargoyle petrify | hatch + G stamp BR + segmented band | 05-gargoyle-petrify.png |
| 06 | fight hub | Basilisk Gaze → Use one | other Gazed: hatch + B stamp + scale rim; tip phrase exact | 06-basilisk-stone.png |
| 07 | fight hub | Hex at 1 and Toll at 1 (separate or same shot) | Hex mint; Toll crimson only | 07-hex-toll-polarity.png |

## Pass criteria

- Each mock state from design/visual/SCREEN-hotbar-aura-kit.md readable in-game.
- No player-facing "Tier".
- Spin strings exact where listed in PR body.

## Outbox path

`playtest/repot/outbox/REQ-20261101-hotbar-aura-kit/`
