# SCREEN: Nib dialog box (cabin) and small bubble

Mocks: `_pixel_extras/review/mocks/01_main_room_first_visit.png` (box), `02_main_room_nib_interrupt.png` (choices), `09_loft_bed_quit.png`. GIFs: `nib_bust_talk.gif`, `nib_talk.gif`, `nib_psst.gif`.

This is new: `scripts/cabin/cabin_dialog.gd` (Control). It is **not** `tutorial_guide.gd`; that one stays tutorial-only (audit §7). The look is built from the shipped 9-slices so it matches the tutorial's talk box: the same speaker key, the same `sfx.speak`.

## Node tree
```
CabinDialog (Control, full rect, z 7 in CabinRoot, mouse STOP while open)
├── Box        NinePatchRect ui/dialog_box_9.png, patch margins 12 native (48 px), size 300x64 native = 1200x256, at native (60,186) [y 170 when choices]
├── Tail       TextureRect ui/speech_tail.png under the box, x aimed at the speaker (Nib's head x), optional
├── Plate      NinePatchRect ui/nameplate_9.png 40x14 native at box + (8,-8); Label tutorial.speaker ("Nib")
├── Bust       TextureRect nib/nib_bust_f0..f2 / nib/nib_bust_blink.png 32x32 native at box + (10,14)
├── Text       RichTextLabel at box + (50,13), width 238 native, 30 px font, ink #3a2414, visible_characters typewriter
├── Next       AnimatedSprite2D ui/dialog_next_f0..f1 @ 300 ms at box bottom-right − (18,16); hint label nib.next (tooltip only)
└── Choices    HBox at box + (64,68): up to 3 choice tags (ui/choice_tag_idle / _hover / _press, 9-slice margins 8,4 native), 92x16 native each, 12 native gap
```

## Behaviour
- `say(keys: Array, choices := [], speaker := "nib")` plays lines in order and returns the picked choice index (or −1) via `finished(choice)`.
- **Typewriter:**
  - 45 chars/s. Each new line calls `sfx.speak(&"nib", text)` (existing speech ticks).
  - The bust mouth cycles `nib_bust_f0..f2` every 90 ms while typing.
  - It blinks (`nib_bust_blink`) every 3–5 s.
- The in-room Nib sprite (if visible) plays `talk` while typing and `idle` otherwise.
- Click / `ui_accept`: if typing, finish the line; else go to the next line.
  - On the last line with choices, the choice tags appear (pop scale 0.8→1, 0.12 s, staggered 60 ms) and clicks outside them are ignored.
  - `ui_left`/`ui_right` move the focus between choices; `ui_accept` picks.
- Escape: advances if there are no choices; ignored when choices are up.
- Open: Box position.y +20 native → final, modulate.a 0→1, 0.15 s. Close: reverse 0.1 s.
- `{n}` fills use `PLAYER_COPY.fill(key, {...})`.

## Small bubble (non-blocking one-liners)
Used for `cabin.locked`, `nib.home.new`, `cabin.cat.line`, `map.first_only` and the `nib.prompt` bubble:
- A NinePatchRect `ui/dialog_box_9.png`, auto-sized to its text (max width 140 native), 26 px font.
- It sits over the speaker (or the clicked hotspot), with `ui/speech_tail.png` pointing down.
- Hold = 1.2 s + 0.04 s per char, then fade 0.2 s. No blips except `nib.prompt`, which plays `speech.nib_psst` once per menu visit.

## All line sets (keys only; texts are in data/player-copy.additions.json)
| Set | Keys | Choices |
|---|---|---|
| First visit | `nib.first.1`, `nib.first.2`, `nib.first.3` | — |
| Tutorial gate | `nib.interrupt.1`, `nib.interrupt.2` | `nib.interrupt.yes`, `nib.interrupt.no` |
| After declining | `nib.interrupt.no_reply` | — |
| After the tutorial | `nib.tutorial_done` | — |
| Idle (cycle) | `nib.idle.1` … `nib.idle.6` | — |
| Props | `nib.portrait`, `nib.fire`, `nib.chair`, `cabin.telescope.line`, `cabin.telescope.none`, `cabin.trunk.empty`, `cabin.bed.web` | — |
| Dummy | `cabin.dummy.ask` | `cabin.dummy.yes`, `cabin.dummy.no` |
| Bed (desktop) | `cabin.bed.ask` | `cabin.bed.yes`, `cabin.bed.no` |
| Homecoming | `nib.home.loss.1..3`, `nib.home.win.1..3`, `nib.home.nothing_new`, `nib.milestone.25/50/75` | — |
| Key ring | `keyring.1`, `keyring.2`, `keyring.door.hall/study/workshop/loft`, `keyring.done` | — |
| Ending | `ending.nib` | `ending.continue` |

**Copy:** `tutorial.speaker`, `nib.next`, `nib.prompt`, `nib.first.1`, `nib.interrupt.1`, `nib.interrupt.2`, `nib.interrupt.yes`, `nib.interrupt.no`, `nib.interrupt.no_reply`, `nib.tutorial_done`, `nib.idle.1`, `cabin.locked`, `nib.home.new`, `cabin.cat.line`, `map.first_only`, `cabin.dummy.ask`, `cabin.dummy.yes`, `cabin.dummy.no`, `cabin.bed.ask`, `cabin.bed.yes`, `cabin.bed.no`, `cabin.bed.web`

**Cues:** `speech.nib`, `speech.nib_psst`, `speech.nib_gasp`, `speech.nib_chuckle`, `cabin.click`, `cabin.hover`

**Code hooks:** `audio_fx.gd` `speak` (existing), `PLAYER_COPY.text` / `fill`, `tutorial_guide.gd` `_build_talk` (121; for visual reference only, not reused).
