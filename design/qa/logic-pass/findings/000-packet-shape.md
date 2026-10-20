# 000 — Packet shape (dry run, Side)
Status: SIDE
Family: art
Cards: needleback
Phase: fight

## Expected
Notes on Needleback: portrait is a stand-in until a porcupine/toad tile exists. Side log for Pixel. Not a logic FAIL.

## Observed
Spin Needleback. Fight is playable. Art is still the stand-in.

## Repro
1. Developer Test: seat Needleback, Enter, Spin.
2. Look at the portrait. Do not draw a replacement.

## Files you may touch
- none for Cursor. Pixel owns PNG bytes.

## Do not
- draw or replace PNG bytes
- butler push

## Acceptance
This packet is the fixer-handoff shape for the Bucket 0 demo. No code change.
