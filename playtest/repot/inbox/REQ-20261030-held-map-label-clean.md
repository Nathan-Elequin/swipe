---
id: REQ-20261030-held-map-label-clean
status: open
priority: high
branch: playtest/latest
created: 2026-10-30T20:15:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Continue / Brand New → cabin → open Grandpa's map (held map hotspot)
---

# REQ-20261030-held-map-label-clean

**Screen:** Held Grandpa map (ChatGPT plate — clean painted text)  
**What shipped:** When `map_in_hands_living.png` (ChatGPT plate) is loaded, hide always-on code Labels that duplicate painted art: biome name Labels (Verdant / Crystal / Ashen / Cinder / Shadow / Endless), locked muted names, Endless sealed always-on + sealed_sub always-on. Keep WaxStamp peel / hover lift / press flatten, Verdant `_add_start` pin (not a WaxStamp), hit areas, hover tips (`START HERE` on Verdant pin, `click to set off` on stamps), click-to-start-run. State-only lines not painted on the plate (Endless depth record, open tip) stay always-on. Endless sealed status moves to hover tip. Supersedes [REQ-20261030-chatgpt-grandpa-map](../archive/REQ-20261030-chatgpt-grandpa-map.md).  
**Viewport:** 1680×1040 · Nearest · no gameplay / no player-facing copy string edits · stamp filenames unchanged

## Outbox
`playtest/repot/outbox/REQ-20261030-held-map-label-clean/shots/`

## What to verify

- Idle held map: painted badge names and START HERE banner read cleanly — no grey code Labels smeared over them.
- Verdant remains the START pin (flag + green dot); hover still shows tip; click still starts.
- Unlocked WaxStamps still peel on hover and press-flatten; click still starts the run.
- Endless sealed: no duplicate grey “Endless” / “ENDLESS · SEALED” always-on Label over the painted seal note; hover still surfaces sealed status.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | held map | Brand New → open map from cabin (idle, no hover) | ChatGPT plate; no grey code biome Labels over badges; no duplicate START HERE code Label over the painted banner | 01-idle-no-code-labels.png |
| 02 | held map | same, hover Verdant START pin | Flag + green dot still there; hover tip / pin feedback still works (not a WaxStamp peel) | 02-verdant-start-hover.png |
| 03 | held map | DEV fill every cabinet → hover Shadow Abyss | Wax peel lifts (~12px / −16°) with “click to set off”; no grey “Shadow Abyss” name Label beside the stamp | 03-shadow-peel-no-name.png |
| 04 | held map | look at / hover Endless seal (bottom-left), cabinets not all full if sealed | Overlay on painted dark seal; painted “ENDLESS - SEALED …” readable; no duplicate grey Endless / sealed always-on Label | 04-endless-seal-no-dup.png |

## Pass criteria

- All four PNGs at 1680×1040.
- Idle shot has no grey FitLabel/Label biome names stacked on painted badge text.
- Verdant is still `_add_start` (pin), not converted to WaxStamp.
- Shadow hover still peels; tip “click to set off” visible.
- Endless has no smeared duplicate sealed/name Label.

## Copy / gameplay

No copy string edits. No rule changes. Stamp filename slugs unchanged (`b2` may still be `sunken_mire`). Verdant stays `_add_start` by design.
