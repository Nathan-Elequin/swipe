---
id: REQ-20261101-hotbar-aura-kit
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-01T14:50:00-05:00
machine: Cherry
tip_sha: 7209bbe3
godot: F5 playtest (godot-mcp exec setup + viewport PNG 1680×1040)
---

# Result

Hotbar aura kit Direction A, shot on `cursor/hotbar-aura-kit-9c33` @ `7209bbe3`. Viewport 1680×1040. No player-facing "Tier".

| id | verdict | note |
|----|---------|------|
| 01 | pass | Recycler@1: solid pulsing gold READY ring (#F2A93B), not the old ember. |
| 02 | pass | Rust in hand, Shield Block hovered: Rust dashed static WARN red. |
| 03 | pass | Merchant facing; all four candidates double thin CHOICE cyan rings. Item pool was empty so native `_merchant_ask` logged "no upgrade"; `pending_feed` kind=upgrade was applied so CHOICE still paints. |
| 04 | pass | Decay pair: Shield violet LINK + TL diamond pip; Net dashed WARN chip "Will be discarded." (chip truncates slightly on the 147px card). |
| 05 | pass | Longbow: grey desat + 8px hatch, G stamp bottom-right, segmented duration band. |
| 06 | pass | After Gaze Use: Net hatch + B stamp + green scale rim; inspect warn exact `Petrified while the Basilisk remains`. Longbow also stoned behind the hover plate. |
| 07 | pass | Hex@1 mint face/rim (never red); Toll@1 crimson lethal wash only. |

## Blockers

None for the seven required frames. Native Merchant upgrade pool is empty until a real delve fills `item_pool` (shot 03 used the same CHOICE path as a live offer).

## Shots

All PNGs under `shots/` using the filenames from the request table.
