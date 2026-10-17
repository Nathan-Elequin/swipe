# SCREEN: Key ring (rooms unlock after the first successful haul)

Mocks: `_pixel_extras/review/mocks/13_cut_keyring_p1.png`, `15_main_keyring_unlock.png`. GIFs: `_pixel_extras/review/key_ring.gif`, `side_door_unlock.gif`, `ladder_unlock.gif`.

Trigger: the end of a **win** homecoming when `counters.hauls == 1` (just incremented) and `key_ring_seen == false`. Also on the first menu visit for migrated v1 players with swiped items (SYSTEMS §4). The state machine is in SYSTEMS §6.

## Sequence (inputs: click advances dialog; the sequence itself cannot be skipped, about 25 s)
| t | Beat | Visual | Audio | Copy |
|---|---|---|---|---|
| 0 | Nib gasps, rummages | Nib `nib/nib_gasp.png` 0.5 s, then `nib_walk` to the fire mantle and back (Tween x 216→120→216 native, 1.2 s total) | `speech.nib_gasp` | — |
| 1 | Panel | `_cutscene` shows `cutscenes/keyring_p1.png` in the frame (as in the intro) | `cabin.key_jingle`, `cabin.panel` | `keyring.1`, then `keyring.2` |
| 2 | Back in the room | Panel fades out; `KeyRing` `props/key_ring_f0..f2` (1/2 jingle @ 120 ms) appears in Nib's hand at Nib origin + (14,8) | `cabin.key_jingle` | — |
| 3 | Door 1: Hall | Nib walks to the SideDoor (x 216→352). Door anim `doors/side_door_unlock_f0..f3` @ 110 ms. `doors/unlock_sparkle_f0..f3` centred on the padlock (door origin + (16,32) − (16,16)). Then `doors/side_door_closed.png`. | `cabin.unlock`, `cabin.chain_drop` on f2, `sting.unlock` | `keyring.door.hall` |
| 4 | Pan to the hall | Host pan (SYSTEMS §1.2). Nib is not drawn in other rooms; the dialog shows only his bust. The hall SideDoor unlocks the same way. | same | `keyring.door.study` |
| 5 | Pan to the study | Study SideDoor unlocks | same | `keyring.door.workshop` |
| 6 | Pan to the workshop | `doors/ladder_unlock_f0..f3` @ 110 ms on the Ladder, then `doors/ladder_open.png` | same | `keyring.door.loft` |
| 7 | Pan back to main | Nib back at 216, KeyRing hidden | `cabin.pan` | `keyring.done` |

After each door: append the room to `rooms_unlocked` and `_save()`. At the end: `key_ring_seen = true`, `_save()`, and the background textures of the other rooms are already loaded (SYSTEMS §1.2).
- The tags [[114, 126], [142, 134], [170, 134], [198, 126]] are panel-local positions of the four key tags on `keyring_p1`. They are for an optional label pop; no text is drawn on them.

## Copy and cues
**Copy:** `keyring.1`, `keyring.2`, `keyring.door.hall`, `keyring.door.study`, `keyring.door.workshop`, `keyring.door.loft`, `keyring.done`, `tutorial.speaker`

**Cues:** `speech.nib_gasp`, `cabin.key_jingle`, `cabin.panel`, `cabin.unlock`, `cabin.chain_drop`, `sting.unlock`, `cabin.pan`, `cabin.room_sign`, `speech.nib`
