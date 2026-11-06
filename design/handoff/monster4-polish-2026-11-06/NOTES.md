# Polish — scale-four-monsters (slash + idle)

**Pass:** 2026-11-06 · PixelLab `/animate-with-text-v3` · floor 100 · no tip-wire

## Balance
- Before: **768.4**
- After: **760.0**
- Billed gens this pass: **8** (4 slash A + 2 idle + 2 slash B alts)
- Optional crab hurt / huntsman Take-X VFX: **parked** (headroom left; not required)

## Recommendations (Nathan lock via Pixel chat)
| id | slash | idle | notes |
|---|---|---|---|
| huntsman | **A** | (exists facing_idle) | Bow raise → fire + cyan streak; readable attack |
| quicksand_crab | **B** | (exists facing_idle) | A was flinch/compress; B has clearer claw lunge |
| phantom | **B** | **A** (new) | A slash ≈ breathe; B more flare/reach. Idle haze flicker OK |
| collector | **A** | **A** (new) | Slash ends with specimen-jar thrust; idle vials/staff tilt |

Single-cand ids auto-copied to `*/locked/slash/` and (phantom/collector) `*/locked/facing_idle/`. Crab+phantom locked/slash hold **B** (recommended).

## slash_base choice
All four: **facing_LOCKED NEAREST fit/pad → 48×48** (not first anim frame).
- huntsman facing already 48×48 (identity)
- crab / phantom / collector facing 64×64 → thumbnail+center pad to 48×48

## Layout on disk
```
polish/{id}/slash_base.png, slash_f0..f3.png   # recommended
polish/{id}/slash_A/…                         # crab+phantom only (archived A)
polish/{id}/slash_B/…                         # crab+phantom B source
polish/phantom|collector/idle/f0..f3.png
polish/SLASH-CONTACT.png
polish/IDLE-CONTACT.png
*/locked/slash/…                              # recommended copies
phantom|collector/locked/facing_idle/f0..f3   # new real idle
```

## Failures
None.

## SFX
Not in this pass (art only). Combat SFX still open for Scale/audio lane.
